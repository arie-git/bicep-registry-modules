Security baseline App Service
=============================

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
     - April 19, 2023
     - Michiel Janssen
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - Juny 9, 2024
     - Michiel Janssen
     - Added baseline control ``drcp-aps-20``.

.. |AzureComponent| replace:: App Service
.. include:: ../../_static/include/security-baseline-header1.txt

These App Service kinds and hosting are in-scope:

- Logic App (v2)
- Function App
- Web App
- Static Web App
- App Service Environment v3
- App Service Plan (only SKUs that support private link).

Out of scope kinds and hosting:

- Mobile App
- Logic App (v1 - Workflow variant)
- App Service Environment v1 and v2
- Integration Service Environment (in any kind or version)

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
   * - drcp-aps-01
     - Disable public network access
     - To improve the security of App Service, ensure that they aren't exposed to the public internet and attached to a private endpoint.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-02
     - Enforce HTTPS
     - Use of HTTPS ensures server/service authentication and protects data in transit from network layer eavesdropping attacks.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-03
     - Enforce HTTP 2.0
     - Periodically, newer versions released for HTTP either due to security flaws or to include new functionality. Using the latest HTTP version to take advantage of security fixes, if any, and new functionalities of the newer version.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-04
     - Deny lower / legacy TLS versions
     - Periodically, newer versions released for TLS either due to security flaws, include new functionality, and enhance speed. Upgrade to the latest TLS version to take advantage of security fixes, if any, or new functionalities of the latest version.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-05
     - Deny public network access to App Service Environments
     - To ensure apps deployed in an App Service Environment aren't accessible over public internet, one should deploy App Service Environment with an IP address in virtual network. To set the IP address to a virtual network IP, the App Service Environment must deploy with an internal load balancer.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-06
     - Deny lower / legacy TLS versions on App Service Environments
     - TLS 1.0 and 1.1 are out-of-date protocols that don't support modern cryptographic algorithms. Disabling inbound TLS 1.0 and 1.1 traffic helps secure apps in an App Service Environment.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-07
     - Deny Cross-Origin Resource Sharing (CORS) from all domains
     - Don't allow all domains to access the app with Cross-Origin Resource Sharing (CORS). Restrict interaction with your app to required domains.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-08
     - Audit for injection of App Service apps into a virtual network
     - Injecting App Service Apps in a virtual network unlocks advanced App Service networking and security features and offers greater control over the network security configuration.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-09
     - Audit for enabling of configuration routing of App Service apps
     - By default, app configuration such as pulling container images and mounting content storage don't route through the regional virtual network integration. Using the API to set routing options to true enables configuration traffic through the Azure Virtual Network. These settings allows the usage of features like network security groups and user defined routes, and service endpoints to be private.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-10
     - Audit for enabling outbound non-RFC 1918 traffic to Azure Virtual Network
     - By default, if one uses regional Azure Virtual Network (VNet) integration, the app routes RFC1918 traffic into that respective virtual network. Using the API to set 'vnetRouteAllEnabled' to true enables all outbound traffic into the Azure Virtual Network. This setting allows the usage of features like network security groups and user defined routes for all outbound traffic from the App Service app.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-11
     - Deny FTP access
     - An attacker listening to traffic on a public network used by a remote employee or a corporate network could see login traffic in clear-text which would then grant them full control of the code base of the App or service.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy to ensure FTP state is FTPs or disabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-12
     - Deny local authentication methods for FTP and SCM deployments to App Service
     - Disabling local authentication methods improves security by ensuring that App Service require Microsoft Entra ID identities for authentication. Learn more `here <https://aka.ms/app-service-disable-basic-auth>`__.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-13
     - Deny lack of internal encryption of App Service Environments
     - Setting InternalEncryption to true encrypts the page file, worker disks, and internal network traffic between the front ends and workers in an App Service Environment.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-14
     - Deny weak TLS Cipher suites in App Service Environments
     - Deny weak TLS Cipher suites in App Service Environments.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-15
     - Audit for legacy App Service Environment versions
     - Only allow App Service Environment version 3. Older versions of App Service Environment require manual management of Azure resources and have greater scaling limitations.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-16
     - Audit for enabling of remote debugging
     - Remote debugging requires to open inbound ports on an App Service app.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-17
     - Audit for latest version of application framework
     - Parties periodically release newer versions for software frameworks either due to security flaws or to include functionality. The recommendation is to use the latest software version for App Service apps, to take advantage of security fixes, if any, and new functionalities of the latest version.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-18
     - Deny anonymous authentication
     - By Enabling App Service Authentication, every incoming HTTP request passes through it before handled by the application code. It also handles authentication of users with the specified provider, validation, storing and refreshing of tokens, managing the authenticated sessions and injecting identity information into request headers.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-19
     - Audit for managed identity
     - Managed service identity in App Service provides more security by eliminating secrets from the App, such as credentials in the connection strings. When registering with Microsoft Entra ID in App Service, the App will connect to other Azure services securely without the need for usernames and passwords.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aps-20
     - Microsoft Defender for Cloud.
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for App Service.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and audit.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt