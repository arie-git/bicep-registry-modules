Release 26-1 06
===============
Release date: February 24, 2026

What's new for users
--------------------
- Added new Ubuntu2404 agent pools for use in CI/CD pipelines. `[SAA-13666] <https://jira.office01.internalcorp.net:8443/browse/SAA-13666>`__
- Added approval information in ServiceNow to changes for Azure DevOps pipelines. `[SAA-17609] <https://jira.office01.internalcorp.net:8443/browse/SAA-17609>`__ & `[SAA-17952] <https://jira.office01.internalcorp.net:8443/browse/SAA-17952>`__
- Added a ServiceNow :doc:`Quick action <../Platform/DRDC-portal/Quick-actions>` ``Upgrade security context ADO Principal`` for adding and removing an Environment principal to the appropriate location binding Microsoft Entra ID group. `[SAA-16501] <https://jira.office01.internalcorp.net:8443/browse/SAA-16501>`__
- Added references to the `Getting Started` guides of the BU-CCC's on the :doc:`FAQ <../Frequently-asked-questions>` page. `[SAA-13570] <https://jira.office01.internalcorp.net:8443/browse/SAA-13570>`__
- Released :doc:`Azure Managed Grafana (part of Azure Monitor) <../Azure-components/Monitor>` as beta component to the BU-CCCs and first Application systems responsible for beta testing. `[SAA-16543] <https://jira.office01.internalcorp.net:8443/browse/SAA-16543>`__
- The deployment pipeline changes set the correct usages based on the affected configuration items. `[SAA-18673] <https://jira.office01.internalcorp.net:8443/browse/SAA-18673>`__

Fixed issues
------------
- Added explicit clause for Storage Account ``FileStorage`` in policy ``APG DRCP StorageAccount Encryption all services enabled V2`` (baseline control ``drcp-st-08``). `[SAA-18200] <https://jira.office01.internalcorp.net:8443/browse/SAA-18200>`__

Internal platform improvements
------------------------------
- Removed unused Business Continuity objects. `[SAA-18149] <https://jira.office01.internalcorp.net:8443/browse/SAA-18149>`__
- Migrated DRCP non-personal secrets from Keeper Vault to CyberArk Workforce Password Manager. `[SAA-18136] <https://jira.office01.internalcorp.net:8443/browse/SAA-18136>`__
- Migrated DRCP OFFICE01 service accounts from Keeper Vault to CyberArk Privileged Access Manager. `[SAA-18142] <https://jira.office01.internalcorp.net:8443/browse/SAA-18142>`__
- Moved DRCP pipelines to Ubuntu2404 agent pools for organization ``connectdrcpapg1``. `[SAA-13666] <https://jira.office01.internalcorp.net:8443/browse/SAA-13666>`__
- The Environment automation pipeline now checks whether an Environment number already exists before it creates a Subscription. `[SAA-18162] <https://jira.office01.internalcorp.net:8443/browse/SAA-18162>`__
- The Environment automation pipeline now indicates if the pipelinerun relates to a `Create` or `Refresh` action. `[SAA-18308] <https://jira.office01.internalcorp.net:8443/browse/SAA-18308>`__
- Invoke Garbage Collection now excludes the ``Billingreservations`` subscriptions from the report. `[SAA-18224] <https://jira.office01.internalcorp.net:8443/browse/SAA-18224>`__
- Investigated SMB protocol settings for Storage Account. `[SAA-16439] <https://jira.office01.internalcorp.net:8443/browse/SAA-16439>`__
