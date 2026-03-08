Security baseline Redis
=======================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 1.0
     - August 7, 2025
     - Wieshaal Jhinnoe
     - Initial version for Azure Cache for Redis.
   * - 2.0
     - Oktober 14, 2025
     - Wieshaal Jhinnoe
     - Microsoft announced the deprecation of Azure Cache for Redis (Enterprise). DRCP will continue with Azure Managed Redis.
   * - 2.1
     - November 13, 2025
     - Wieshaal Jhinnoe
     - Adjusted control ``drcp-redis-02`` and removed ``drcp-redis-03``.

.. |AzureComponent| replace:: Redis
.. include:: ../../_static/include/security-baseline-header1.txt

In-scope service types
----------------------
The following Redis service types are in scope:

- **Azure Managed Redis**

  - Resource ID: ``Microsoft.Cache/redisEnterprise``
  - Tiers: Balanced, Compute Optimized, Flash Optimized, Memory Optimized

Out-of-scope service types
--------------------------
The following Redis service types are explicitly excluded from the scope:

- **Azure Cache for Redis**

  - Resource ID: ``Microsoft.Cache/redis``
  - Tiers: Basic, Standard, Premium

- **Azure Cache for Redis Enterprise**

  - Resource ID: ``Microsoft.Cache/redisEnterprise``
  - Tiers: Enterprise, Enterprise Flash

Ownership
---------

.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-redis-01
     - Block Azure Cache for Redis and Azure Cache for Redis Enterprise.
     - Blocking Azure Cache for Redis (Enterprise) ensures the enforcement of Azure Managed Redis. DRCP doesn't support Azure Cache for Redis (Enterprise), because of deprecation by Microsoft starting in October 2026.

       Azure Managed Redis and Azure Cache for Redis Enterprise use the same resource ID. The chosen SKU determines the difference. Azure Cache for Redis Enterprise uses SKU's that start with Enterprise. DRCP blocks these SKU's.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Block Azure Cache for Redis and Azure Cache for Redis Enterprise.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-02
     - Disable public network access.
     - Disabling public network access improves security by ensuring the component isn't exposed on public internet.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Azure Managed Redis shouldn't use public access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-04
     - Use of private DNS zones for private endpoints.
     - Redis should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Configure Azure Managed Redis to use private DNS zones.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-05
     - Enforce Microsoft Entra ID authentication.
     - Disabling the Access Keys Authentication option ensures the restriction to Microsoft Entra ID identities.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Azure Managed Redis shouldn't use access keys for authentication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-06
     - Enforce Microsoft managed keys.
     - Disabling the customer managed key option enforces the use of Microsoft managed keys to prevent key loss and ensure data security.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Azure Managed Redis should use Microsoft managed keys.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-07
     - Enforce TLS access.
     - Enforcing TLS access ensures encrypted data transmition between clients and the cache. This protects it from eavesdropping, tampering, and man-in-the-middle attacks.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Azure Managed Redis should use TLS access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-08
     - Enforce TLS 1.2 or newer.
     - TLS 1.2 or newer ensures secure communication and reducing risk from outdated protocols.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: Azure Managed Redis should use TLS v1.2 or newer.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-redis-09
     - Enforce Zone Redundancy.
     - Distributes replicas across availability zones to ensure high availability and resilience against zone-level failures. DRCP enforces Zone Redundancy on production usage.
     - L
     - A = 3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy for usage Production: Azure Managed Redis should be Zone Redundant.
     - Microsoft Defender for Cloud. Compliant policy.


.. include:: ../../_static/include/security-baseline-footer.txt
