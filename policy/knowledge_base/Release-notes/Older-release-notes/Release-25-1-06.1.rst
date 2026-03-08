Release 25-1 06.1
=================
Release date: March 04 2025

.. warning:: Breaking change: Policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` changes from Audit to Deny effect for all usages. `[SAA-11568] <https://jira.office01.internalcorp.net:8443/browse/SAA-11568>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce new restrictions on user-defined routes in route tables with next hop type ``Internet``. Updated DRCP policies will ensure that routes with destinations to ``AzureActiveDirectory`` and ``AzureMonitor`` are no longer allowed to point directly to the internet. Traffic must instead route through the central firewalls. Please review your current configurations and update them as necessary. `[SAA-10105] <https://jira.office01.internalcorp.net:8443/browse/SAA-10105>`__

.. note:: Starting with next PI ``25-2``, DRCP will enforce priority low on Azure policy run incidents to ensure a SLA is running.

What's new for users
--------------------
- DRCP policy ``APG DRCP StorageAccount Disallow network ACL and firewall bypassing`` changes from Deny to Audit effect for all usages. `[SAA-12724] <https://jira.office01.internalcorp.net:8443/browse/SAA-12724>`__
