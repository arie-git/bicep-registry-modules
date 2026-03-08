Release 25-1 06
===============
Release date: February 25, 2025

.. warning:: Breaking change: Policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` changes from Audit to Deny effect for all usages. `[SAA-11568] <https://jira.office01.internalcorp.net:8443/browse/SAA-11568>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce new restrictions on user-defined routes in route tables with next hop type ``Internet``. Updated DRCP policies will ensure that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to the internet. Traffic must instead route through the central firewalls. Please review your current configurations and update them as necessary. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce priority low on Azure policy run incidents to ensure a SLA is running.

What's new for users
--------------------
- DRCP policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` changes from Audit to Deny effect for all usages. `[SAA-11568] <https://jira.office01.internalcorp.net:8443/browse/SAA-11568>`__
- Updated the ``"APG DRCP AI Search Network Private endpoints private link service connections"`` policy effect to disabled because of an ongoing issue with the expression value. `[SAA-11575] <https://jira.office01.internalcorp.net:8443/browse/SAA-11575>`__.
- Updated the ``"APG DRCP AI Search Disable local authentication methods"`` policy which includes a tag. This enables the custom question answering feature of AI Language. `[SAA-11575] <https://jira.office01.internalcorp.net:8443/browse/SAA-11575>`__.
- Promoted :doc:`Azure AI Search <../../Azure-components/AI-Search>` to MVP for approved Application systems. `[SAA-10495] <https://jira.office01.internalcorp.net:8443/browse/SAA-10495>`__.
- Promoted :doc:`Azure services <../../Azure-components/AI-Services>` AI Language to MVP for approved Application systems. `[SAA-10580] <https://jira.office01.internalcorp.net:8443/browse/SAA-10580>`__.
- Promoted :doc:`Azure services <../../Azure-components/AI-Services>` Azure OpenAI to MVP for approved Application systems. `[SAA-10513] <https://jira.office01.internalcorp.net:8443/browse/SAA-10513>`__.
- Updated the ``"APG DRCP AI Search Allow approved API versions"`` policy to allow ``2024-06-01-preview``. `[SAA-11534] <https://jira.office01.internalcorp.net:8443/browse/SAA-11534>`__.
- Updated the :doc:`Notification Hubs use cases documentation <../../Azure-components/Notification-Hubs/Use-cases>`. `[SAA-10801] <https://jira.office01.internalcorp.net:8443/browse/SAA-10801>`__.

Fixed issues
------------
- Fixed agent pool specification in DRCPRepo code quality check pipeline. `[SAA-11731] <https://jira.office01.internalcorp.net:8443/browse/SAA-11731>`__
- Fixed an issue where reporting from Azure DevOps to ServiceNow broke due to special characters in values. `[SAA-12219] <https://jira.office01.internalcorp.net:8443/browse/SAA-12219>`__
- Fixed an issue where the Quick action 'Set allowed usage' wasn't available. `[CCC-214] <https://jira.office01.internalcorp.net:8443/browse/CCC-214>`__
- Fixed an issue where the policy ``APG DRCP Contributor role`` was blocking the assignment of built-in roles through the Azure portal. `[SAA-12643] <https://jira.office01.internalcorp.net:8443/browse/SAA-12643>`__

Internal platform improvements
------------------------------
- Started to use JFrog Artifactory for PowerShell modules used by DRCP. `[SAA-10141] <https://jira.office01.internalcorp.net:8443/browse/SAA-10141>`__
- Extended the DRCP regression tests for Storage Account. `[SAA-11568] <https://jira.office01.internalcorp.net:8443/browse/SAA-11568>`__
- Extended the DRCP regression test notifications with a hyperlink to the failed run. `[SAA-7329] <https://jira.office01.internalcorp.net:8443/browse/SAA-7329>`__
- Created the DRCP regression functional test for Data Factory. `[SAA-10716] <https://jira.office01.internalcorp.net:8443/browse/SAA-10716>`__
- Extended the DRCP regression technical tests for Data Factory. `[SAA-6458] <https://jira.office01.internalcorp.net:8443/browse/SAA-6458>`__
