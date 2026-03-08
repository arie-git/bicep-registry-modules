Roles and authorizations
========================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
------------

Role Based Access Control (RBAC) is the method to provide access to Application systems at APG. The `IAM system of APG <https://cloudapg.sharepoint.com/sites/IAM-APG-EN>`__ manages these authorizations via roles and entitlements. This system also controls access to the DRCP platform.
When the DRCP platform creates a new Application system (AS), the following roles become available in the IAM system.

.. note:: This page lists the IAM roles related to the DRCP platform, which always contain the term 'DRCP', for example in 'TR-DRCP-<AS>_engineer'. Other platforms are out of scope for this documentation.

.. list-table::
   :widths: 40 100
   :header-rows: 1

   *  - IAM Role
      - Description
   *  - TR-DRCP_<AS>_reader
      - This DRCP role grants Reader access to all resources within the Application system, but not to Environments with usage Production.
   *  - TR-DRCP_<AS>_user
      - This DRCP role grants Contributor permissions in the Azure DevOps <AS> project.
   *  - TR-DRCP_<AS>_engineer
      - This DRCP role grants Engineer access to all resources within the Application system.
   *  - TR-DRCP_<AS>_acceptanceapprover
      - This DRCP role grants Reader and Acceptance Approver permissions in the Azure DevOps <AS> project.
   *  - TR-DRCP_<AS>_productionapprover
      - This DRCP role grants Reader and Production Approver permissions in the Azure DevOps <AS> project.
   *  - TR-DRCP_<AS>_releasemanager
      - This DRCP role grants Reader role and Release Manager permissions in the Azure DevOps <AS> project.
   *  - TR-DRCP_<AS>_productionreader
      - This DRCP role grants Reader access to all Environments with usage Production within the Application system after Just In Time (JIT) activation of the Privileged Identity Management (PIM) for Groups activation.
   *  - TR-DRCP_<AS>_productionoperator
      - This DRCP role grants Reader access to all Environments with usage Production within the Application system after Just In Time (JIT) activation of the Privileged Identity Management (PIM) for Groups activation, but has assignable roles.
   *  - TR-DRCP_<AS>_productionengineer
      - This DRCP role grants Engineer access to all Environments with usage Production within the Application system after Just In Time (JIT) activation of the Privileged Identity Management (PIM) for Groups activation.
   *  - TR-DRCP_<AS>_tempaccess
      - This DRCP role grants temporary access in the Azure DevOps <AS> project after Just In Time (JIT) activation of the Privileged Identity Management (PIM) for Groups activation.
   *  - TR-\ **ITPS-Approval**\ _Approval <AS>
      - This DRDC role grants Approver access in ServiceNow within the <AS> on Environment requests.

ServiceNow authorizations
-------------------------

Overview of the ServiceNow authorizations assigned to the IAM roles.
See the ServiceNow permissions section below for an explanation of ServiceNow groups.

.. list-table::
   :widths: 40 100 30
   :header-rows: 1

   *  - IAM Role
      - ServiceNow authorizations
      - ServiceNow group
   *  - TR-DRCP_<AS>_reader
      - View Environments, but doesn't allow you to make any changes. Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_user
      - Gives access to use the ServiceNow portal for managing Environments. Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_engineer
      - Gives access to use the ServiceNow portal for managing Environments. Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_acceptanceapprover
      - Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_productionapprover
      - Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_releasemanager
      - Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_productionreader
      - Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_productionoperator
      - Approve Application system requests.
      - <AS>
   *  - TR-DRCP_<AS>_tempaccess
      - Approve Application system requests.
      - <AS>
   *  - TR-\ **ITPS-Approval**\ _Approval <AS>
      - Necessary approval in ServiceNow given by users in this group, like assigning temporary access, or removing an Environment.
      - <AS>_Approval


ServiceNow permissions
^^^^^^^^^^^^^^^^^^^^^^

Overview of the ServiceNow groups and their permissions. The permission ``itil`` gives standard access entitlements to ServiceNow.

.. list-table::
   :widths: 40 100 30
   :header-rows: 1

   *  - ServiceNow group
      - Description
      - Permissions
   *  - <AS>
      - Also called the support group for assigning tickets and approving Application system request like ``Mule enable`` or ``Request temporary access Application system (LZ3)``.
      - ``itil``
   *  - <AS>_Approval
      - Group for approving ServiceNow Environment request.
      - ``itil``


Azure DevOps authorizations
---------------------------

Overview of the IAM roles and their mapping to the Azure DevOps default security groups.
For more information about the DRCP-Templates and S01-App-MULE-Templates, see the section :doc:`required pipeline templates <../Application-development/Azure-devops/Required-pipeline-templates>`.

.. list-table::
   :widths: 20 45 15 10 10
   :header-rows: 1

   *  - IAM Role
      - Azure DevOps authorizations
      - <AS> project role
      - DRCP-Templates project role
      - S01-App-MULE-Templates project role
   *  - TR-DRCP_<AS>_reader
      - This role gives permission to read code, pipelines, and status information, but a user with just this role can't change anything in the project.
      - Readers
      -
      -
   *  - TR-DRCP_<AS>_user
      - Has the Azure DevOps default Contributor role in the project. This role gives permission to manage code, create pull requests and run pipelines, but not to manage pipelines, repositories, permissions and policies.
      - Contributors
      -
      -
   *  - TR-DRCP_<AS>_engineer
      - Has an APG custom role with the highest permissions in the project (within APG boundaries). This role gives permission to manage pipelines, repositories, code and variables, but not to manage permissions and default repository policies.
      -  | APG Engineers
         | Build Administrators
         | Contributors
      - Readers
      - Readers
   *  - TR-DRCP_<AS>_acceptanceapprover
      - Needs to approve every deployment to an acceptance Environment.
      - Readers
      -
      -
   *  - TR-DRCP_<AS>_productionapprover
      - Needs to approve every deployment to a production Environment.
      - Readers
      -
      -
   *  - TR-DRCP_<AS>_releasemanager
      - The second approver for every deployment to a production Environment.
      - Readers
      -
      -

   *  - TR-DRCP_<AS>_tempaccess
      - .. warning:: By default, has no permissions. After elevation, no approval neeeded, these permissions apply:

         - To change (policies for) service connections
         - To circumvent the 4-eyes principle (pull requests) for the branches.
         - To approve deployment to acceptance and production Environments.

      - APG Temporary Access
      -
      -

Azure DevOps project roles
^^^^^^^^^^^^^^^^^^^^^^^^^^

Overview of the IAM roles and their Azure DevOps role on Environments, libraries, and service endpoints.
Look for more detailed information on the Azure DevOps roles in `Default permissions quick reference <https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions-access?view=azure-devops>`__.

.. list-table::
   :widths: 40 10 10 10
   :header-rows: 1

   *  - IAM Role
      - Environment
      - Library
      - Service connection
   *  - TR-DRCP_<AS>_reader
      -
      -
      - Reader
   *  - TR-DRCP_<AS>_user
      - User
      - Creator
      - User
   *  - TR-DRCP_<AS>_engineer
      - Creator
      - Administrator
      -  | Administrator
         | User (only for SC-<AS>-<ENV>)
   *  - TR-DRCP_<AS>_acceptanceapprover
      -
      -
      - Reader
   *  - TR-DRCP_<AS>_productionapprover
      -
      -
      - Reader
   *  - TR-DRCP_<AS>_releasemanager
      -
      -
      - Reader
   *  - TR-DRCP_<AS>_tempaccess
      -
      - Administrator
      -  | Administrator
         | User (only for SC-<AS>-<ENV>)


Azure DevOps project permissions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Overview of the IAM roles and their specific permissions on the project.

.. list-table::
   :widths: 5 15 15 15 15 20 20 20 20
   :header-rows: 1

   *  - DevOps
      - Project permissions
      - TR-DRCP_<AS>_reader
      - TR-DRCP_<AS>_user
      - TR-DRCP_<AS>_engineer
      - TR-DRCP_<AS>_acceptanceapprover
      - TR-DRCP_<AS>_productionapprover
      - TR-DRCP_<AS>_releasemanager
      - TR-DRCP_<AS>_tempaccess
   *  - General
      -
      -
      -
      -
      -
      -
      -
      -
   *  -
      - Delete this node
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - Edit this node
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - Manage project properties
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Rename team project
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - Suppress notifications for work item updates
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - Update project visibility
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - View permissions for this node
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
   *  - Boards
      -
      -
      -
      -
      -
      -
      -
      -
   *  -
      - Bypass rules on work item updates
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Change process of team project
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Create tag definition
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Delete and restore work items
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Move work items out of this project
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  -
      - Permanently delete work items
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Analytics
      -
      -
      -
      -
      -
      -
      -
      -
   *  -
      - Delete shared Analytics views
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - Edit shared Analytics views
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  -
      - View analytics
      - Allow (inherited)
      - Allow (inherited)
      - Allow (inherited)
      - Allow (inherited)
      - Allow (inherited)
      - Allow (inherited)
      - Allow (inherited)


Azure DevOps repository permissions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Overview of the IAM roles and their specific permissions on the repositories.

.. list-table::
   :widths: 20 15 15 15 20 20 20 15
   :header-rows: 1

   *  - DevOps repository permissions
      - TR-DRCP_<AS>_reader
      - TR-DRCP_<AS>_user
      - TR-DRCP_<AS>_engineer
      - TR-DRCP_<AS>_acceptanceapprover
      - TR-DRCP_<AS>_productionapprover
      - TR-DRCP_<AS>_releasemanager
      - TR-DRCP_<AS>_tempaccess
   *  - Advanced Security: manage and dismiss alerts
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  - Advanced Security: manage settings
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  - Advanced Security: view alerts
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  - Bypass policies when completing pull requests
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Bypass policies when pushing
      - Not set
      - Not set
      - Deny
      - Not set
      - Not set
      - Not set
      - Deny
   *  - Contribute
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Contribute to pull requests
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
   *  - Create branch
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Create repository
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Create tag
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Delete or disable repository
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Edit policy
      - Not set
      - Not set
      - Deny
      - Not set
      - Not set
      - Not set
      - Deny
   *  - Force push (rewrite history, delete branches and tags)
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Manage notes
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Manage permissions
      - Not set
      - Not set
      - Deny
      - Not set
      - Not set
      - Not set
      - Deny
   *  - Read
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
   *  - Remove others' locks
      - Not set
      - Not set
      - Deny
      - Not set
      - Not set
      - Not set
      - Deny
   *  - Rename repository
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow


Azure DevOps pipeline permissions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Overview of the Azure DevOps teams and their specific permissions on the pipelines.

.. list-table::
   :widths: 20 15 15 15 20 20 20 15
   :header-rows: 1

   *  - DevOps repository permissions
      - TR-DRCP_<AS>_reader
      - TR-DRCP_<AS>_user
      - TR-DRCP_<AS>_engineer
      - TR-DRCP_<AS>_acceptanceapprover
      - TR-DRCP_<AS>_productionapprover
      - TR-DRCP_<AS>_releasemanager
      - TR-DRCP_<AS>_tempaccess
   *  - Administer build permissions
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Not set
   *  - Create build pipeline
      - Not set
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
   *  - Delete build pipeline
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Delete builds
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Destroy builds
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Edit build quality
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Edit queue build configuration
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Manage build qualities
      - Not set
      - Not set
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Override check-in validation by build
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
      - Not set
   *  - Queue builds
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - ``Retain`` indefinitely
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Stop builds
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - Update build information
      - Not set
      - Allow
      - Allow
      - Not set
      - Not set
      - Not set
      - Allow
   *  - View build pipeline
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
   *  - View builds
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow
      - Allow


Azure Portal authorizations
---------------------------

Overview of the Azure roles assigned to the IAM roles.

.. list-table::
   :widths: 15 20 10 10 10 10 10 50
   :header-rows: 1

   *  - IAM Role
      - Azure Portal authorizations
      - Development
      - Test
      - Test (PIM)
      - Acceptance
      - Acceptance (PIM)
      - Production (PIM)
   *  - TR-DRCP_<AS>_reader
      - View all resources, but doesn't allow you to make any changes.
      - Reader
      - Reader
      -
      - Reader
      -
      -
   *  - TR-DRCP_<AS>_engineer
      - Gives `APG Custom - DRCP - Contributor (FP-MG) - DEV` role on development Environment and Reader role on test and acceptance Environments.
      -  APG Custom - DRCP - Contributor (FP-MG) - DEV
      -  Reader
      -  APG Custom - DRCP - Contributor (FP-MG) - TST

         .. warning:: Approval by one of the other Engineers.
      -  Reader
      -  APG Custom - DRCP - Contributor (FP-MG) - ACC

         .. warning:: Approval by one of the other Engineers.
      -
   *  - TR-DRCP_<AS>_productionreader
      - Gives Reader role on production Environments.
      -
      -
      -
      -
      -
      -  Reader

         .. warning:: No Approval needed.
   *  - TR-DRCP_<AS>_productionoperator
      - Gives Reader role on production Environments and has assignable Azure roles if needed.
      -
      -
      -
      -
      -
      -  | Reader
         | Assignable:

         * Azure Event Hubs Data Receiver
         * Azure Event Hubs Data Sender
         * Azure Kubernetes Service RBAC Reader
         * App Configuration Data Reader
         * Container Registry Repository Reader
         * Storage Blob Data Reader
         * Storage Blob Data Owner

         .. note:: You can assign these Azure roles to the ``F-DRCP-<Application system>-<Environment>-Operator-Privileged-001-ASG`` group using the Azure DevOps service connection.
         .. warning:: Approval by one of:

            * product owner
            * other Production Operators
   *  - TR-DRCP_<AS>_productionengineer
      - Gives eligibility for `APG Custom - DRCP - Contributor (FP-MG) - TST/ACC/PRD` role on test/acceptance/production Environments.
      -
      -
      -
      -
      -
      -  APG Custom - DRCP - Contributor (FP-MG) - PRD

         .. warning:: Approval by one of:

            * product owner
            * ICT Operating & Control
            * BU-CCC member

.. note:: Privileged Azure roles need activation through `Privileged Identity Management (PIM) <https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ActivationMenuBlade/~/aadgroup>`__ .

Azure roles
^^^^^^^^^^^

Overview of the permissions per used Azure role.

.. list-table::
   :widths: 30 50 50 100
   :header-rows: 1

   *  - Azure role
      - Description
      - Actions
      - NotActions
   *  - Reader
      - View all resources, but doesn't allow you to make any changes.
      - ``*/read``
      -

   *  - APG Custom - DRCP - Contributor (FP-MG) - DEV/TST/ACC
      - This role is a custom contributor which disables the management of resource providers and specific security settings. The table below shows the specific permissions to this role. Allows for SQL backup deletion.
      - ``*``
      -  | ``Microsoft.Compute/galleries/share/action``
         | ``Microsoft.Security/unregister/action``
         | ``Microsoft.Security/policies/write``
         | ``Microsoft.Authorization/classicAdministrators/*``
         | ``Microsoft.Authorization/policyExemptions/delete``
         | ``Microsoft.Authorization/policyExemptions/write``
         | ``Microsoft.Authorization/policySetDefinitions/delete``
         | ``Microsoft.Authorization/policySetDefinitions/write``
         | ``Microsoft.Authorization/policyDefinitions/delete``
         | ``Microsoft.Authorization/policyDefinitions/write``
         | ``Microsoft.Authorization/policyAssignments/delete``
         | ``Microsoft.Authorization/policyAssignments/write``
         | ``Microsoft.Authorization/policyAssignments/exempt/action``
         | ``Microsoft.Authorization/roleDefinitions/*``
         | ``Microsoft.Security/pricings/delete``,
         | ``Microsoft.Security/pricings/write``,
         | ``Microsoft.Security/securityContacts/delete``
         | ``Microsoft.Security/securityContacts/write``
         | ``Microsoft.Features/featureProviders/subscriptionFeatureRegistrations/delete``
         | ``Microsoft.Features/featureProviders/subscriptionFeatureRegistrations/write``
         | ``Microsoft.Features/providers/features/register/action``
         | ``Microsoft.Features/providers/features/unregister/action``
         | ``Microsoft.ClassicCompute/*``
         | ``Microsoft.ClassicNetwork/*``
         | ``Microsoft.ClassicStorage/*``
         | ``Microsoft.Insights/Components/ApiKeys/Action``
         | ``Microsoft.Subscription/rename/action``

   *  - APG Custom - DRCP - Contributor (FP-MG) - PRD
      - This role is a custom contributor which disables the management of resource providers and specific security settings. The table below shows the specific permissions to this role. Doesn't allow for SQL backup deletion.
      - ``*``
      -  | ``Microsoft.Compute/galleries/share/action``
         | ``Microsoft.Security/unregister/action``
         | ``Microsoft.Security/policies/write``
         | ``Microsoft.Authorization/classicAdministrators/*``
         | ``Microsoft.Authorization/policyExemptions/delete``
         | ``Microsoft.Authorization/policyExemptions/write``
         | ``Microsoft.Authorization/policySetDefinitions/delete``
         | ``Microsoft.Authorization/policySetDefinitions/write``
         | ``Microsoft.Authorization/policyDefinitions/delete``
         | ``Microsoft.Authorization/policyDefinitions/write``
         | ``Microsoft.Authorization/policyAssignments/delete``
         | ``Microsoft.Authorization/policyAssignments/write``
         | ``Microsoft.Authorization/policyAssignments/exempt/action``
         | ``Microsoft.Authorization/roleDefinitions/*``
         | ``Microsoft.Security/pricings/delete``,
         | ``Microsoft.Security/pricings/write``,
         | ``Microsoft.Security/securityContacts/delete``
         | ``Microsoft.Security/securityContacts/write``
         | ``Microsoft.Features/featureProviders/subscriptionFeatureRegistrations/delete``
         | ``Microsoft.Features/featureProviders/subscriptionFeatureRegistrations/write``
         | ``Microsoft.Features/providers/features/register/action``
         | ``Microsoft.Features/providers/features/unregister/action``
         | ``Microsoft.ClassicCompute/*``
         | ``Microsoft.ClassicNetwork/*``
         | ``Microsoft.ClassicStorage/*``
         | ``Microsoft.Insights/Components/ApiKeys/Action``
         | ``Microsoft.Subscription/rename/action``
         | ``Microsoft.Sql/locations/longTermRetentionServers/longTermRetentionDatabases/longTermRetentionBackups/delete``

Temporary access
----------------

.. warning:: Use temporary access in case of incidents. If this is part of your regular development or release workflow, you should contact your CCC for advice.

You can request temporary access on two different levels:

- On an Application system to gain elevated permissions in Azure DevOps, or:
- On an Environment to gain elevated permissions to a Subscription in the Azure portal.

   .. note:: With direct administrative access to the Environment, be aware of manual change risks and take responsibility for any issues caused.

Privileged Identity Management
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The preceding described roles give access to the Application system or Environment. You can elevated to privileged roles or permissions either on Application system or Environment, depending on the usage.
For access to these privliged roles in Azure, Privileged Identity Management (PIM) for groups. Follow the instructions to `Activate your group membership in Privileged Identity Management <https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/groups-activate-roles>`__.

The activation of these privileged roles and permissions require Azure Multi Factor Authorization (MFA) and some information:
   - a `Ticket system` (that's Jira, ServiceNow).
   - a `Ticket number` (that's story number, incident or change number).
   - a `Reason`.

Next, the request might need approval by one of these:
   - The product owner.
   - Another member of the role you activate.
      .. note:: You cann't approve your own request within Azure PIM for groups.
   - ICT Operating & Control
      .. warning:: ICT Operating & Control will approve your request during standby when the standby manager instructs them to do. Standby times range from 16:00 till 8:00 on workingdays and weekends.
   - BU-CCC member
      .. warning:: BU-CCC member will approve your request in absense of the PO and during office hours.

For the required approvals see the preceding tables.