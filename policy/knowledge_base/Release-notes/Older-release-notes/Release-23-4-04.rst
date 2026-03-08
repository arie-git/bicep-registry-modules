Release 23-4 04
===============
Release date: November 21, 2023

.. warning:: Upcoming breaking change: on the release of December 5th the agent pools ``H01-P1-Infrastructure-BuildAgent-MAN03-pool`` and ``H01-P1-Infrastructure-BuildAgent-Ubuntu-latest`` will be removed. A new and improved agent pool setup is available. Please visit :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` for more information.`[SAA-4499] <https://jira.office01.internalcorp.net:8443/browse/SAA-4499>`__
.. warning:: Breaking change: As mentioned in the previous release notes, App Service policies changed from Audit to Deny. `[SAA-5435] <https://jira.office01.internalcorp.net:8443/browse/SAA-5435>`__
.. warning:: Breaking change: Disabled Workspace context access mode for Log Analytics Workspaces. `[SAA-5824] <https://jira.office01.internalcorp.net:8443/browse/SAA-5824>`__

What's new for users
--------------------
- A DRCP API is now available for assigning `Directory Reader` to managed identities. See :doc:`Assign role <../../Platform/DRCP-API/Endpoint-for-role-assignment>`. `[SAA-1844] <https://jira.office01.internalcorp.net:8443/browse/SAA-1844>`__
- Aligned the format of the security baselines to be consistent over all components. `[SAA-5723] <https://jira.office01.internalcorp.net:8443/browse/SAA-5723>`__
- Environments are automatically registered in Mule if the Application system is Mule enabled. `[SAA-5504] <https://jira.office01.internalcorp.net:8443/browse/SAA-5504>`__
- Switched policy ``APG DRCP IAAS Creation of virtual machine(set)s`` from Deny to Audit. `[SAA-5396] <https://jira.office01.internalcorp.net:8443/browse/SAA-5396>`__

Fixed issues
------------
- Fixed an issue in policy ``APG DRCP App Service Site Slot virtual network injection`` to exclude App Service apps hosted by an App Service Environment instance. `[SAA-5748] <https://jira.office01.internalcorp.net:8443/browse/SAA-5748>`__
- Fixed an issue in which the creation of new environments sometimes required a retry. `[SAA-5948] <https://jira.office01.internalcorp.net:8443/browse/SAA-5948>`__
