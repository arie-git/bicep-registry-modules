Release 24-1 05
===============
Release date: February 13, 2024

.. warning:: Breaking change: DRCP will set the policy ``APG DRCP Application Gateway Web Application Firewall Managed Rule set`` from Audit to Deny for the usages Test, Acceptance, and Production. `[SAA-6269] <https://jira.office01.internalcorp.net:8443/browse/SAA-6269>`__
.. warning:: Breaking change: DRCP will set the policy ``APG DRCP SQL Azure AD only authentication`` from Audit to Deny for the usages Test, Acceptance, and Production. `[SAA-4940] <https://jira.office01.internalcorp.net:8443/browse/SAA-4940>`__
.. warning:: Breaking change: DRCP will set the policy ``APG DRCP Network Subnet Private Endpoint Network Policy`` from Audit to Deny for the all usages. Change subnet Bicep property ``"privateEndpointNetworkPolicies"`` to either ``"Enabled" or "RouteTableOnly"`` `[SAA-5499] <https://jira.office01.internalcorp.net:8443/browse/SAA-5499>`__

What's new for users
--------------------
- Applied the Service Bus Security baseline, so the policies becomes active on Subscriptions. `[SAA-4801] <https://jira.office01.internalcorp.net:8443/browse/SAA-4801>`__
- Added initial version of :doc:`Use cases for Service Bus <../../Azure-components/Service-Bus/Use-cases>`. `[SAA-4802] <https://jira.office01.internalcorp.net:8443/browse/SAA-4802>`__
- The Data Factory component is now promoted from Beta to MVP phase. `[ISF-5921] <https://jira.office01.internalcorp.net:8443/browse/ISF-5921>`__
- Added description of :doc:`Azure DevOps settings and policies <../../Application-development/Azure-devops/Settings-and-policies>`. `[SAA-4818] <https://jira.office01.internalcorp.net:8443/browse/SAA-4818>`__
- Added detailed information to :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>`. `[SAA-4819] <https://jira.office01.internalcorp.net:8443/browse/SAA-4819>`__
- Added custom domain to DRCP API, see :doc:`Endpoint documentation <../../Platform/DRCP-API/Endpoint-for-role-assignment>`. Also added information on :doc:`how to create custom domain for App Services <../../Azure-components/App-Service/Custom-domain>`. `[SAA-5901] <https://jira.office01.internalcorp.net:8443/browse/SAA-5901>`__
- It's now possible to refresh an Application system using the new Quick action *Refresh Landing zone 3*. `[SAA-6649] <https://jira.office01.internalcorp.net:8443/browse/SAA-6649>`__
- Applied the Service Bus Security baseline, so the policies becomes active on Subscriptions. `[SAA-4801] <https://jira.office01.internalcorp.net:8443/browse/SAA-4801>`__

Fixed issues
------------
- Fixed an issue where the policy ``"APG DRCP Network Subnet Private Endpoint Network Policy"`` incorrectly targeted the Virtual Network. `[SAA-6573] <https://jira.office01.internalcorp.net:8443/browse/SAA-6573>`__
