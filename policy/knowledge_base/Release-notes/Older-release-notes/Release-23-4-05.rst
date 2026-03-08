Release 23-4 05
===============
Release date: December 5, 2023

.. warning:: Breaking change postponed to December 19th due to connectivity issues: As announced in the previous release notes, the agent pools ``H01-P1-Infrastructure-BuildAgent-MAN03-pool`` and ``H01-P1-Infrastructure-BuildAgent-Ubuntu-latest`` will be removed on December 19th. A new and improved agent pool setup is available. Please visit :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` for more information. `[SAA-4499] <https://jira.office01.internalcorp.net:8443/browse/SAA-4499>`__

What's new for users
--------------------
- Updated the :doc:`Use cases for App Service <../../Azure-components/App-Service/Use-cases>`. `[SAA-2986] <https://jira.office01.internalcorp.net:8443/browse/SAA-2986>`__
- Added privileged roles to AdminRBACRoles policy for Log Analytics and Application Insights. `[SAA-5991] <https://jira.office01.internalcorp.net:8443/browse/SAA-5991>`__
- Added control gates to limit the usage an Application system can use. To request a new usage use the Quick action :doc:`Set allowed usage <../../Platform/DRDC-portal/Quick-actions>`. `[SAA-4932] <https://jira.office01.internalcorp.net:8443/browse/SAA-4932>`__
- Created the :doc:`roles and authorizations <../../Getting-started/Roles-and-authorizations>` documentation. `[SAA-6032] <https://jira.office01.internalcorp.net:8443/browse/SAA-6032>`__
- Added policy ``APG DRCP Application Gateway Web Application Firewall Managed Rule set`` which enforces Microsoft Default Rule set 2.1 on Web Application Firewall for Application Gateway, but excludes on `Microsoft Threat Intelligence Collection rules <https://learn.microsoft.com/nl-nl/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21>`__. `[SAA-6069] <https://jira.office01.internalcorp.net:8443/browse/SAA-6069>`__

Fixed issues
------------
- Fixed an issue where the policy ``[Preview]: Certificates should have the specified maximum validity period`` blocked new APG certificates when importing into an Azure KeyVault. `[SAA-6027] <https://jira.office01.internalcorp.net:8443/browse/SAA-6027>`__
- Automated DRCP changes within ServiceNow do no longer create calendar items in the Outlook calendar of the change leader. `[SAA-6161] <https://jira.office01.internalcorp.net:8443/browse/SAA-6161>`__