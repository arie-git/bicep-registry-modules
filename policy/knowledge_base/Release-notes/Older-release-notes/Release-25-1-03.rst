Release 25-1 03
===============
Release date: January 14, 2025


.. note:: DRCP combines **Release 25-1 02** and **Release 25-1 03** into this one single release.

.. warning:: Breaking change: The Azure DevOps agent pool ``CPP-Ubuntu2204-Latest`` is removed **this release**. Please make sure to either use ``CPP-Ubuntu2204-Latest-A`` or ``CPP-Ubuntu2204-Latest-B`` in case of using the ``Latest`` agent version. `[SAA-11044] <https://jira.office01.internalcorp.net:8443/browse/SAA-11044>`__

.. warning:: Upcoming breaking change: during **Release 25-01 04** (January 28, 2025) DRCP will set the policy ``APG DRCP RBAC Contributor role`` from Audit to Deny for all usages. `[SAA-11503] <https://jira.office01.internalcorp.net:8443/browse/SAA-11503>`__

.. warning:: Upcoming breaking change: during **Release 25-01 04** (January 28, 2025) DRCP will set the private endpoint restriction policies from Audit to Deny for all usages. `[SAA-11317] <https://jira.office01.internalcorp.net:8443/browse/SAA-11317>`__

.. warning:: From **Release 25-01 04** (January 28, 2025), incompliant Azure policies will result in an incident in ServiceNow.


What's new for users
--------------------
- Added policy ``APG DRCP ACR Trusted Microsoft services should be allowed`` with effect Audit to ensure `vulnerability scanning of Defender for Cloud <https://learn.microsoft.com/en-us/azure/container-registry/scan-images-defender#scanning-a-network-restricted-registry>`__. `[SAA-9455] <https://jira.office01.internalcorp.net:8443/browse/SAA-9455>`__
- Added policy ``APG DRCP RBAC Contributor role`` with effect Audit to prevent usage of the default Azure Contributor role. `[SAA-11503] <https://jira.office01.internalcorp.net:8443/browse/SAA-11503>`__
- Added policy ``APG DRCP Notification Hubs Disallow default access policies`` with effect Audit to prevent usage of the default access policies. `[SAA-7117] <https://jira.office01.internalcorp.net:8443/browse/SAA-7117>`__
- Added policies with effect Audit to prevent creating inbound private links from external subscriptions `[SAA-11317] <https://jira.office01.internalcorp.net:8443/browse/SAA-11317>`__:
   - ``APG DRCP App Configuration Network Private endpoints private link service connections``
   - ``APG DRCP App Service Static Sites Network Private endpoints private link service connections``
   - ``APG DRCP Data Factory Network Private endpoints private link service connections``

Fixed issues
------------
- Reverted changes made to policy ``APG DRCP App Service Environment Deny lower TLS versions`` with `SAA-9963 <https://jira.office01.internalcorp.net:8443/browse/SAA-9963>`__ which caused policy to stay incompliant. `[SAA-11556] <https://jira.office01.internalcorp.net:8443/browse/SAA-11556>`__
- Fixed an issue where Cinc runs failed using the REST API to ServiceNow with large data structures. `[SAA-11135] <https://jira.office01.internalcorp.net:8443/browse/SAA-11135>`__
- Fixed an issue where Cinc run payloads for Databricks where to big, by truncating the ``code_desc`` property `[SAA-11582] <https://jira.office01.internalcorp.net:8443/browse/SAA-11582>`__
- Adjusted policy ``APG DRCP ACR Assessments status codes allowed policy`` to make it compliant before removal next release, and removed corresponding baseline control ``drcp-cr-07`` after alignment with security. `[SAA-6190] <https://jira.office01.internalcorp.net:8443/browse/SAA-6190>`__
- Fixed an issue where DevOps teams could skip the ServiceNow stages in ADO pipelines. `[SAA-10347] <https://jira.office01.internalcorp.net:8443/browse/SAA-10347>`__
- Fixed an issue where ``APG engineers`` and ``APG Temporary Access`` :doc:`ADO roles <../../Getting-started/Roles-and-authorizations>` had ``Administrator`` permissions on the default DRCP service connections for Azure. `[SAA-6565] <https://jira.office01.internalcorp.net:8443/browse/SAA-6565>`__

Preparing for the future
------------------------
- Microsoft upgrades their latest Azure DevOps runner image versions to Ubuntu 24.04 (`see announcement on GitHub <https://github.com/actions/runner-images/issues/10636>`__) , and Azure LLDC and DRCP are testing for future use in the :doc:`DRCP build agent pools <../../Application-development/Azure-devops/Build-agent-setup>`.
