Security baseline PostgreSQL
============================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 0.1
     - January 20, 2025
     - Wieshaal Jhinnoe
     - Initial version.
   * - 1.0
     - January 23, 2025
     - Wieshaal Jhinnoe
     - First final version.
   * - 1.1
     - November 26, 2025
     - Michiel Janssen
     - Adjusted control ``drcp-psql-03`` (limit administrator principals).

.. |AzureComponent| replace:: PostgreSQL
.. include:: ../../_static/include/security-baseline-header1.txt

These Azure PostgreSQL types are in-scope:

- Azure Database for PostgreSQL flexible server.

Out of scope types:

- Azure Database for PostgreSQL single server (scheduled for retirement in March 2025).
- Azure Cosmos DB for PostgreSQL.

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
   * - drcp-psql-01
     - Disable public network access and enforce VNet integration.
     - Disabling public network access improves security by ensuring PostgreSQL isn't exposed on public internet and forces the use of VNet integration.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce deny policy: Disable public network access and enable VNet integration.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-02
     - Microsoft Entra ID authentication.
     - Disabling local authentication methods ensures PostgreSQL access restriction to Microsoft Entra ID identities.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable local accounts.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-03
     - Restrict administrator.
     - Restrict the PostgreSQL flexible server administrator allowed principals.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: only allow the Azure DevOps deployment principal (all usages), Engineer group (`development` usage) or Privileged Engineer group (`test`, `acceptance` and `production` usages).
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-04
     - Enforce service-managed encryption keys.
     - Enforces the use of service-managed encryption keys to prevent key loss and ensure data security.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable customer-managed keys.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-05
     - Disable PostgreSQL single server and CosmosDB PostgreSQL.
     - Ensures PostgreSQL flexible server enforcement. PostgreSQL single server and CosmosDB PostgreSQL isn't allowed. PostgreSQL single server deprecation starts in March 2025.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable PostgreSQL single server and CosmosDB PostgreSQL.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-06
     - Enforce minimum version of PostgreSQL.
     - Ensures PostgreSQL flexible servers run on a specific minimum version to meet compliance and security standards.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: PostgreSQL flexible server runs a minimum version.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-07
     - Enforce SSL connection.
     - Ensures all connections to PostgreSQL flexible servers use SSL to protect data from 'man in the middle' attacks.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: Enforce SSL connection.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-08
     - Enforce TLS 1.2 or newer.
     - TLS 1.2 or newer ensures secure communication and reducing risk from outdated protocols.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: PostgreSQL flexible server runs TLS version 1.2 or newer.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-09
     - Microsoft Defender for open source relational databases.
     - Use the Microsoft Defender for open source relational databases built-in threat detection capability and enable Microsoft Defender for your PostgreSQL to track and address threats.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: enable Defender for open source relational databases.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-10
     - Enforce Zone Redundancy.
     - Distributes database replicas across availability zones to ensure high availability and resilience against zone-level failures.
     - H
     - A = 3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy for usage Production: enable Zone Redundancy.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-psql-11
     - Disable PostgreSQL Extensions.
     - Ensures not to install PostgreSQL Extensions. Installing PostgreSQL extensions isn't allowed.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable PostgreSQL Extensions.
     - Microsoft Defender for Cloud. Compliant policy.


.. include:: ../../_static/include/security-baseline-footer.txt
