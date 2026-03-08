Quick actions
=============

Available Quick actions
-----------------------

The following Quick actions are available:

.. list-table::
   :widths: 10 10 10 40 20
   :header-rows: 1

   * - Name
     - Short description
     - Component
     - Description
     - Notes
   * - Refresh Environment
     - Quick: refresh Environment
     - Environment
     - The refresh of an Environment reapplies all settings to the DRCP standard. Azure policies, set by DRCP on Subscription scope, will reapply as part of this action. This action automatically runs during the configured maintenance window.
     -
   * - Remove Environment
     - Quick: remove Environment
     - Environment
     - This Quick action removes an Environment. The manual removal of Azure resources within the Environment's Subscription is mandatory, before the ServiceNow workflow is able to proceed.
     - .. warning:: The removal of an Environment is irreversible and may lead to data loss!
   * - Change maintenance details
     - Quick: change Environment maintenance details
     - Environment
     - The Quick action "Change maintenance details" allows the user to change the maintenance day and time of the Environment.
     -
   * - Set allowed usage
     - Quick: request an allowed usage for an Application system
     - Application system
     - When creating a new Environment within an Application system you have to set the usage for that Environment. The usage is one of *development*, *test*, *acceptance* or *production*. By default new Application systems allow ``only`` development Environments. The :doc:`onboarding process <../../Getting-started/Onboarding-process>` enables the other DTAP phases when the application and team are ready. When this is the case, this Quick action allows the user to request access to a new usage for an Application system. This request requires an approval of the BU CCC.
     -
   * - Enable Mule
     - Quick: Enable Mule
     - Application system
     - The Quick action "Enable Mule" allows the user enable Mule APIs for an Application system.
     -
   * - Refresh Landing zone 3
     - Quick: Refresh Landing zone 3
     - Application system
     - The refresh of an Application system reapplies all settings to the DRCP standard. For example the Azure DevOps project settings.
     -
   * - Run automated controls for LZ3
     - Quick: Run automated controls for LZ3
     - Application system and Environment
     - Running automated controls tests if an Application system or Environment complies with the security baselines. Results are visible in the DRDC portal and failed baselines result in incidents.
     -
   * - Add Private Link Service id
     - Quick: Add Private Link Service id
     - Application system
     - By default, DRCP restricts the use of `private endpoints/links <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource>`__ to resources in the scope of the Subscription in which the private endpoint/link deploys (see control ``drcp-sub-07`` in the :doc:`Subscription security baseline <../../Azure-components/Subscription/Subscription-Baseline>`. Use this Quick action to add an exception for a specific private link service id.
     - .. note:: Enter the Subscription ID or the full alias (example: ``westeurope-prod-001-privatelink-service.190cd496-6d79-4ee2-8f23-0667fd5a8ec1.westeurope.azure.privatelinkservice``) when connecting to a 3rd party vendor (such as Confluent Cloud or Elastic Cloud). Also enter the required DNS dns zone in the field **DNS zone** (if applicable, this creates a task for the Azure LLDC team). Each entry requires a separate request.
       .. note:: After submitting the form, the ServiceNow workflow creates approval requests for IRSO, security consultants and DRCP. From each group, one member needs to approve to complete the request.
       .. note:: After the approval flow succeeds, each Environment containing the private endpoint/link needs to refresh (see Quick action: **Refresh Environment**) to ensure policy compliance. This can take up to 20 minutes.
       .. note:: Improvement of this process is under construction in `SAA-7462 <https://jira.office01.internalcorp.net:8443/browse/SAA-7462>`__
   * - Enable resource provider
     - Quick: Enable resource provider
     - Application system
     - Enable a new Azure resource provider for the Application system.
     -
   * - Request support access for LZ3
     - Quick: Request support access for LZ3
     - Environment
     - Enables support access for InSpark for the Environment. An InSpark ticket number is mandatory to activate the support access.
     - Learn more on the :doc:`Need help <../../Need-help>` page under `InSpark / Microsoft support`.
       .. warning:: Revoke the support access by closing the assigned task under the request in ServiceNow once you InSpark / Microsoft support has resolved the ticket.
   * - Add VNet address space
     - Quick: Add VNet address space
     - Environment
     - Select a VNet address space with selected size to add to your Environment. Then, ServiceNow performs a refresh of your Environment to apply changes.
     - .. note:: You may add 2 more address spaces.
   * - Remove VNet address space
     - Quick: Remove VNet address space
     - Environment
     - Select a VNet address space to remove from your Environment. Then, ServiceNow performs a refresh of your Environment to apply changes.
     -
   * - Manage Databricks Workspace registration
     - Quick: Manage Databricks Workspace
     - Environment
     - Select a Databricks Workspace from your Environment to register it in Unity Catalog, set privileges and register serverless compute.
     - .. note:: Business units that don't have a network connectivity configuration defined for that Environment specific usage won't have that Databricks Workspace automatically registered with serverless compute.
   * - Upgrade security context ADO Principal
     - Quick: Upgrade security context ADO Principal
     - Environment
     - Use this Quick action to add the Azure DevOps deployment principal (for example ``SP-App-DEMOAS-ENV12345-ADO-001``) to the corresponding Entra ID location binding group.
     - .. note:: These groups restrict the principal source IP address to the APG Azure network.

Approvals
---------

For more information about approval see the :doc:`Approval overview <Approval-overview>` page.
