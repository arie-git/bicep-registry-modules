Release 25-1 07
===============
Release date: March 11, 2025

.. note:: Starting with next PI ``25-2``, DRCP will enforce new restrictions on user-defined routes in route tables with next hop type ``Internet``. Updated DRCP policies will ensure that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to the internet. Traffic must instead route through the central firewalls. Please review your current configurations and update them as necessary. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce priority low on Azure policy run incidents to ensure a SLA is running.

.. note:: During next PI ``25-2``, DRCP will remove extra permissions of ADO repository creators.

.. note:: During next PI ``25-2``, DRCP will enforce :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` for all Azure DevOps projects.

What's new for users
--------------------
- It's now possible to see the status of specific DRCP services and connections on the `DRCP status page <https://apgprd.service-now.com/drdc?id=drcp_status>`_ in the DRDC portal. `[SAA-8452] <https://jira.office01.internalcorp.net:8443/browse/SAA-8452>`__
- It's possible to receive mails from alerts created by Azure Monitor. See :doc:`Custom Alerts Rules <../../Platform/Alerts-and-incidents/Custom-Alerts>`  for more information. `[SAA-12759] <https://jira.office01.internalcorp.net:8443/browse/SAA-12759>`__
- ServiceNow now provides more information about the pipeline run in the deployment change. `[SAA-12816] <https://jira.office01.internalcorp.net:8443/browse/SAA-12816>`__
- Azure Kubernetes RBAC Reader is now allowed for the Production Operator role. `[SAA-12753] <https://jira.office01.internalcorp.net:8443/browse/SAA-12753>`__

Fixed issues
------------
- Fixed an issue in the policy ``APG DRCP Network Address space settings`` where it would list address spaces as incompliant. `[SAA-12684] <https://jira.office01.internalcorp.net:8443/browse/SAA-12684>`__
- Fixed an issue in the Databricks collector where it would break due to no external locations being present on the Databricks instance. `[SAA-12718] <https://jira.office01.internalcorp.net:8443/browse/SAA-12718>`__

Internal platform improvements
------------------------------
- Created the functionality to track specific DRCP services and connections which reports the status to ServiceNow. `[SAA-8129] <https://jira.office01.internalcorp.net:8443/browse/SAA-8129>`__
- Improved the DRCP regression tests setup for Storage Account. `[SAA-10710] <https://jira.office01.internalcorp.net:8443/browse/SAA-10710>`__
