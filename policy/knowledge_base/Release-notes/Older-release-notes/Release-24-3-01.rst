Release 24-3 01
===============
Release date: July 2, 2024

.. warning:: Upcoming breaking change: DRCP will harden Azure Disk by denying unattached disks to align with corporate policy and DRCP environment design in upcoming releases this PI. See the linked feature to learn when DRCP releases the related Azure policies for which usage. `[ISF-6574] <https://jira.office01.internalcorp.net:8443/browse/SAA-6574>`__

.. warning:: Upcoming breaking change: During upcoming release **24-3 02**, DRCP removes the component **API Management**. `[SAA-7705] <https://jira.office01.internalcorp.net:8443/browse/SAA-7705>`__

Fixed issues
------------
- Removed policy ``APG DRCP App Service SKU that supports private links`` because other App Service policies already restrict apps to be private, while remaining compliant to the security baseline. `[SAA-8602] <https://jira.office01.internalcorp.net:8443/browse/SAA-8602>`__
- Implemented policy ``APG DRCP Network Route Table Disable BGP route propagation`` which puts an audit effect on all route tables which don't have route propagation disabled on all usages except Production. To achieve compliancy with DRCP routing 2.0 and this new policy, set "disableBgpRoutePropagation" to true on existing route tables. `[SAA-8194] <https://jira.office01.internalcorp.net:8443/browse/SAA-8194>`__
- Implemented builtin policy ``Keys should have more than the specified number of days before expiration`` which puts an audit effect on Key Vault keys which expire within 60 days. `[SAA-8118] <https://jira.office01.internalcorp.net:8443/browse/SAA-8118>`__
- Fixed an issue where isn't possible to see Quick actions for none administrators. `[SAA-8979] <https://jira.office01.internalcorp.net:8443/browse/SAA-8979>`__

What's new for users
--------------------
- Added incident remediation pages (under construction for now) for all current DRCP components. `[SAA-4920] <https://jira.office01.internalcorp.net:8443/browse/SAA-4920>`__
- Added non-compliance messages to all DRCP policies, containing a hyperlink to the corresponding incident remediation pages of the component. `[SAA-4920] <https://jira.office01.internalcorp.net:8443/browse/SAA-4920>`__
- Updated all component security baseline IDs to prepare for compliance framework. `[SAA-8174] <https://jira.office01.internalcorp.net:8443/browse/SAA-8174>`__
- It's now possible to run more then one security baseline against a component. `[SAA-8154] <https://jira.office01.internalcorp.net:8443/browse/SAA-8154>`__
- Improved the internal DRCP regression test to handle policies that trigger on audit effect. `[SAA-6429] <https://jira.office01.internalcorp.net:8443/browse/SAA-6429>`__
- Added documentation about :doc:`Azure App Configuration <../../Azure-components/App-Configuration/Use-cases>`. `[SAA-7667] <https://jira.office01.internalcorp.net:8443/browse/SAA-7667>`__
