Incident remediation SQL Database
=================================

.. |AzureComponent| replace:: SQL Database
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-sql-01
     - Disable public network access.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` to ``Disabled``).

   * - drcp-sql-02
     - Administrator Microsoft Entra ID authentication.
     - Ensure to `configure administrator authentication <https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?view=azuresql&tabs=azure-powershell>`__ through Microsoft Entra ID for authentication.

   * - drcp-sql-03
     - Microsoft Entra ID authentication.
     - Ensure to `disable local accounts <https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?view=azuresql&tabs=azure-powershell>`__ and use Microsoft Entra ID for authentication.

   * - drcp-sql-04
     - Data encryption.
     - Ensure to `configure Transparent Data Encryption <https://learn.microsoft.com/en-us/azure/azure-sql/database/transparent-data-encryption-tde-overview?view=azuresql&tabs=azure-portal>`__.

   * - drcp-sql-05
     - Enforce TLS 1.2 or newer.
     - Ensure to configure the minimum TLS version to ``1.2`` (configure property ``minimalTlsVersion`` to ``1.2``).

   * - drcp-sql-06
     - Vulnerability Assessment.
     - Ensure to `enable the Vulnerability Assessment feature <https://learn.microsoft.com/en-us/azure/defender-for-cloud/sql-azure-vulnerability-assessment-enable>`__.

   * - drcp-sql-07
     - Backup status.
     - Ensure to configure a `backup policy <https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql>`__ with a minimum of 5 PIT days.

   * - drcp-sql-08
     - Microsoft Defender for Cloud.
     - Ensure to enable `Defender for Azure SQL <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-sql-introduction>`__.

   * - drcp-sql-09
     - Security alerts.
     - Ensure to enable security alert policies in `Defender for Azure SQL <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-sql-introduction>`__.

   * - drcp-sql-10
     - Automated private link DNS integration.
     - When deploying a private endpoint that belongs to Azure SQL, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.
