Release 24-1 04
===============
Release date: January 30, 2024

.. warning:: Upcoming breaking change: on the release of February 13th DRCP will set the policy ``APG DRCP Application Gateway Web Application Firewall Managed Rule set`` from Audit to Deny for the usages Test, Acceptance, and Production. `[SAA-6269] <https://jira.office01.internalcorp.net:8443/browse/SAA-6269>`__
.. warning:: Upcoming breaking change: on the release of February 13th DRCP will set the policy ``APG DRCP SQL Azure AD only authentication`` from Audit to Deny for the usages Test, Acceptance, and Production. `[SAA-4940] <https://jira.office01.internalcorp.net:8443/browse/SAA-4940>`__
.. warning:: Upcoming breaking change: on the release of February 13th DRCP will set the policy ``APG DRCP Network Subnet Private Endpoint Network Policy`` from Audit to Deny for the all usages. Change subnet Bicep property ``"privateEndpointNetworkPolicies"`` to either ``"Enabled" or "RouteTableOnly"`` `[SAA-5499] <https://jira.office01.internalcorp.net:8443/browse/SAA-5499>`__

What's new for users
--------------------
- Private endpoints of App Service apps hosted by an App Service Environment can now remediate to the appropriate DNS zone (``appserviceenvironment.net`` instead of ``azurewebsites.net``). See :doc:`this documentation <../../Azure-components/App-Service/Use-cases>` for more information. `[SAA-5370] <https://jira.office01.internalcorp.net:8443/browse/SAA-5370>`__
- Improved the internal DRCP regression test by splitting existing components in create, check and remove stages. `[SAA-5509] <https://jira.office01.internalcorp.net:8443/browse/SAA-5509>`__
- Added the :doc:`Security baseline for Service Bus <../../Azure-components/Service-Bus/Security-Baseline>`. `[SAA-4800] <https://jira.office01.internalcorp.net:8443/browse/SAA-4800>`__
- Added the ``APG DRCP Network Subnet Private Endpoint Network Policy`` which audits subnets for Private Endpoint policies that should be using a Route Table. `[SAA-5499] <https://jira.office01.internalcorp.net:8443/browse/SAA-5499>`__
- Enabled creation of Application systems for BU CCC. `[ISF-5625] <https://jira.office01.internalcorp.net:8443/browse/ISF-5625>`__

Fixed issues
------------
- Fixed an issue where Azure DevOps pipelines couldn't update the change in ServiceNow. `[SAA-5487] <https://jira.office01.internalcorp.net:8443/browse/SAA-5487>`__
