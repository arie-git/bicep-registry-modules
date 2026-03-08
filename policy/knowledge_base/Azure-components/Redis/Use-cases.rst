Use cases Redis
===============

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Managed Redis
---------------------
| Azure Managed Redis is a fully managed in-memory data store based on the open source Redis engine and offered as a service on Azure.
| It's designed to improve application performance and auto scalability by providing fast access to frequently used data.
| The service reduces latency and database load by storing data in memory, making it ideal for caching, session storage, and real-time analytics.

Scope
^^^^^
See article :doc:`Security baseline Redis <Security-Baseline>` for an actual overview of the scope of this component.

Use cases and follow-up
-----------------------

Authentication & Client access
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

**Microsoft Entra ID & Client access**

DRCP enforces Microsoft Entra ID authentication for centralized identity management. This blocks all client tools that are Access Keys based like `Redis-cli <https://learn.microsoft.com/en-us/azure/redis/how-to-redis-cli-tool>`__ and third party tools like `RedisInsight <https://learn.microsoft.com/en-us/azure/redis/how-to-redis-cli-tool#redis-cli-alternatives>`__.

DRCP recommends using SDKs since they support Microsoft Entra ID authentication. `Configure <https://learn.microsoft.com/en-us/azure/redis/entra-for-authentication#microsoft-entra-client-workflow>`__ the Redis client/SDK and request a `supported client library <https://learn.microsoft.com/en-us/azure/redis/best-practices-client-libraries>`__ if needed. See `quick start <https://learn.microsoft.com/en-us/azure/redis/development-faq#how-can-i-get-started-with-azure-managed-redis->`__ guides for examples.

Connectivity
^^^^^^^^^^^^

**Inbound Access**

Configure port 10000 on the client to send or receive data from the client to Redis. Optional are the 85xx port range needed for shard-level connections (clients connect directly to shards with `OSS cluster policy <https://learn.microsoft.com/en-us/azure/redis/architecture#cluster-policies>`__).

More information on `clustering <https://learn.microsoft.com/en-us/azure/redis/architecture#clustering>`__ and `sharding <https://learn.microsoft.com/en-us/azure/redis/architecture#sharding-configuration>`__.

**Outbound Access**

Redis is a passive service which means it doesn't use outbound connections for core functionality.

**Private DNS Zone**

Private endpoints of Azure Managed Redis use ``privatelink.redis.azure.net`` for private DNS resolving. The DRCP policy ``APG DRCP Redis Private DNS zones`` recognizes the domain suffix used by the component and completes (remediates) the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ to the corresponding private DNS zone.

Encryption at Rest
^^^^^^^^^^^^^^^^^^

DRCP enforces Microsoft managed keys for disk encryption to prevent loss of key.

`More information about encryption coverage. <https://learn.microsoft.com/en-us/azure/redis/how-to-encryption#encryption-coverage>`__

Encryption in Transit
^^^^^^^^^^^^^^^^^^^^^

DRCP enforces TLS for encrypted data transmission between client and cache.

`More information about TLS configuration settings. <https://learn.microsoft.com/en-us/azure/redis/tls-configuration>`__

Availability
^^^^^^^^^^^^^^^^^

**Zone redundancy**

DRCP is enforcing zone redundancy for Production usage, via the high availability option, which ensures the cache node is also available in the other zone.

`More information about high availability <https://learn.microsoft.com/en-us/azure/redis/overview#high-availability>`__.

**Data Persistence**

Azure Managed Redis uses managed disks enforced with Microsoft managed keys to store persistence data. These disks are fully managed by Microsoft and aren't directly accessible for users. This means you can't view, mount, or manage them. Nonetheless, you can configure:

- Persistence type: Choose between RDB (Redis database snapshots) or AOF (Append-only File write logs). `More information about Data Persistence <https://learn.microsoft.com/en-us/azure/redis/how-to-persistence#types-of-data-persistence-in-redis>`__.
- Backup frequency: For RDB, set how often Redis takes snapshots.
- Import/Export data: Move data between caches using the export feature, not the persistence disk. `More information about Import/Export data <https://learn.microsoft.com/en-us/azure/redis/how-to-import-export-data>`__.

**Eviction policy**

Azure Managed Redis uses eviction policies to remove cached keys when the component reaches memory limits. The default policy is ``volatile-lru`` which evicts keys with a time-to-live (TTL) set. `Configure <https://learn.microsoft.com/en-us/azure/redis/best-practices-memory-management>`__ the correct policy based on the business needs.
