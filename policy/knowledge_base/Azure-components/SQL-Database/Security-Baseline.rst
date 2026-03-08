Security baseline SQL Database
==============================

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
     - February 2, 2023
     - Tim Eijgelshoven
     - Initial version.
   * - 0.2
     - August 25, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 0.3
     - January 24, 2024
     - Ivo Huizinga
     - Added baseline controls.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: SQL Database
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - Nr.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-sql-01
     - Disable Public Network Access.
     - To enhance network security, you can configure your SQL Database to disable public access. This will deny all public configurations and allow connections through private endpoints.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: SQL Database should disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-02
     - Administrator Microsoft Entra ID authentication.
     - Disable administrator accounts for your SQL Database so that it isn't accessible by a local administrator. Disabling local authentication methods like the administrator user improves security by ensuring that SQL Databases require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable the local administrator account.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-03
     - Microsoft Entra ID authentication.
     - Disable local accounts for your SQL Database so that it isn't accessible by a local accounts. Disabling local accounts improves security by ensuring that SQL Databases require Microsoft Entra ID identities for authentication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disable local accounts.
     - DRCP will check every quarter.
   * - drcp-sql-04
     - Data encryption.
     - Enable transparent data encryption on SQL instances so data isn't left in a transparent state.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: transparent data encryption on SQL databases.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-05
     - Enforce TLS 1.2 or newer.
     - Configure a TLS version for secure communication between a SQL Database and other infrastructure or services to ensure the confidentiality of data. To reduce security risk, the recommended TLS version is the latest released version, which at this point is TLS 1.2.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce policy: SQL Databases should use the specified TLS version.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-06
     - Vulnerability Assessment.
     - Follow up the Vulnerability Assessment to ensure a better security by getting alerts on vulnerabilities.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy: enable vulnerability assessment on the Azure SQL Servers.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-07
     - Backup status.
     - Ensure that there is a backup policy with a minimum of 5 PIT days on SQL instances.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: See if the retention days is 5 or more.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-08
     - Microsoft Defender for Cloud.
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for your Azure SQL Database. Defender for Cloud has a maintained list of exploit identification for SQL Databases.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: Defender for SQL Database isn't disabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-09
     - Security alerts.
     - Use the Microsoft Defender for creating security alerts for your Azure SQL Database.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Set an audit policy: security alerts aren't disabled for SQL implementations.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sql-10
     - Automated private link DNS integration.
     - If you use a private link, the DNS setting is automatically configured for the Azure SQL Database.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an auto remediation policy: DNS settings are automatically set on the private link.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt