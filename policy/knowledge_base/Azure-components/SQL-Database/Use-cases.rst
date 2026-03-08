Use cases SQL Database
======================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. warning:: Limited :doc:`Azure Availability Zones support <../../Platform/Azure-availability-zones-support>` applies.

Azure SQL Database
------------------
| This article applies to the DRCP enabled component Azure SQL Database and the corresponding Azure SQL Database Server.
| With Azure SQL Database, you can create a highly available and high-performance data storage layer for the applications and solutions in Azure.
| Azure SQL Database is ideal for modern cloud applications because it processes both relational data and non-relational structures like graphs, JSON, spatial, and XML.

DRCP recommends its use because it:

- Manages database functions like upgrading, patching, backups, and monitoring automatically.
- Keeps the Azure SQL Server database engine and OS on the latest stable version with high availability.

Since APG policy requires the use of private endpoints for Azure SQL Databases, DevOps teams must choose a SKU that supports private endpoints.

Keep in mind that the following sub-components are out of scope and not enabled by DRCP:

   - Azure SQL Managed instance;
   - Azure database PostgreSQL (PostgreSQL is available via :doc:`Azure Database for PostgreSQL flexible server <../PostgreSQL/Use-cases>`);
   - Azure database MySQL;
   - Azure Synapse Analytics;
   - SQL Server on Azure VM;
   - And any other sub-components recent added by Microsoft.

Keep in mind that the following Azure SQL features are out of scope and not enabled nor supported by DRCP:

   - Database watcher for Azure SQL (in preview);
   - Elastic jobs (due to security constraints);
   - Elastic queries (no Microsoft Entra ID support) (in preview);
   - Microsoft Entra ID server principal;
   - Import and Export using Private Link (in preview);
   - SQL Analytics (in preview);
   - SQL Database emulator (in preview);
   - SQL Server DNS aliases;
   - SQL Server Database Sync Groups;
   - SQL Server Job Agents;
   - And any other Azure SQL feature recent added by Microsoft.

Use cases and follow-up
-----------------------

Separate databases per environment
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
A `best practice <https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice?view=azuresql-db#implement-separation-of-duties>`__ from Microsoft is to use separate databases per application per environment. This helps to not share secrets across environments and regions and reduces the threat in case of a breach.

**Follow-up**:
| DRCP requires DevOps teams not to use one database across more than one environment within the same Application system.
| To create security boundaries for data, DRCP requires a separate database per environment. Grouping environment data into the same database increases the blast radius of a security event because attackers might be able to access (sensitive) data from more than one environment.


Authentication
^^^^^^^^^^^^^^
When accessing Azure SQL Database, clients must authenticate themselves to the service.

**Follow up:**
DRCP requires `Microsoft Entra ID <https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice?view=azuresql-db#central-management-for-identities>`__ authentication to achieve one method with central management for every DevOps team.

DRCP advises to use managed identities for the Azure SQL Database itself when it needs to authenticate to another service. DevOps teams can choose between system-assigned or user-assigned managed identity, depending on their needs.

- System-assigned has the lifecycle of the associated SQL Database and gets deleted when the database gets deleted.
- User-assigned has its own lifecycle and is reusable when a database gets deleted and redeployed.

To enable the authentication of users, the managed identity of the SQL Database needs the Microsoft Entra ID Directory Reader role and Graph permission :code:`User.Read.All`.
A DRCP API is available for assigning the Directory Reader role to managed identities, see :doc:`Assign role <../../Platform/DRCP-API/Endpoint-for-role-assignment>`.

Authorization
^^^^^^^^^^^^^
An Azure SQL Database `offers RBAC roles <https://learn.microsoft.com/en-us/azure/azure-sql/database/security-best-practice?view=azuresql-db#access-management>`__.

**Follow-up:**
DRCP requires Microsoft Entra ID and its the recommended authorization system for the data plane, and management plane. It has advantages:

- Centralizes access management for administrators and users.
- `Deny assignments <https://learn.microsoft.com/en-us/azure/role-based-access-control/deny-assignments>`__ - ability to exclude security principals at a particular scope.
- Integration with Privileged Identity Management for just-in-time access control.

By utilizing Azure RBAC for all other enabled components, DRCP achieves a standard way of granting privileges on building blocks.

**Adding users in groups to assign roles**

| DRCP provides DevOps teams the flexibility to manage and grant RBAC roles to assign permissions which are database specific.
| Assign access rights to resources to Microsoft Entra ID principals via group assignment. Create Microsoft Entra ID groups, grant access to groups, and add individual members to the groups through IAM.
| In your database, create contained database users that map your Microsoft Entra ID groups.
| To assign permissions inside the database, put the users associated with your groups in database roles with the appropriate permissions.
| See the articles, `Configure and manage Microsoft Entra ID authentication with SQL <https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-configure?view=azuresql-db>`__ and `Use Microsoft Entra ID for authentication with SQL <https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview?view=azuresql-db>`__.

**Microsoft Entra ID Administrator**

A DevOps team must have one Microsoft Entra ID Administrator for SQL, who owns the database. Assigning the Azure DevOps deployment service principal as the Microsoft Entra ID Administrator is best practice, enabling database deployments and configurations from the Azure DevOps project.

For more information on granting Microsoft Entra ID groups certain permissions on the Azure SQL Database, see `this article <https://learn.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-overview?view=azuresql-db#permissions>`__.

**Privileged roles using Azure Privileged Identity Management**

| The roles ``SQL DB Contributor`` and ``SQL Server Contributor`` give privileged Azure SQL access. To prevent misuse, these roles can be solely assigned to the DRCP environment engineer privileged group (for example ``F-DRCP-<AS>-<ENV>-Enigneer-Privileged-001-ASG``) in usages Test, Acceptance, and Production.

| For usage DEV it's also possible to assign the roles to the DRCP environment engineer group (for example ``F-DRCP-<AS>-<ENV>-Engineer-001-ASG``).
| It's recommended to use the ADO service principal (for example ``SP-App-<AS>-<AS>-ADO-001``) for these privileged SQL DB tasks and just use the DRCP environment engineer privileged group (``F-DRCP-<AS>-<ENV>-Engineer-Privileged-001-ASG``) in case of emergency or for troubleshooting.

Data protection and back-up
^^^^^^^^^^^^^^^^^^^^^^^^^^^
In certain conceivable scenarios, a user may inadvertently delete a database or data inside a database. If that database or data were to be recoverable for a predetermined period, the user may undo the deletion and recover their data.

In a different scenario, a rogue user may attempt to delete a database or data inside a database, to cause a business disruption.

To limit these risks, automated backups can help to recover.
`More information about the automated backups <https://learn.microsoft.com/en-us/azure/azure-sql/database/automated-backups-overview?view=azuresql-db>`__.

| In Environments with usage 'Production', deletion holds on SQL long-term retention (LTR) backups:
| When you remove a production Environment that holds on a SQL (LTR) backup, the system generates an error message indicating `The Environment isn't eligible for removal! Because deleted SQL LTR backups prevent its deletion`.

.. note:: Before you delete a production Environment with an SQL (LTR) backup, ensure that you delete the obsolete SQL LTR backups, otherwise migrate the data to another Environment. If you have obsolete LTR SQL backups, you can request the deletion of the SQL LTR backups using the ``Request an manual action by SIS (Azure only)`` option in the DRCP Portal under 'Requests'. In the request, approval of the Product Owner is necessary.

**Follow-up:**
DRCP requires automated backups for a specified period (see the security baseline). This lowers risk and supports DevOps teams with data recovery. DevOps teams should setup backup of SQL Databases, according to their needs.

Networking
^^^^^^^^^^
| The APG security baseline requires the use of private endpoints for Azure SQL Database and blocks public access.
| DNS is a shared item over all Application systems: to avoid intervention cross Application systems, DRCP automates this. SQL private endpoints register in the standard DNS zone by standard automation maintained by DRCP.

**Follow-up:**
DRCP automates DNS entries for the private endpoints, and deployments by DevOps teams should use a DNS zone as none.

**Outbound network access**
| By default, SQL Server doesn't restrict outbound network access from within databases. It allows to connect to an Azure service not part of the same Application system.

**Follow-up:**
| DRCP requires enabling the 'restrict outbound network access' setting to be compliant.
| Make sure to include fully qualified domain names when the restricting is active, to allow databases to access external services.
| The outbound network activity denies any attempt to access storage accounts or databases not in this list.
| `More information about this setting <https://learn.microsoft.com/en-us/azure/azure-sql/database/outbound-firewall-rule-overview?view=azuresql>`__.

Vulnerability assessment
^^^^^^^^^^^^^^^^^^^^^^^^
| The APG security baseline requires the use of Vulnerability assessment, as part of the Defender for Azure SQL offering.
| Please enable the express configuration since it's not dependent on a separate storage account and is the default now. It's easy to switch from classic to express configuration in the portal.
| The assessment includes Microsoft's best practices and focuses on the security issues that present the biggest risks to your database and its valuable data. They cover database-level issues and server-level security issues.
| Results of the scan include actionable steps to resolve each issue and provide customized remediation scripts where applicable.
| Please resolve the issues of the scan to improve the security posture of your database.
| To resolve the findings you need the SQL Security Manager role.
| For more information please read this `article <https://learn.microsoft.com/en-us/azure/defender-for-cloud/sql-azure-vulnerability-assessment-overview>`__.

SQL Import/Export using Private Link
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| This SQL feature is at the moment in preview by Microsoft. During latest LCM investigation, DRCP identified limitations that affect the usability of this feature combined with the DRCP platform.
| For more information please read this `article <https://learn.microsoft.com/en-us/azure/azure-sql/database/database-import-export-private-link?view=azuresql>`__.

Key issues include:

- The PowerShell command ``New-AzSqlDatabaseImport`` produces generic errors regardless of its root cause, making troubleshooting difficult. The current error handling is insufficient for effectively diagnosing issues.
- Exporting a database behind a firewall is impossible at the moment, which presents a limitation for databases secured by network firewalls as hardened by the SQL security baseline.
- You must manually approve Private Endpoint connections for both Azure SQL logical server and Azure Blob Storage in the Private Link Center. This adds an extra administrative step.

Backlog story `SAA-10163 <https://jira.office01.internalcorp.net:8443/browse/SAA-10163>`__ will address this feature for future investigation.

Removal request of Long Term Retention (LTR) SQL Database Backups
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DevOps teams can't remove `SQL Long Term Retention backups <https://learn.microsoft.com/en-us/azure/azure-sql/database/long-term-retention-overview?view=azuresql>`__ due to restrictions. This process outlines how the teams can request the removal of these backups upon a manual request.

.. note:: When you delete the Azure SQL server in Azure, the SQL Long Term Retention Database backup is no longer accessible in the Azure Portal. You can view them with Powershell.

.. code-block:: powershell

   Get-AzSqlDatabaseLongTermRetentionBackup -Location swedencentral

Submit a manual request in ServiceNow through the DRDC portal

- At the page Requests (in the DRDC portal), go to ``Request a Manual Action by SIS (Azure Only)`` and select the option ``Remove SQL Azure Backup``.
- Fill in the Short Description starting with, for example: "Removal SQL Backup [Backup Name]".
- In the Description, include the following details:

 -	The Environment Usage (DEV, TST, ACC or PRD).
 -	The Azure Environment (ENV******).
 - The SQL Backup name.
 - Reason for removal.

- Attach a document with written approval from the Product Owner (PO), confirming the approval of deletion of the backup in the production environment. (A template isn't available yet, but will become available soon).
