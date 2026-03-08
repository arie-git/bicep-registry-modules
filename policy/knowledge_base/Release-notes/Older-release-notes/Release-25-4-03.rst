Release 25-4 03
===============
Release date: November 4, 2025

.. warning::
  | **Breaking changes**

  - In upcoming **Release 25-4 04**, DRCP resets the permissions on individual repositories and pipelines in Azure DevOps. `[SAA-16178] <https://jira.office01.internalcorp.net:8443/browse/SAA-16178>`__

What's new for users
--------------------
- DRCP updates information in ServiceNow changes after the finish of customer pipelines. `[SAA-15035] <https://jira.office01.internalcorp.net:8443/browse/SAA-15035>`__
- Production Operator role now has the Azure Reader role without elevation. `[SAA-16202] <https://jira.office01.internalcorp.net:8443/browse/SAA-16202>`__
- Added Azure policies for beta component Azure Managed Redis. `[SAA-16113] <https://jira.office01.internalcorp.net:8443/browse/SAA-16113>`__
- The Azure Monitor component is now in MVP status. `[SAA-14249] <https://jira.office01.internalcorp.net:8443/browse/SAA-14249>`__

Internal platform improvements
------------------------------
- DRCP uses OAuth and service principals to connect to Azure DevOps. `[SAA-15169] <https://jira.office01.internalcorp.net:8443/browse/SAA-15169>`__
- Raised Parallel jobs of the B95 Organisation from 8 to 12. `[SAA-16235] <https://jira.office01.internalcorp.net:8443/browse/SAA-16235>`__
- Performed LCM for :doc:`App Service <../../../Azure-components/App-Service>`. `[SAA-8359] <https://jira.office01.internalcorp.net:8443/browse/SAA-8359>`__

