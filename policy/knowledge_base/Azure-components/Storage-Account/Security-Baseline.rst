Security baseline Storage Account
=================================

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
     - February 6, 2023
     - Martijn van der Linden, Bas van den Putten
     - Initial version.
   * - 0.2
     - April 4, 2023
     - Ivo Huizinga
     - Updated baseline controls for global design.
   * - 0.3
     - August 25, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 0.4
     - January 24, 2024
     - Ivo Huizinga
     - Added baseline controls.
   * - 0.5
     - February 27, 2024
     - Michiel Janssen
     - Added baseline controls for Databricks.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - February 5, 2025
     - Harmien Beimers
     - Added baseline control ``drcp-st-15``.

.. |AzureComponent| replace:: Storage Account
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
   * - drcp-st-01
     - Disable Public Network Access to a Storage Account.
     - To enhance network security, you can configure your Storage Account to disable public access. This will deny all public configurations and allow connections through private endpoints.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: configure Storage Accounts to disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-02
     - Anonymous Public Read Access to a Storage Account.
     - Anonymous Public Read Access to containers and blobs in Azure Storage is a convenient way to share data but might present security risks. To prevent data breaches caused by undesired anonymous access, Microsoft recommends preventing public access to a Storage Account unless your scenario requires it.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: disallow public access to the Storage Account.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-03
     - Secure transfer of data to a Storage Account.
     - Secure transfer allows to perform REST API requests on the Storage Account with HTTPS. Use of HTTPS ensures authentication between the server and the service. It also protects data in transit from network layer attacks such as man-in-the-middle, eavesdropping, and session-hijacking. An advantage of this is, when creating a file share, it makes it impossible to use NFS as a protocol with a file share.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: allow secure transfer to Storage Accounts.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-04
     - Microsoft Entra ID authentication.
     - Every secure request needs authorization to a Storage Account. Microsoft Entra ID credentials or the account access key for Shared Key authorization authorizes a request. Between these two types of authorizations, Microsoft Entra ID provides superior security and ease of use over a Shared Key, so it's the preferred way.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy: Storage Account should prevent shared key access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-05
     - Infrastructure encryption.
     - Enable infrastructure encryption for higher level of assurance that the data is secure. Enabling infrastructure encryption makes sure that the Storage Account data has two layers of encryption.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Storage Accounts should have infrastructure encryption.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-06
     - Encrypt sensitive data in transit.
     - Configure a TLS version for secure communication between the client application and the Storage Account. To reduce security risk, the recommended TLS version is the latest released version, which at this point is TLS 1.2.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: Storage Account TLS Setting Deny to prevent the creating of a storage if they haven't opted for 1.2.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-07
     - Cross tenant object replication.
     - Audits restriction of object replication for Storage Accounts. Users can configure object replication with a source Storage Account in one Microsoft Entra ID tenant and a destination account in a different tenant. The data will replicate to a customer-owned storage account, which is a major security concern. By setting allowCrossTenantReplication to false, object replication will challenge if both source and destination accounts are in the same Microsoft Entra ID tenant.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an audit policy with value false: Storage Accounts should prevent cross tenant object replication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-08
     - Support for all types of encryption for all services.
     - The customer has 2 options to choose from: customer-managed keys for “blobs and Files” or “all service types" (blobs, files, tables and queues). After the creation of the Storage Account you can't change this setting. For future use this setting is now already set to 'all services'.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy with value true: Storage Account Customer Managed Keys Queue and Table Storage Deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-09
     - Disable sFTP for blob storage.
     - APG accepts ControlM (internal), SeeBurger (external) and Tibco in APG application landscapes for integrations. A policy disables it. DRCP revisits when DevOps teams has a valid reason to use the functionality.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-10
     - Use of private DNS zones for private endpoints.
     - Storage accounts should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a DeployIfNotExist policy to remediate.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-11
     - Microsoft Managed Resource Group for Databricks - Storage - Allow public network access.
     - The Microsoft managed resource group for Databricks creates a storage account with access from all networks. These Microsoft managed resource groups should be the ones where this is possible.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Exception on existing storage account policy for managed resource group: Allow Databricks deployment to create storage account with access from 'all networks' in Databricks managed resource group with pre-defined naming convention.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-12
     - Microsoft Managed Resource Group for Databricks - Storage - Enable Shared Key Access.
     - The Microsoft managed resource group for Databricks creates a storage account with Shared Key configuration. These Microsoft managed resource groups should be the ones where this is possible.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Exception on existing storage account policy for managed resource group: Allow Databricks deployment to create storage account with 'Shared Key Access enabled' in Databricks managed resource group with pre-defined naming convention.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-13
     - Microsoft Managed Resource Group for Databricks - Storage - Allow no encryption of queues and tables since these aren't supported for ADLS type storage account.
     - The Microsoft managed resource group for Databricks creates a storage account without encryption of queues and tables. These Microsoft managed resource groups should be the ones where this is possible.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Exception on existing storage account policy for managed resource group: Allow the Storage Account without encryption enabled on queues and tables in Databricks managed resource group with pre-defined naming convention.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-14
     - Microsoft Defender for Cloud.
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for Storage.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-st-15
     - No ACL and component firewall bypassing.
     - To enhance network security, you can configure your Storage Account to allow trusted Azure services to connect and ignore the component firewall. This control prevents enabling this bypass.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy: configure Storage Accounts to disable network ACL and firewall bypassing.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt