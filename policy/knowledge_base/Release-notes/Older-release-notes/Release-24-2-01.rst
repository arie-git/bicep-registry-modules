Release 24-2 01
===============
Release date: March 26, 2024


What's new for users
--------------------
- Updated the ``APG DRCP Network Allowed Private endpoints private link service connections`` policy to allow specified Private Link service connections, defined per Application system. `[SAA-6807] <https://jira.office01.internalcorp.net:8443/browse/SAA-6807>`__
- Added a :doc:`Quick action <../../Platform/DRDC-portal/Quick-actions>` ``Add Private Link service id`` to add specified Private Link service connections id's, defined per Application system. `[SAA-6802] <https://jira.office01.internalcorp.net:8443/browse/SAA-6802>`__
- Enabled feature toggle for App Configuration. `[SAA-6929] <https://jira.office01.internalcorp.net:8443/browse/SAA-6929>`__
- Added :doc:`App Configuration use cases documentation <../../Azure-components/App-Configuration/Use-cases>` to the Knowledge Base. `[SAA-6934] <https://jira.office01.internalcorp.net:8443/browse/SAA-6934>`__
- Applied the App Configuration security baseline, so the policies becomes active on Subscriptions. `[SAA-6939] <https://jira.office01.internalcorp.net:8443/browse/SAA-6939>`__
- Updated the :doc:`Application Insights use case documentation <../../Azure-components/Application-Insights/Use-cases>` with information related to networking. `[SAA-5927] <https://jira.office01.internalcorp.net:8443/browse/SAA-5927>`__
- Automatic rolling of the DRCP API secrets has an automatic schedule of 90 days. `[SAA-5922] <https://jira.office01.internalcorp.net:8443/browse/SAA-5922>`__
- Updated the :doc:`Security baseline for Databricks <../../Azure-components/Databricks/Security-Baseline>` with information related to the Databricks Enhanced Security and Compliance Add-On. `[SAA-7128] <https://jira.office01.internalcorp.net:8443/browse/SAA-7128>`__
- Added DRCP resource group ``DRCP-{Environmentcode}-ActionGroups`` to environments containing an action group and alert rules as part of the monitoring and alerting framework. Refrain from deleting this resource group and its contents as these will be mandatory in the future. `[SAA-5738] <https://jira.office01.internalcorp.net:8443/browse/SAA-5738>`__