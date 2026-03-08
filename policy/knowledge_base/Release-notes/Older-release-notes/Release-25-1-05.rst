Release 25-1 05
===============
Release date: February 11, 2025

.. warning:: Breaking change: DRCP enforces ADO ``CPP-Windows2022`` Agents to re-image after usage. `[SAA-11744] <https://jira.office01.internalcorp.net:8443/browse/SAA-11744>`__

.. warning:: Upcoming breaking change: during **Release 25-01 06** (February 25, 2025) DRCP will set the policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` from Audit to Deny for all usages. `[SAA-11568] <https://jira.office01.internalcorp.net:8443/browse/SAA-11568>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce new restrictions on user-defined routes in route tables with next hop type ``Internet``. Updated DRCP policies will ensure that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to the internet. Traffic must instead route through the central firewalls. Please review your current configurations and update them as necessary. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce priority low on Azure policy run incidents to ensure a SLA is running.

What's new for users
--------------------
- Added policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` with effect Audit to prevent bypassing the ACL and component firewall of Storage Accounts. Also added corresponding security baseline control ``drcp-st-15``.  `[SAA-9999] <https://jira.office01.internalcorp.net:8443/browse/SAA-9999>`__
- It's now possible to remove a VNet address space or add a VNet address spaces to an Environment using the Quick actions **Add VNet address space** and **Remove VNet address space** . `[SAA-11268] <https://jira.office01.internalcorp.net:8443/browse/SAA-11268>`__
- Updated the documentation to include ``private.postgres.database.azure.com`` as a supported private DNS zone, ensuring it accurately reflects the APIs capabilities for managing private DNS records. `[SAA-11974] <https://jira.office01.internalcorp.net:8443/browse/SAA-11974>`__
- Added the following Azure RBAC roles to the ``"APG DRCP RBAC Allowed `admin` roles"`` policy. `[SAA-11453] <https://jira.office01.internalcorp.net:8443/browse/SAA-11453>`__
    * `"Container Registry Repository Contributor"` with id: `"2efddaa5-3f1f-4df3-97df-af3f13818f4c`" as a administrator role.
    * `"Container Registry Repository Catalog Lister"` with id: `"2efddaa5-3f1f-4df3-97df-af3f13818f4c`" as a administrator role.
    * `"Container Registry Repository Writer"` with id: `"2a1e307c-b015-4ebd-883e-5b7698a07328`" as a administrator role.
    * `"App Configuration Contributor"` with id: `"fe86443c-f201-4fc4-9d2a-ac61149fbda0`" as  administrator role.
    * `"Container Registry Data Importer and Data Reader"` with id: `"577a9874-89fd-4f24-9dbd-b5034d0ad23a`" as an administrator role.
    * `"App Configuration Data SAS User"` with id: `"7fd69092-c9bc-4b59-9e2e-bca63317e147`" as a administrator role.
    * `"App Service Environment Contributor"` with id: `"8ea85a25-eb16-4e29-ab4d-6f2a26c711a2`" as a administrator role.
- Added the following Azure RBAC roles to the ``"APG DRCP RBAC Allowed data roles"`` policy. `[SAA-11453] <https://jira.office01.internalcorp.net:8443/browse/SAA-11453>`__
    * `"Container Registry Repository Reader"` with id: `"b93aa761-3e63-49ed-ac28-beffa264f7ac`" as a data role.
- Changed policy effect for policies `"APG DRCP RBAC New custom contributor role"` and `"APG DRCP Contributor role"` to deny to complete the migration from the old DRCP contributor role to the newly split ones per usage.  `[SAA-12158] <https://jira.office01.internalcorp.net:8443/browse/SAA-12158>`__
- ServiceNow will manage beta components, enabling Azure AI components to achieve MVP status for specific Application systems. `[SAA-11853] <https://jira.office01.internalcorp.net:8443/browse/SAA-11853>`__
- Refined the DRDC portal. The "icon menu" in the middle directly shows the categories without having to hover over the icons. Also, the change view now shows the pending (error) tasks.
- ServiceNow will manage beta components, enabling Azure AI components to achieve MVP status for specific Application systems. `[SAA-11853] <https://jira.office01.internalcorp.net:8443/browse/SAA-11853>`__
- Added Notification Hubs to the regression test. `[SAA-6782] <https://jira.office01.internalcorp.net:8443/browse/SAA-6782>`__

Fixed issues
------------
- Fixed a bug in DRCP policy ``APG DRCP PostgreSQL Enforce service managed encryption keys`` which caused to deny a correct configured deployment. `[SAA-11780] <https://jira.office01.internalcorp.net:8443/browse/SAA-11780>`__
- Fixed an issue where ``Request temporary access`` fails due to special characters in the reason field. `[SAA-12018] <https://jira.office01.internalcorp.net:8443/browse/SAA-12018>`__
- Disabled DRCP policy ``APG DRCP PostgreSQL Minimum TLS version`` due anomalies in retrieving the current value. `[SAA-11540] <https://jira.office01.internalcorp.net:8443/browse/SAA-11540>`__
