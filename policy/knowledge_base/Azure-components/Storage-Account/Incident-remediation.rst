Incident remediation Storage Account
====================================

.. |AzureComponent| replace:: Storage Account
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-st-01
     - Disable public network access to a Storage Account.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` to ``Disabled``).

   * - drcp-st-02
     - Anonymous public read access to a Storage Account.
     - Ensure to disable public blob access (configure property ``allowBlobPublicAccess`` to ``Disabled``).

   * - drcp-st-03
     - Secure transfer of data to a Storage Account.
     - Ensure to enforce HTTPS traffic (configure boolean property ``supportsHttpsTrafficOnly`` to ``true``).

   * - drcp-st-04
     - Microsoft Entra ID authentication.
     - Ensure to disable the shared key access option (configure boolean property ``allowSharedKeyAccess`` to ``false``).

   * - drcp-st-05
     - Infrastructure encryption.
     - Ensure to require infrastructure encryption (configure boolean property ``requireInfrastructureEncryption`` to ``true``).

   * - drcp-st-06
     - Encrypt sensitive data in transit.
     - Ensure to configure the minimum TLS version to ``1.2`` (configure property ``minimumTlsVersion`` to ``TLS1_2``).

   * - drcp-st-07
     - Cross tenant object replication.
     - Ensure to disable cross tenant object replication (configure boolean property ``allowCrossTenantReplication`` to ``false``).

   * - drcp-st-08
     - Support for all types of encryption for all services.
     - Ensure to avoid the ``Blob and Files only`` option when using customer-managed keys in Azure Storage Account resources. Choose the option ``All services``.

   * - drcp-st-09
     - Disable sFTP for blob storage.
     - Ensure to disable sFTP access (configure boolean property ``isSftpEnabled`` to ``false``).

   * - drcp-st-10
     - Use of private DNS zones for private endpoints.
     - When deploying a private endpoint that belongs to any kind of Azure Storage (such as ``blob`` or ``queue``), clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-st-11
     - Microsoft Managed Resource Group for Databricks - Storage - Allow public network access.
     - No remediation information available. See the security baseline of this component for more information.

   * - drcp-st-12
     - Microsoft Managed Resource Group for Databricks - Storage - Enable Shared Key Access.
     - No remediation information available. See the security baseline of this component for more information.

   * - drcp-st-13
     - Microsoft Managed Resource Group for Databricks - Storage - Allow no encryption of queues and tables since these aren't supported for ADLS type storage account.
     - No remediation information available. See the security baseline of this component for more information.

   * - drcp-st-14
     - Microsoft Defender for Cloud.
     - Ensure to enable `Defender for Storage <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction>`__.

   * - drcp-st-15
     - No ACL and component firewall bypassing.
     - Ensure to disable ``Allow Azure services on the trusted services list to access the storage account``.
