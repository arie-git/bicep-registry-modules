Release 24-1 01
===============
Release date: December 19, 2023

.. warning:: Breaking change: As announced in the previous release notes, the agent pools ``H01-P1-Infrastructure-BuildAgent-MAN03-pool`` and ``H01-P1-Infrastructure-BuildAgent-Ubuntu-latest`` are removed on December 19th. A new and improved agent pool setup is available. Please visit :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` for more information. `[SAA-4499] <https://jira.office01.internalcorp.net:8443/browse/SAA-4499>`__
.. warning:: Breaking change: In the upcoming release of January 16th, 2024, the policy effect for the new policy ``APG DRCP API Management Disable Request Auditing`` is Deny for production usage environments.

What's new for users
--------------------
- It's now possible to enable Mule APIs in the SeriveNow portal for an Application system. `[SAA-5847] <https://jira.office01.internalcorp.net:8443/browse/SAA-5847>`__
- Added missing WAF policies in the :doc:`Application Gateway user documentation <../../Azure-components/Application-Gateway/Use-cases>`. `[SAA-6069] <https://jira.office01.internalcorp.net:8443/browse/SAA-6069>`__
- Added the :doc:`Security baseline for Data Factory <../../Azure-components/Data-Factory/Security-Baseline>`. `[SAA-3094] <https://jira.office01.internalcorp.net:8443/browse/SAA-3094>`__
- Added user documentation for :doc:`Data Factory <../../Azure-components/Data-Factory/Use-cases>`. `[SAA-3094] <https://jira.office01.internalcorp.net:8443/browse/SAA-3094>`__
- An Application system removal request from the ServiceNow portal now removes the Mule APIs registration for that Application system. `[SAA-5852] <https://jira.office01.internalcorp.net:8443/browse/SAA-5852>`__
- Added a new policy ``APG DRCP API Management Disable Request Auditing``, which disables audit logging on API Management. `[SAA-5718] <https://jira.office01.internalcorp.net:8443/browse/SAA-5718>`__
- Added a new role ``Private DNS Zone Contributor - azmk8s.io`` for requesting via the :doc:`DRCP API - Assign role <../../Platform/DRCP-API/Endpoint-for-role-assignment>`. `[SAA-5701] <https://jira.office01.internalcorp.net:8443/browse/SAA-5701>`__

Fixed issues
------------
- Fixed an issue where the :doc:`DRCP API Authentication documentation <../../Platform/DRCP-API/API-authentication>` showed the wrong URL. `[SAA-6170] <https://jira.office01.internalcorp.net:8443/browse/SAA-6170>`__
- Fixed an issue where it's possible to create more then one Mule record for an environment in ServiceNow. `[SAA-6195] <https://jira.office01.internalcorp.net:8443/browse/SAA-6195>`__
- Fixed an issue where the policy ``APG DRCP Storage Account Shared Key Access should be disabled`` didn't work as intended. `[SAA-6175] <https://jira.office01.internalcorp.net:8443/browse/SAA-6175>`__
- Fixed an issue where the policy ``APG DRCP API Management minimum API version should be set to 2019-12-01 or higher`` didn't work as intended. `[SAA-6180] <https://jira.office01.internalcorp.net:8443/browse/SAA-6180>`__
- Fixed an issue where the service principal belonging to the environment service connection in Azure DevOps didn't have Microsoft Entra ID directory reader permissions for usages other than development. `[SAA-6248] <https://jira.office01.internalcorp.net:8443/browse/SAA-6248>`__
- Fixed an issue where the service principal belonging to the environment service connection in Azure DevOps didn't always have DRCP API permissions. `[SAA-6254] <https://jira.office01.internalcorp.net:8443/browse/SAA-6254>`__
- Renamed the technical name of policy ``DataFactoryLinkedServicesNotAllowed`` to ``DataFactoryLinkedServicesWhitelist`` to clarify it's intention. `[SAA-5728] <https://jira.office01.internalcorp.net:8443/browse/SAA-5728>`__
