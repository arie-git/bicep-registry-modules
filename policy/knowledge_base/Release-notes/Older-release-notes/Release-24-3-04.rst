Release 24-3 04
===============
Release date: August 13, 2024

.. warning:: Upcoming breaking change: DRCP will harden Azure Disk by denying unattached disks to align with corporate policy and DRCP environment design in upcoming releases this PI. See the linked feature to learn when DRCP releases the related Azure policies for which usage. `[ISF-6574] <https://jira.office01.internalcorp.net:8443/browse/SAA-6574>`__

.. warning:: Breaking change: During this release, DRCP will deny the creation of Azure Disk in usage Acceptance. `[SAA-8303] <https://jira.office01.internalcorp.net:8443/browse/SAA-8303>`__

Fixed issues
------------
- Fixed automated control ``drcp-adb-04`` for Databricks with retrieval of the application ID instead of the object ID. `[SAA-9064] <https://jira.office01.internalcorp.net:8443/browse/SAA-9064>`__
- Fixed automated control ``drcp-adb-w11`` for Databricks to exclude the ``Disable the use of web terminal.`` control for Environments with usage Development. `[SAA-9123] <https://jira.office01.internalcorp.net:8443/browse/SAA-9123>`__
- Fixed collector for Databricks for storage credentials with no access from all workspaces. `[SAA-9143] <https://jira.office01.internalcorp.net:8443/browse/SAA-9143>`__
- The refresh of an Environment now retains custom Subscription tags. `[SAA-9113] <https://jira.office01.internalcorp.net:8443/browse/SAA-9113>`__
- Updated the internal DRCP automation and the MS Graph script in the :doc:`Scripting guide <../../Application-development/Scripting-guide>` to use the ``-AsSecureString`` parameter since this is an upcoming breaking change `documented here <https://learn.microsoft.com/en-us/powershell/azure/upcoming-breaking-changes>`__. `[SAA-9133] <https://jira.office01.internalcorp.net:8443/browse/SAA-9133>`__

What's new for users
--------------------
- Updated the DRCP API PowerShell version from 7.2 to 7.4. `[SAA-8969] <https://jira.office01.internalcorp.net:8443/browse/SAA-8969>`__
- Extended policies to check on programming language versions for App services. `[SAA-7693] <https://jira.office01.internalcorp.net:8443/browse/SAA-7693>`__
  - See :doc:`App Services use cases <../../Azure-components/App-Service/Use-cases>` for supported languages.
- Promoted the :doc:`Service Bus <../../Azure-components/Service-Bus>` component to MVP. `[SAA-6699] <https://jira.office01.internalcorp.net:8443/browse/SAA-6699>`__
- Promoted the :doc:`App Configuration <../../Azure-components/App-Configuration>` component to MVP. `[SAA-7677] <https://jira.office01.internalcorp.net:8443/browse/SAA-7677>`__
- Updated the policy effect from 'Audit' to 'Deny' for usage ``Acceptance`` on policy ``APG DRCP Azure Disk creation is not allowed`` to prevent the creation of Azure Disk, because IAAS isn't supported. `[SAA-8303] <https://jira.office01.internalcorp.net:8443/browse/SAA-8303>`__
- Added automated testing for ``DevOpsProject`` security baseline. `[SAA-8233] <https://jira.office01.internalcorp.net:8443/browse/SAA-8233>`__
- Added Environment numbers in the Application system overview page in the DRDC portal. `[SAA-9138] <https://jira.office01.internalcorp.net:8443/browse/SAA-9138>`__