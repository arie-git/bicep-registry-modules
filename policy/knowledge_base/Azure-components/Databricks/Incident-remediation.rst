Incident remediation Databricks
===============================

.. |AzureComponent| replace:: Databricks
.. include:: ../../_static/include/incident-remediation-header.txt

Azure policies
^^^^^^^^^^^^^^

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-adb-r01
     - Deny public network access for Azure Databricks workspaces.
     - Disable public network access to the Databricks workspace by configuring the property ``publicNetworkAccess`` to ``Disabled``.

   * - drcp-adb-r02
     - Deny using Standard and Trial pricing tier.
     - Use the Premium pricing tier by configuring the property ``sku`` to ``Premium``.

   * - drcp-adb-r03
     - Enforce Azure Databricks workspaces to use virtual network injection.
     - Ensure that the Databricks workspace uses `VNet injection <https://learn.microsoft.com/en-us/azure/databricks/security/network/classic/private-link-standard>`__.

   * - drcp-adb-r04
     - Deny public IP for Azure Databricks Clusters.
     - Deny public IP by configuring the property ``enableNoPublicIp`` boolean to ``true``.

   * - drcp-adb-r05
     - Automated private link DNS integration.
     - When deploying a private endpoint, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-adb-r06
     - Enforce encryption of data at rest.
     - Enforce encryption of data at rest by configuring the property ``requireInfrastructureEncryption`` boolean to ``true``.

   * - drcp-adb-r07
     - Restrict Public Key/SSH access to the cluster subnet.
     - Restrict Public Key/SSH access to the cluster subnet by enabling enhanced security of Azure Databricks, see drcp-adb-w23.

   * - drcp-adb-r08
     - Restrict Virtual Network peering for workspaces.
     - Make sure that the Virtual Network of the Subscription in which the workspace resides has no other peerings then the peering with the hub, see :doc:`drcp-sub-05 <../Subscription/Incident-remediation>`.

   * - drcp-adb-r09
     - Encryption for data in transit.
     - Encrypt data in transit by enabling enhanced security of Azure Databricks, see drcp-adb-w23.

   * - drcp-adb-r10
     - Restrict deprecated versions of Databricks runtimes.
     - Restrict deprecated versions of Databricks runtimes by enabling enhanced security of Azure Databricks, see drcp-adb-w23.


Account controls
^^^^^^^^^^^^^^^^
The Azure LLDC team manages these baselines.

Workspace controls
^^^^^^^^^^^^^^^^^^

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - drcp-adb-w01
     - Restrict the use of local groups in Databricks Workspace.
     - Enable the workspace with Identity Federation. The workspace contains two default Databricks groups: 'admins' and 'users'. Restrict other Databricks groups in the workspace to Microsoft Entra ID groups. See :ref:`Use-cases-Databricks-Users-and-Groups-label`.

   * - drcp-adb-w02
     - Restrict individual workspace permissions.
     - Enable the workspace with Identity Federation. Make sure every user in the workspace is a member of a Microsoft Entra ID group in the workspace. See :ref:`Use-cases-Databricks-Users-and-Groups-label`.

   * - drcp-adb-w03
     - Use Microsoft Entra ID Service Principals.
     - Enable the workspace with Identity Federation. Make sure every Service Principal in the workspace is a Microsoft Entra ID Service Principal. See :ref:`Use-cases-Databricks-Service-Principals-label`.

   * - drcp-adb-w04
     - Restrict workspace administrator access to the environment Service Principal.
     - Check the members of the 'admins' group. Make sure that the environment Service Principal (``SP-App-<Application system>-<Environment>-ADO-001``) is the sole member of the 'admins' group. See :ref:`Use-cases-Databricks-CI/CD-Service-Principal-label`.

   * - drcp-adb-w05
     - Restrict sharing of Unity-enabled Data Catalogs across workspaces.
     - Don't share the catalog with 'all' workspaces.

   * - drcp-adb-w08
     - Disable MLflow run artifact download in non-Dev environment.
     - Disable 'MLflow run artifact download'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w09
     - Use Microsoft Entra ID Authentication for Databricks workspaces in all cases. No use of PAT token in Databricks workspace.
     - Disable 'Personal Access Tokens'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w10
     - Disable DBFS file browser in non-Dev environment.
     - Disable 'DBFS file browser'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w11
     - Disable the use of web terminal.
     - Disable 'Web terminal'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w12
     - Disable legacy and non secure features.
     - Disable 'Databricks Autologging' and 'Legacy MLflow Model Serving'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w13
     - Disable FileStore endpoint.
     - Disable 'FileStore Endpoint'. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w14
     - Restrict Cluster Access Modes without support for isolation and data access controls.
     - Enable 'Enforce user isolation'. See :ref:`Use-cases-Databricks-Configuring-label`. For every cluster in the workspace, set 'Access mode' to 'USER_ISOLATION' or 'SINGLE_USER'. See :ref:`Use-cases-Databricks-Cluster-policies`.

   * - drcp-adb-w15
     - Restrict credentials passthrough for non-Dev Environments.
     - Don't set the 'Access mode' of clusters to 'LEGACY_SINGLE_USER' or 'LEGACY_PASSTHROUGH'. Don't use a compute policy with ``spark.databricks.passthrough.enabled`` set to true.

   * - drcp-adb-w16
     - Restrict Git integration to APG Azure DevOps.
     - In Environments with usage development, the 'Git URL allow list' may have a link to the Application system project in the 'https://dev.azure.com/connectdrcpapg1/' Azure DevOps organization. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w17
     - Control the use of Azure DevOps Repository in non-DEV Environments.
     - Uncouple repositories from workspaces in non-DEV Environments. See :ref:`Use-cases-Databricks-Configuring-label`.

   * - drcp-adb-w18
     - Control the use of Global Init script.
     - Remove all global init scripts.

   * - drcp-adb-w19
     - Enforce the creation of Storage Credential using Databricks Connector's identity in the same Environment/Subscription.
     - See :ref:`Use-cases-Databricks-Creating-data-catalog`.

   * - drcp-adb-w20
     - Configure access control on the jobs in non-DEV environment.
     - Check the job permissions. Make sure that users and groups have the view permission in Environments other then usage development.

   * - drcp-adb-w21
     - Configure access control on the clusters.
     - Check the cluster permissions. Make sure that users and groups don't have the can manage permission in non-DEV Environments.

   * - drcp-adb-w22
     - Restrict the use of not supported use cases.
     - Remove all pipepines from 'Delta Live Tables'. Don't use 'Serverless' SQL Warehouses. Remove all 'Queries' from the workspace. Remove all 'Dashboards' from the workspace. Remove all 'Alerts' from the workspace. Remove all 'Experiments' from the workspace. Remove all 'Models' from the 'Workspace Model Registry'. Remove all 'Serving Endpoints' from the workspace.

   * - drcp-adb-w23
     - Enable enhanced security and compliance add-on for workspaces.
     - Enable enhanced security of Azure Databricks. Enable the options 'Enable compliance security profile', 'Enable enhanced security monitoring' and 'Enable automatic cluster update'.

   * - drcp-adb-w24
     - Limit workspace to predefined business unit/usage Network Connectivity Configuration.
     - Check the workspaces. Make sure that the workspace uses the Network Connectivity Configuration dedicated to that APG business unit & usage.

   * - drcp-adb-w25
     - Limit workspace access for external locations, credentials and connections.
     - On external locations, credentials and connections. Check the permissions section. Disable the 'All workspaces have access' setting.

   * - drcp-adb-w26
     - Limit grant target subject 'All users' for catalogs, external locations, credentials and connections.
     - On catalogs, external locations, credentials and connections. Check the permissions section. Remove any grant having a target subject of 'All users'.

   * - drcp-adb-w27
     - Limit external locations' and connections' bindings to their business unit/usage related workspaces.
     - On the external locations and connections. Check if the bindings refer to their business unit/usage related workspaces. Remove bindings which don't refer to business unit/usage related workspaces.

   * - drcp-adb-w28
     - Configure access control on the pipelines in non-DEV environment.
     - Check the pipeline permissions. Make sure that users and groups have the view permission in Environments other then usage development.
