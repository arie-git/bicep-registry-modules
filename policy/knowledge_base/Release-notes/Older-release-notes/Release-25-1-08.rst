Release 25-1 08
===============
Release date: March 25, 2025

.. warning:: Upcoming breaking change: during Release **25-2 02** (April 22, 2025), DRCP will remove extra permissions of ADO repository creators. `[SAA-12249] <https://jira.office01.internalcorp.net:8443/browse/SAA-12249>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects. `[SAA-8974] <https://jira.office01.internalcorp.net:8443/browse/SAA-8974>`__

.. warning:: Upcoming breaking change: during Release **25-2 05** (June 3, 2025), DRCP will enforce new restrictions (with policy effect Deny) on user-defined routes with next hop type ``Internet``. Updated DRCP policies ensures that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to Internet. Traffic must instead route through the central firewalls. Please review your current configurations. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__ and `[SAA-11692] <https://jira.office01.internalcorp.net:8443/browse/SAA-11692>`__

What's new for users
--------------------
- Azure policy runs enforces priority '4 - Low' on incidents to ensure an SLA is running. `[SAA-13333] <https://jira.office01.internalcorp.net:8443/browse/SAA-13333>`__
- Grouped the tool documentation together in the :doc:`Tools <../../Application-development/Tools>` section, and added documentation for :doc:`Azure CLI <../../Application-development/Tools/AzureCLI>`. `[SAA-12931] <https://jira.office01.internalcorp.net:8443/browse/SAA-12931>`__

Internal platform improvements
------------------------------
- Added functional tests for Storage accounts in DRCP regression tests. `[SAA-7568] <https://jira.office01.internalcorp.net:8443/browse/SAA-7568>`__
- Changed the target location of the Azure DevOps backups to the dedicated ransomware tenant. `[SAA-11364] <https://jira.office01.internalcorp.net:8443/browse/SAA-11364>`__
- Added policy compliance tests for Storage Account to regression testing. `[SAA-6463] <https://jira.office01.internalcorp.net:8443/browse/SAA-6463>`__