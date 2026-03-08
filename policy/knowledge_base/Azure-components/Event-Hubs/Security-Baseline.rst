Security baseline Event Hubs
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
     - April 3, 2023
     - Ivo Huizinga
     - Initial version.
   * - 0.2
     - May 16, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - January 23, 2026
     - Michiel Janssen
     - Removed control ``drcp-evh-09`` after alignment with SecCons and global design renewal.

.. |AzureComponent| replace:: Event Hubs
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
   * - drcp-evh-01
     - Disable Public Network Access to Azure Event Hub.
     - To enhance network security, you can configure your Event Hub to disable public access. This will deny all public configurations and allow connections through private endpoints.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny: Event Hub Namespaces should disable public network access.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-02
     - Use of private DNS zones for private endpoints in Azure Event Hub Namespaces.
     - Event Hubs should be accessible through private endpoints that have their DNS records centrally registered in a private DNS zone group.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and remediate: configure Event Hub Namespaces to use private DNS zones.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-03
     - Virtual Network Integration.
     - The integration of Event Hubs with Virtual Network (VNet) Service Endpoints enables secure access to messaging capabilities from workloads. For example: virtual machines that use virtual networks, with the network traffic path secured on both ends.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy: Event Hub should use a virtual network service endpoint.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-04
     - Trusted Services.
     - The Trusted Services setting becomes visible after creating an Azure Event Hubs, to allow trusted Microsoft services to bypass the firewall / private link.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny: enabling the trusted services setting.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-05
     - Local authentication methods.
     - Use Microsoft Entra ID as the default authentication method to control your data plane access. A shared access signature (SAS) provides delegated access to Event Hubs resources based on authorization rules. An authorization rule has a name, associated with specific rights, and carries a pair of cryptographic keys. You use the rule's name and key via the Event Hubs clients or in your own code to generate SAS tokens. A client can then pass the token to Event Hubs to prove authorization for the requested operation. Avoid the usage of local authentication methods or accounts, wherever possible, you should disable these. Instead use Microsoft Entra ID to authenticate where possible.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny: Azure Event Hub Namespaces should have local authentication methods disabled
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-06
     - Authorization for the Event Hub Namespace.
     - When you create an Event Hubs Namespace, a policy rule named RootManageSharedAccessKey is automatically created for the Namespace. This policy has to manage permissions for the entire Namespace. It's recommended that you treat this rule like an administrative root account and don't use it in your application. You can create policy rules in the Configure tab for the Namespace in the portal, via PowerShell or Azure command-line tool. Avoid the usage of local authentication methods or accounts, wherever possible, you should disable these. Instead use Microsoft Entra ID to authenticate where possible. Use Azure role-based access control (Azure RBAC) to manage Azure resource access through built-in role assignments. You can assign Azure RBAC roles to users, groups, service principals, and managed identities.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce policies: remove all authorization rules, except RootManageSharedAccessKey, from the Event Hub Namespace. (deny). Audit authorization rules on Event Hub Namespaces (audit). Audit existence of authorization rules on Event Hub entities(audit).
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-07
     - Encrypt sensitive data in transit.
     - Configure a TLS version for secure communication the Event Hub and other infrastructure or services to ensure the confidentiality of data. To reduce security risk, the recommended TLS version is the latest released version, which at this point is TLS 1.2.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce policy: Event Hub Namespaces should have the specified TLS version.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-evh-08
     - Encrypt data for REST using platform keys.
     - Encrypt data for REST at the data plane level to protect the confidentiality of the data in the event of unauthorized access.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an Audit policy: Event Hub Namespaces should have double encryption enabled.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt
