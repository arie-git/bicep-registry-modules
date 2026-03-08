Security baseline Azure DevOps
===================================

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
     - January 23, 2023
     - Onno Hettema
     - Initial version.


.. |AzureComponent| replace:: Azure DevOps
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 12 20 25 05 05 15 20 20 15 10
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
   * - drcp-ado-01
     - Org policy: Disallow public projects.
     - APG just allows private projects. Public projects give anonymous access to a project and APG source code. Private projects allow authenticated and authorized users access to an APG ADO project.
     - H
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-02
     - Org policy: Enable protections when using public package registries.
     - This provides security for private feeds in Azure Artifacts by limiting access to externally sourced packages when internally sourced packages are already present. This provides a new layer of security, which prevents malicious packages from a public registry being inadvertently consumed.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-03
     - Project policy: Commit author email validation.
     - Before every code commit, Azure DevOps performs a check if the email address of the author belongs to APG.
     - L
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Inspec output stored in ServiceNow on Application system level.
   * - drcp-ado-04
     - Project policy: Require a minimum number of reviewers for a pull request.
     - A peer review is an appropriate method for removing unintentional (or intentional) errors from software. Furthermore a review process supports quality improvement.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DevOps team
     - Azure DevOps audit log.
     - Inspec output stored in ServiceNow on Application system level.
   * - drcp-ado-05
     - Org policy: Don't allow external guest access.
     - The integrity and security of external guest accounts aren't guaranteed by APG. Only APG Microsoft Entra ID accounts should be able to get access to an ADO project, based on group membership, managed by IAM.
     - H
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-06
     - Org policy: Don't allow team and project administrators to invite new users.
     - The IAM system should manage user access to Azure DevOps by using Microsoft Entra ID groups to give certain roles access to an Azure DevOps project. Single users shouldn't get access to Azure DevOps directly.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-07
     - Org and project policy: Microsoft Entra ID groups, managed by IAM, get permissions in ADO. Individual users shouldn't have permissions in an APG ADO project.
     - Because ADO has a link to Microsoft Entra ID, you can assign permissions to Microsoft Entra ID groups. Individual users shouldn't have access in ADO projects or ADO organizations, instead grant access to Microsoft Entra ID groups which IAM controls.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Inspec output stored in ServiceNow on Application system level and DevSupport/DRCP level.
   * - drcp-ado-08
     - Org policy: Don't provide a URL to request access to an ADO organization.
     - The IAM system should grant access to certain Azure DevOps roles. This URL can grant access to individual users and therefor it's disabled.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-09
     - Org policy: Enable Microsoft Entra ID Conditional Access Policy Validation.
     - If you sign in to the web portal of a Microsoft Entra ID-backed organization, Microsoft Entra ID checks that you can move forward by performing validation for any CAPs that tenant administrators set. Azure DevOps can also perform more CAP validation once you're signed in and navigating through Azure DevOps. If the Enable Microsoft Entra ID CAP validation policy sets to enabled, web flows are 100% honored for all conditional access policies. If the policy sets to disabled, Azure DevOps doesn't perform more CAP validation, but Microsoft Entra ID always checks for CAPs upon sign-in.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-10
     - Org policy: Enable application access via OAuth.
     - All the REST APIs accept OAuth tokens and this is the preferred method of integration over personal access tokens (PATs). The Organizations, Profiles, and PAT Management APIs just support OAuth. Required for DRCP Automation when OAuth tokens replace the PAT tokens.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.
   * - drcp-ado-11
     - Org policy: Enable Log Audit Events and stream them to Log Analytics for long term retention and security monitoring.
     - To meet APG compliance- and governance goals, the changes in the Azure DevOps organizations need tracking and logging. Audit changes occur whenever a user or service identity within the organization edits the state of an artifact. This can be changing permissions, changing agent pools, changing policy or security settings, etc.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Audit logs stream to Log Analytics for long term retention.'
   * - drcp-ado-12
     - Project policy: An automated change process is in place by using required template for pipelines.
     - Registering changes provides a control on the process of change and traceability back to the person making the change. With such a central registration APG prevents misuse and the quality of the change process improves. A required template in ADO enforces the creation of changes for every deployment pipeline run.
     - M
     - C = 0/3
     - PO Development Support
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - DRCP (for Landing zone 3) and DevSupport (for other Landing zones)
     - Azure DevOps audit log.
     - Inspec output stored in ServiceNow on Application system level.


.. include:: ../../_static/include/security-baseline-footer.txt