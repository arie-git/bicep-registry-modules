Incident remediation Redis
==========================

.. |AzureComponent| replace:: Redis
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-redis-01
     - Block Azure Cache for Redis and Azure Cache for Redis Enterprise.
     - Ensure to configure Azure Managed Redis as sub-resource type (resource ID ``Microsoft.Cache/redisEnterprise``). You can choose any `SKU <https://learn.microsoft.com/en-us/azure/templates/microsoft.cache/redisenterprise?pivots=deployment-language-bicep#sku>`__, except SKU's starting with the name Enterprise.

   * - drcp-redis-02
     - Disable public network access.
     - Ensure to disable public network access (configure boolean property publicNetworkAccess to disabled in ``Microsoft.Cache/redisEnterprise``).

   * - drcp-redis-04
     - Use of private DNS zones for private endpoints.
     - When deploying a private endpoint that belongs to Azure Managed Redis, clear the Private DNS zone configuration since DRCP policies remediate this configuration.

   * - drcp-redis-05
     - Enforce Microsoft Entra ID authentication.
     - Ensure to disable access key authentication (configure boolean property accessKeysAuthentication to disabled in ``Microsoft.Cache/redisEnterprise/databases``).

   * - drcp-redis-06
     - Enforce Microsoft managed keys.
     - Ensure to disable customer managed keys (configure boolean property customerManagedKeyEncryption to false in ``Microsoft.Cache/redisEnterprise``).

   * - drcp-redis-07
     - Enforce TLS access.
     - Ensure to disable non-TLS access (configure property clientProtocol to Encrypted in ``Microsoft.Cache/redisEnterprise/databases``).

   * - drcp-redis-08
     - Enforce TLS 1.2 or newer.
     - Ensure to configure TLS 1.2 or newer (configure property minimumTlsVersion to 1.2 in ``Microsoft.Cache/redisEnterprise``).

   * - drcp-redis-09
     - Enforce Zone Redundancy.
     - Ensure to enable Zone Redundancy for usage production (configure boolean property highAvailability to enabled in ``Microsoft.Cache/redisEnterprise``).
