Release 25-1 04
===============
Release date: January 28, 2025

.. warning:: Breaking change: Policy ``APG DRCP RBAC Contributor role`` from Audit to Deny for all usages. `[SAA-11510] <https://jira.office01.internalcorp.net:8443/browse/SAA-11510>`__

.. warning:: Breaking change: Private endpoint restriction policies as introduced in `SAA-11317 <https://jira.office01.internalcorp.net:8443/browse/SAA-11317>`__ from Audit to Deny for all usages. `[SAA-11466] <https://jira.office01.internalcorp.net:8443/browse/SAA-11466>`__

.. warning:: Upcoming breaking change: DRCP enforces ADO ``CPP-Windows2022`` Agents to re-image after usage at next release ``(25-1-05)``. `[SAA-11744] <https://jira.office01.internalcorp.net:8443/browse/SAA-11744>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce new restrictions on user-defined routes in route tables with next hop type ``Internet``. Updated DRCP policies will ensure that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to the internet. Traffic must instead route through the central firewalls. Please review your current configurations and update them as necessary. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

What's new for users
--------------------
- Incompliant Azure policies will result in an incident. You can find more information on Azure policies and incidents :doc:`here <../../Platform/Policies-controls-and-exemptions/Azure-policies>`. `[SAA-11491] <https://jira.office01.internalcorp.net:8443/browse/SAA-11491>`__
- Updated the effect of policy ``APG DRCP RBAC Contributor role`` from Audit-mode to Deny-mode to prevent RBAC assignments. `[SAA-11510] <https://jira.office01.internalcorp.net:8443/browse/SAA-11510>`__
- Updated the effect of policies to prevent creating inbound private links from external subscriptions from Audit-mode to Deny-mode `[SAA-11466] <https://jira.office01.internalcorp.net:8443/browse/SAA-11466>`__:
   - ``APG DRCP App Configuration Network Private endpoints private link service connections``
   - ``APG DRCP App Service Static Sites Network Private endpoints private link service connections``
   - ``APG DRCP Data Factory Network Private endpoints private link service connections``
- Removed policy ``APG DRCP ACR Assessments status codes allowed``. `[SAA-11562] <https://jira.office01.internalcorp.net:8443/browse/SAA-11562>`__
- Added :doc:`Use cases for AI Language <../../Azure-components/AI-services/Use-cases>` to the KB. `[SAA-10571] <https://jira.office01.internalcorp.net:8443/browse/SAA-10571>`__
- Adjusted security baseline control ``drcp-cosmos-10`` and corresponding policy ``APG DRCP CosmosDB Zone redundancy enabled`` of the :doc:`Cosmos DB security baseline <../../Azure-components/Cosmos-DB/Security-Baseline>` to exclude non-Production usages. `[SAA-11629] <https://jira.office01.internalcorp.net:8443/browse/SAA-11629>`__
- Added policy ``APG DRCP Contributor role`` which limits the assignment of the newly split DRCP customer contributor roles to the corresponding usage. `[SAA-11396] <https://jira.office01.internalcorp.net:8443/browse/SAA-11396>`__
- Defender for Cloud plans for Application system relational databases is now part of the `Defender for Cloud plan for Databases <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-databases-introduction>`__. This is part of implementing beta-component PostgreSQL server `[SAA-10059] <https://jira.office01.internalcorp.net:8443/browse/SAA-10059>`__.
- Added baseline control metadata to builtin Azure policies for reporting compliance in ServiceNow. `[SAA-11667] <https://jira.office01.internalcorp.net:8443/browse/SAA-11667>`__.
- Added documentation for new component Azure PostgreSQL which is in development `[SAA-10015] <https://jira.office01.internalcorp.net:8443/browse/SAA-10015>`__:
   - :doc:`Security baseline PostgreSQL <../../Azure-components/PostgreSQL/Security-Baseline>`
   - :doc:`Incident remediation PostgreSQL <../../Azure-components/PostgreSQL/Incident-remediation>`
   - :doc:`Use cases PostgreSQL <../../Azure-components/PostgreSQL/Use-cases>`
- Released the component :doc:`Notification Hubs <../../Azure-components/Notification-Hubs>` as Beta for DRCP and CCC. `[SAA-6777] <https://jira.office01.internalcorp.net:8443/browse/SAA-6777>`__
- Added the setting ``Workspace access for Azure Databricks personnel`` to the :doc:`Databricks use cases <../../Azure-components/Databricks/Use-cases>`. `[SAA-11719] <https://jira.office01.internalcorp.net:8443/browse/SAA-11719>`__
- Implemented Azure policies for new component Azure PostgreSQL which is in development. `[SAA-10025] <https://jira.office01.internalcorp.net:8443/browse/SAA-10025>`__
- Updated security baseline control ``drcp-psql-03`` in :doc:`Security baseline PostgreSQL <../../Azure-components/PostgreSQL/Security-Baseline>`. `[SAA-10025] <https://jira.office01.internalcorp.net:8443/browse/SAA-10025>`__
- Updated the documentation to add the handling of public certificates for setting custom domains in Azure App Service :doc:`Custom domain App Service <../../Azure-components/App-Service/Custom-domain>`. `[SAA-10704] <https://jira.office01.internalcorp.net:8443/browse/SAA-10704>`__
- The internal root cert chain is no longer needed for calling the ``DRCP AAD API``. `[SAA-10704] <https://jira.office01.internalcorp.net:8443/browse/SAA-10704>`__

Fixed issues
------------
- Fixed a bug in the Databricks collector which caused the automated control to fail for large workspaces. `[SAA-11685] <https://jira.office01.internalcorp.net:8443/browse/SAA-11685>`__
- Fixed a bug in DRCP policy ``APG DRCP Generic tag inheritance from subscription`` which caused to report noncompliance on certain subresources that don't support tags. `[SAA-11701] <https://jira.office01.internalcorp.net:8443/browse/SAA-11701>`__