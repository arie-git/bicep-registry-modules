Release 24-1 06
===============
Release date: February 27, 2024

.. warning:: Upcoming breaking change: on the release of March 12th DRCP will set the policy ``APG DRCP CosmosDB Disable key based metadata write access`` from Audit to Deny for all usages. `[SAA-7061] <https://jira.office01.internalcorp.net:8443/browse/SAA-7061>`__

What's new for users
--------------------

- Applied the Databricks Security baseline, so the policies become active. `[SAA-3289] <https://jira.office01.internalcorp.net:8443/browse/SAA-3289>`__
- Added the :doc:`Security baseline for Databricks <../../Azure-components/Databricks/Security-Baseline>`. `[SAA-4793] <https://jira.office01.internalcorp.net:8443/browse/SAA-4793>`__
- Moved the Azure Storage Contributor roles from the ``APG DRCP RBAC Allowed admin roles`` policy to the ``APG DRCP RBAC Allowed data roles`` policy. `[SAA-7107] <https://jira.office01.internalcorp.net:8443/browse/SAA-7107>`__

Fixed issues
------------
- Fixed an issue where the policy ``APG DRCP CosmosDB Disable key based metadata write access`` incorrectly applied reverse logic for attribute ``disableKeyBasedMetadataWriteAccess``. `[SAA-7056] <https://jira.office01.internalcorp.net:8443/browse/SAA-7056>`__
