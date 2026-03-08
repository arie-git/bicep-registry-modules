Release 24-1 03
===============
Release date: January 16, 2024

.. warning:: Breaking change: The policy effect for the new policy ``APG DRCP API Management Disable Request Auditing`` is Deny for production usage environments.
.. warning:: Please remove any RBAC assignments on the builtin Azure Reader role for the DRCP Reader (``F-DRCP-<AS_name>-ENV#####-Reader-001-ASG``) and DRCP Engineer (``F-DRCP-<AS name>-ENV#####-Engineer-001-ASG``) groups for Subscriptions with usage production.


What's new for users
--------------------
- The refresh and maintenance of an environment triggers the rolling of secrets for the service connections and app registrations. `[SAA-4824] <https://jira.office01.internalcorp.net:8443/browse/SAA-4824>`__
- The Azure DevOps branch policy now supports `Git flow <https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow>`__ branching strategy. `[SAA-5842] <https://jira.office01.internalcorp.net:8443/browse/SAA-5842>`__
- A new or refreshed environment gets the latest version of Defender for Cloud. `[SAA-4837] <https://jira.office01.internalcorp.net:8443/browse/SAA-4837>`__
    - The Defender for Cloud plans for AKS and Container Registry are now part of the `Defender for Cloud plan for Containers <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction>`__.
    - The Defender for Cloud plan for DNS is now part of the `Defender for Cloud plan for Servers <https://learn.microsoft.com/en-us/azure/defender-for-cloud/plan-defender-for-servers>`__.
    - `Defender for Cloud for Storage <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-storage-introduction>`__ uses a new plan.
- The RBAC role ``Data Factory Contributor`` is now part of the list of roles in policy ``APG DRCP RBAC Allowed admin roles``. `[SAA-6049] <https://jira.office01.internalcorp.net:8443/browse/SAA-6049>`__
- Updated Vale to version 2.30.0. `[SAA-6353] <https://jira.office01.internalcorp.net:8443/browse/SAA-6353>`__
- Updated Sphinx to version 7.2.3. `[SAA-6358] <https://jira.office01.internalcorp.net:8443/browse/SAA-6358>`__
- Improved the knowledge base structure, providing better readability and search experience. All articles from before are still included, some received updates in the form of improved guiding text or a more suitable title. `[CCC-61] <https://jira.office01.internalcorp.net:8443/browse/CCC-61>`__
- Added new articles about :doc:`responsibilities <../../Getting-started/Responsibilities>` and :doc:`application reference architectures <../../Application-reference-architectures>`. `[CCC-61] <https://jira.office01.internalcorp.net:8443/browse/CCC-61>`__

Fixed issues
------------
- Splitting RBAC role definitions into management and data roles allows custom group assignment to data roles. `[SAA-5681] <https://jira.office01.internalcorp.net:8443/browse/SAA-5681>`__
- The DRCP roles reader and engineer no longer have the Azure reader role in the production usage. `[SAA-5686] <https://jira.office01.internalcorp.net:8443/browse/SAA-5686>`__
- Reorganized the policies monitoring the Defender for Cloud plans by adding missing policies and detailed settings. `[SAA-6299] <https://jira.office01.internalcorp.net:8443/browse/SAA-6299>`__
- Fixed an issue where DevOps teams were able to delete the default route to the central firewall. `[SAA-2809] <https://jira.office01.internalcorp.net:8443/browse/SAA-2809>`__
