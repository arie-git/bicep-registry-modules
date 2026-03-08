Security baseline Databricks
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
   * - 1.0
     - January 23, 2024
     - Onno Hettema
     - Initial version.
   * - 1.1
     - April 8, 2025
     - Cyprian Zurek
     - Added Major change history table and controls: drcp-adb-a09, drcp-adb-w24, drcp-adb-w25, drcp-adb-w26, drcp-adb-w27.
   * - 1.2
     - June 18, 2025
     - Harmien Beimers
     - Removed controls: drcp-adb-w06 and drcp-adb-w07. `[SAA-14606] <https://jira.office01.internalcorp.net:8443/browse/SAA-14606>`__
   * - 1.3
     - July 1, 2025
     - Harmien Beimers
     - Added baseline control: drcp-adb-w28. `[SAA-14361] <https://jira.office01.internalcorp.net:8443/browse/SAA-14361>`__


.. |AzureComponent| replace:: Databricks
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt


It consists of 3 tables:

- First table consists of **Azure Databricks** resource settings.
- Second table consist of **Databricks account** specific settings.
- Third table consist of **Databricks workspace** specific settings.

These policies are **Azure Databricks** resource specific and are manageable with Azure Policy:

.. list-table::
   :widths: 5 25 20 5 05 05 05 20 10 20
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
   * - drcp-adb-r01
     - Deny public network access for Azure Databricks workspaces
     - Disabling public network access improves security by ensuring that the resource isn't exposed on the public internet. You can control exposure of your resources by creating private endpoints instead.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Azure Databricks workspaces should disable public network access
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r02
     - Deny using Standard and Trial pricing tier.
     - In Premium pricing tier, it's possible to apply role based access control so that there is a difference between standard user and administrator. Using Premium tier, it possible to set-up granular access controls on notebooks, clusters and jobs.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Azure Databricks should allow just Premium pricing tier.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r03
     - Enforce Azure Databricks workspaces to use virtual network injection
     - Azure Virtual Networks provide enhanced security and isolation for your Azure Databricks workspaces, including subnets, access control policies, and other features to further restrict access.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Azure Databricks workspaces should be in an existing virtual network.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r04
     - Deny public IP for Azure Databricks Clusters.
     - Disabling public IP of clusters in Azure Databricks workspaces improves security by ensuring that the clusters aren't exposed on the public internet.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a 'Deny' policy: Azure Databricks Clusters should disable public IP.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r05
     - Automated private link DNS integration.
     - If you use a private link, the DNS setting is automatically configured for the Azure Databricks workspace.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce an auto remediation policy: DNS settings are automatically set on the private link.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r06
     - Enforce encryption of data at rest.
     - To enforce the encryption of data at rest, enable local disk encryption.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce 'Audit' policy: Disk encryption enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r07
     - Restrict Public Key/SSH access to the cluster subnet.
     - Restrict Public Key/SSH access to Databricks cluster nodes for security reasons.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce 'Deny' policy: Databricks subnet's NSGs must not have inbound port open for SSH.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r08
     - Restrict Virtual Network peering for workspaces.
     - Restrict Virtual Network peering for workspaces to protect against network traffic cross-Environments.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce 'Deny' policy: Blocking resource type.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-adb-r09
     - Encryption for data in transit.
     - User queries and transformations are typically sent to your clusters over an encrypted channel. By default, the data exchanged between worker nodes in a cluster isn't encrypted. If your environment requires always encrypted data, whether at rest or in transit, create an init script that configures your clusters to encrypt traffic between worker nodes, using AES 128-bit encryption over a TLS 1.2 connection.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - The enhanced security and compliance add-on covers this.
     - Microsoft Defender for Cloud. Compliant policy that enforces the enablement of this add-on.
   * - drcp-adb-r10
     - Restrict Deprecated versions of Databricks runtimes.
     - Restrict the deprecated versions of Databricks Runtime to improve the security, performance and usability. The Cluster Databricks Runtime version must support Unity Catalog features.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - The enhanced security and compliance add-on covers this.
     - Microsoft Defender for Cloud. Compliant policy that enforces the enablement of this add-on.


These policies are **Databricks account** specific and aren't manageable with Azure Policy:

.. list-table::
   :widths: 5 25 20 5 05 05 05 20 10 20
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
   * - drcp-adb-a01
     - Limit the assignment of Databricks account administrator to specific Microsoft Entra ID group and Microsoft Entra ID service principal.
     - Given the number of privileges a Databricks account administrator role has, limit the account  access to one of the Microsoft Entra ID Service Principals and an Azure LLDC Microsoft Entra ID group.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit the number of Users, Groups and Service Principals having account administrator access.
     - Audit the Users, Groups and Service Principals from the Databricks account console and report on exceptions.
   * - drcp-adb-a02
     - Restrict assignment of Marketplace administrator to no-one.
     - To reduce the risk of data leakage, don't assign the Marketplace administrator role to any User, Group, Service Principal.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit if the role assignment is empty.
     - Audit the empty role assignment and report on exceptions.
   * - drcp-adb-a03
     - Enforce the user provisioning at Databricks account level.
     - Don't add individual Users or Groups, instead provision the users and groups from Microsoft Entra ID using SCIM connector.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit the Databricks account console and make sure that the User Provisioning turned-on.
     - Audit the 'User Provisioning' of Databricks account console and report on exceptions.
   * - drcp-adb-a04
     - Enforce Identity Federation on Databricks workspace.
     - To allow the Databricks workspaces to use the Unity Catalog feature of Identity Federation, at least one metastore must be available.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit the Databricks account console and make sure that at least one metastore exists.
     - Audit the 'Data' section of Databricks account console and report on exceptions.
   * - drcp-adb-a05
     - Enforce IP access list in Databricks account console.
     - Use IP access list to restrict access to Databricks account to specific APG IP addresses or subnets. When the feature is on, it's possible to control the IPs to allow and deny access on account.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit the Databricks account console and make sure an enabled IP access list exists and non-APG Public (gateway) IPs have access denied on account.
     - Audit the 'Security and Compliance' section of Databricks account console and report on exceptions.
   * - drcp-adb-a06
     - Restrict access to web terminal.
     - Restrict all users access to the web terminal, where they can interact with the command line on their all-purpose compute resources.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Audit the Databricks account console feature enablement, web terminal is 'off' (not enforced, since DRCP allows it in DEV usage).
     - Audit the Databricks account console and report on exceptions.
   * - drcp-adb-a07
     - Restrict Azure AI services-powered features.
     - Some AI features rely on Azure AI services. Azure AI services don't access or keep your data, you may need to pass information and context.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Enforce the Databricks account console feature enablement, Azure AI services is 'off'.
     - Audit the Databricks account console and report on exceptions.
   * - drcp-adb-a08
     - Restrict the Delta Sharing.
     - Delta Sharing is an approach to data sharing across data, analytics and AI. To prevent the data leakage, restrict Delta Sharing.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - Enforce that the Delta Sharing is off.
     - Audit the Metastore settings and report on exceptions.
   * - drcp-adb-a09
     - Egress policy for Azure Databricks Network Connectivity Configuration.
     - To prevent data exfiltration, all the Network Connectivity Configurations will adhere to an egress policy which prevents implementation of internal and external (internet included) custom routes.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - Azure LLDC
     - In the Azure Databricks account console, define a network policy which restricts outbound access to all outbound locations.
     - Audit the application of the default egress policy on Network Connectivity Configurations, and report on exceptions.

These policies are **Databricks workspace** specific and aren't manageable with Azure Policy:

.. list-table::
   :widths: 5 25 20 5 05 05 05 20 10 20
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
   * - drcp-adb-w01
     - Restrict the use of local groups in Databricks workspace.
     - Don't use local groups created at Databricks workspace scope, which aren't synced from APGs Microsoft Entra ID.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Identity and Access settings in workspace.
     - Audit the Identity and Access settings in workspace and report on exceptions.
   * - drcp-adb-w02
     - Restrict individual workspace permissions.
     - Because of Databricks SCIM connector, you can assign workspace permissions to synchronized Microsoft Entra ID Users and Groups in your account. Individual users shouldn't have access in Environments, instead grant access to Microsoft Entra ID groups.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit assigning workspace permissions to individual users.
     - Audit the settings of the workspace and report on exceptions.
   * - drcp-adb-w03
     - Use Microsoft Entra ID Service Principals.
     - Restrict the use of local Databricks Service Principals across Databricks, instead use Microsoft Entra ID Service Principals.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the workspace Service Principals in the workspace.
     - Audit the workspace Service Principals in the workspace and report on exceptions.
   * - drcp-adb-w04
     - Restrict workspace administrator access to the environment Service Principal.
     - Workspace administrator gives highest privileged permissions within the workspace. In non-DEV Environments Users and Groups (except for the temporary access Group) shouldn't have the workspace administrator role, but it should be the environment Service Principal to ensure CI/CD workflow.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the User and Administrator settings in the workspace.
     - Audit the User and Administrator settings in the workspace and report on exceptions.
   * - drcp-adb-w05
     - Restrict sharing of Unity-enabled Data Catalogs across workspaces.
     - To prevent data leakage and unintended access to data, scope the Data Catalog to a restricted selection of workspaces. Exceptions are system catalogs and APG catalogs based on system catalogs.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Catalog settings in the workspace.
     - Audit the Catalog settings in the workspace and report on exceptions.
   * - drcp-adb-w08
     - Disable MLflow run artifact download in non-Dev environment.
     - Restrict users from Downloading the MLflow run to prevent information leakage.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Security settings in the workspace.
     - Audit the Security settings in the workspace and report on exceptions.
   * - drcp-adb-w09
     - Use Microsoft Entra ID Authentication for Databricks workspaces in all cases. No use of PAT token in Databricks workspace.
     - A PAT token is less secure than Microsoft Entra ID authentication and therefor don't use it.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit generating PAT tokens.
     - Audit the workspace Advanced settings in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w10
     - Disable DBFS file browser in non-Dev environment.
     - DBFS is ephemeral storage attached to Databricks workspace. Also data stored in DBFS is accessible to all the users in the workspace. The DBFS browser provides visual browser interface to the files to upload and download the files. In non-Dev environment, don't use the DBFS browser feature to prevent unauthorized data access.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the workspace Advanced settings.
     - Audit the workspace Advanced settings in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w11
     - Disable the use of web terminal.
     - Web terminal allows users to run shell commands and use editors, such as Vim or Emacs, on the Spark driver node. It gives developers direct access to the cluster nodes.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps Team
     - Allow use of web terminal in Dev Environments, disallow it in non-Dev Environments.
     - Audit the workspace Compute settings in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w12
     - Disable legacy and non secure features.
     - Restrict users from enabling MLflow Model serving and Databricks AutoLogging features as they're out of the current scope of Databricks configuration in DRCP.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the workspace Advanced settings.
     - Audit the workspace Advanced settings in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w13
     - Disable FileStore endpoint.
     - File store endpoint allows to drop or read file from DBFS. The FileStore endpoint is publicly available and can cause data leakage.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the workspace Advanced settings.
     - Audit the workspace Advanced settings in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w14
     - Restrict Cluster Access Modes without support for isolation and data access controls.
     - Don't use the cluster access modes 'No isolation shared' (Legacy) and Custom, since they don't have Unity Catalog support and isolation between users and data access controls aren't available.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Cluster creation with access modes other than 'Shared' or 'Single User'.
     - Audit the Cluster Configuration in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w15
     - Restrict credentials passthrough for non-Dev Environments.
     - Restrict the usage of credential passthrough as it's a legacy data governance model and Databricks recommends Unity Catalog for better security posture. Credential passthrough allows to user's Microsoft Entra ID credentials to pass through to spark allowing access to data storage.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Cluster Configuration in the Databricks workspaces.
     - Audit the Cluster Configuration in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w16
     - Restrict Git integration to APG Azure DevOps.
     - Don't use other Git providers than the APG Azure DevOps Project in the connectdrcpapg1 organization. Databricks allows Git integration with Git providers such as ADO, GitHub, BitBucket, GitLab, AWS CodeCommit.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Git integration other than ADO organization 'connectdrcpapg1'.
     - Audit the Configuration in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w17
     - Control the use of Azure DevOps Repository in non-DEV Environments.
     - The Databricks Repository feature allows you to move away from data stored just in the Azure Databricks control plane, and instead store data in a Git repository. Only in DEV Environments, it's allowed to use Azure DevOps Repository to store data.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the usage of Git repository in non-Development environment.
     - Audit the Configuration in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w18
     - Control the use of Global Init script.
     - Global init scripts execute on all cluster nodes in the workspace to make them consistent. Using Global Init script can cause undesired impact on clusters. Everyone can view the output of Global Init scripts.
     - L
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Restrict the use of 'Legacy Global Init Scripts' in the Databricks workspaces.
     - Audit the Compute Configuration in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w19
     - Enforce the creation of Storage Credential using Databricks Connector's identity in the same environment/Subscription.
     - To prevent data leakage and unauthorized access to data, restrict the scope of Storage Credential to one workspace. Exceptions are Storage Credentials for APG catalogs based on system catalogs.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the Catalog settings in the workspace.
     - Audit the Catalog settings in the workspace and report on exceptions.
   * - drcp-adb-w20
     - Configure Access Control on the jobs in non-DEV environment.
     - Restrict Users from Creating, Managing and Owning the jobs in non-Development Environments. The (Non CI/CD) Service Principal will own and manage the jobs in non-Development Environments. It makes sure the job/workflow runs aren't depending on users.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the configuration of each Job.
     - Audit the configuration of each Job and report on exceptions.
   * - drcp-adb-w21
     - Configure Access Control on the clusters.
     - Restrict Users from having 'Allow unrestricted cluster creation' entitlement.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the configuration of each Cluster.
     - Audit the configuration of each Cluster and report on exceptions.
   * - drcp-adb-w22
     - Restrict the use of not supported use cases.
     - The :doc:`Databricks Use-cases section <Use-cases>` includes a section of not supported Databricks features. Restrict the use of these not supported features.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the not supported Databricks features.
     - Audit the not supported Databricks features in the Databricks workspaces and report on exceptions.
   * - drcp-adb-w23
     - Enable enhanced security and compliance add-on for workspaces.
     - Enforce enabling the compliance profile which includes automatic updates, hardened images and security agents.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the settings of the workspace.
     - Audit the settings of the workspace and report on exceptions.
   * - drcp-adb-w24
     - Limit workspace to predefined business unit/usage Network Connectivity Configuration.
     - To provide compute network segregation for workspaces, workspaces require a connection from predefined business unit/usage specific Network Connectivity Configuration.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the workspace connected Network Connectivity Configuration.
     - Audit if the workspace's connected Network Connectivity Configuration matches with the predefined business unit/usage specific Network Connectivity Configuration and report on exceptions.
   * - drcp-adb-w25
     - Limit workspace access for external locations, credentials and connections.
     - To prevent implicit data access, the setting ‘All workspaces have access’ should be disabled on external locations, credentials and connections.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the setting ‘All workspaces have access’ on external locations, credentials and connections.
     - Audit the ‘All workspaces have access’ setting on external locations, credentials, connections and report on exceptions.
   * - drcp-adb-w26
     - Limit grants subject 'All users' for catalogs, external locations, credentials and connections.
     - To prevent implicit data access, the subject 'All users' on grants applicable to catalogs, external locations, credentials and connections isn't allowed. Exceptions are system catalogs and APG catalogs based on system catalogs.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the subjects on grants containing subject 'All users' on external locations, credentials and connections
     - Audit the subjects on grants containing subject 'All users' on external locations, credentials, connections and report on exceptions.
   * - drcp-adb-w27
     - Limit external locations' and connections' bindings to their business unit/usage related workspaces.
     - To provide business unit/usage data segregation between workspaces and external locations and connections. External location and connection bindings refer ``strictly`` to their business unit/usage related workspaces.
     - H
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the external locations' and connections' binding references.
     - Audit the external locations' and connections' binding references. These must refer to their business unit/usage related workspaces. Report on exceptions.
   * - drcp-adb-w28
     - Configure Access Control on the pipelines in non-DEV environment.
     - Restrict users from creating, managing and owning the pipelines in non-Development Environments. The (Non CI/CD) Service Principal will own and manage the pipelines in non-Development Environments. It makes sure the pipelines aren't depending on users.
     - M
     - C=1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Audit the configuration of each pipeline.
     - Audit the configuration of each pipeline and report on exceptions.

.. include:: ../../_static/include/security-baseline-footer.txt