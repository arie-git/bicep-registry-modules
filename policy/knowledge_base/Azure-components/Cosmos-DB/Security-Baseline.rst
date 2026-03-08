Security baseline Cosmos DB
===========================

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
     - February 15, 2023
     - Pascal Dortants
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - July 9, 2024
     - Michiel Janssen
     - Added baseline control ``drcp-cosmos-09``.
   * - 1.2
     - August 15, 2024
     - Harmien Beimers
     - Added baseline control ``drcp-cosmos-10``.
   * - 1.3
     - January 16, 2025
     - Michiel Janssen
     - Updated control ``drcp-cosmos-10`` to scope to PROD-usage.

.. |AzureComponent| replace:: Cosmos DB
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-cosmos-01
     - Disable Public network access.
     - Disabling public network access improves security by ensuring that your Cosmos DB account isn't exposed on the public internet. Creating private endpoints can limit exposure of your Cosmos DB account.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable public network access.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-02
     - Microsoft Entra ID authentication.
     - Disable local authentication methods so that your Cosmos DB accounts must require Microsoft Entra ID identities for authentication.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable local accounts.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-03
     - Key based write access.
     - This policy enables you to ensure all Azure Cosmos DB accounts disable key based metadata write access.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable key based write access.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-04
     - Deploy Advanced Threat Protection for Cosmos DB accounts.
     - This policy audits for Azure Cosmos DB resources that should have Advanced Threat Protection enabled.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: advanced threat protection isn't disabled.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-05
     - Enforce TLS 1.2 or newer.
     - Configure a TLS version for secure communication between a Cosmos DB and other infrastructure or services to ensure the confidentiality of data. To reduce security risk, the recommended TLS version is the latest released version, which at this point is TLS 1.2.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce policy: Cosmos DB should use the specified TLS version.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-06
     - Only NoSQL databases.
     - Limit the use of databases to NoSQL.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: everything except NoSQL.
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-07
     - Automated private link DNS integration.
     - If you use a private link, the DNS setting is automatically configured for the Cosmos DB.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a auto remediation policy: DNS settings are automatically set on the private link.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cosmos-08
     - Ensure data backups are available.
     - Cosmos DB supports two backup modes; Continues (max retention of 30 days) and Periodic Backup.
     - H
     - A = 3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Ensure to enable at least one of the offerings on the Cosmos DB
     - Microsoft Defender for Cloud: Compliant policy.
   * - drcp-cosmos-09
     - Microsoft Defender for Cloud.
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for Cosmos DB.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-cosmos-10
     - Zone redundancy.
     - Enable zone redundancy for achieving higher availability.
     - L
     - A = 3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy for Environments with usage Production. Other usages (DTA) aren't audited.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt