Release 24-3 06
===============
Release date: September 10, 2024

.. warning:: Breaking change: From this release, DRCP denies the creation of Azure Disk in usage Production. `[SAA-8308] <https://jira.office01.internalcorp.net:8443/browse/SAA-8308>`__
.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

Fixed issues
------------
- Removed the temporary task for removal of old Action Groups not following the naming convention. `[SAA-9440] <https://jira.office01.internalcorp.net:8443/browse/SAA-9440>`__
- Fixed an issue where 'APG DRCP Policy' policy set assignments' managed identities weren't added to the ``F-DRCP-AzureDNS-ContributorNP-001-ASG`` group for DNS remediation. `[SAA-9765] <https://jira.office01.internalcorp.net:8443/browse/SAA-9765>`__
- Fixed an issue where ``APG DRCP Policy`` policy set assignments' managed identities weren't added to the Azure roles for DNS remediation. `[SAA-9833] <https://jira.office01.internalcorp.net:8443/browse/SAA-9833>`__
- Fixed an issue where Cinc collector for Databricks didn't exit the script when data wasn't retrieved, which resulted in a failed security baseline. `[SAA-9445] <https://jira.office01.internalcorp.net:8443/browse/SAA-9445>`__

What's new for users
--------------------
- Removed policy ``APG DRCP Network Route Table Disable BGP route propagation`` and its baseline control ``drcp-sub-13``. `[SAA-8881] <https://jira.office01.internalcorp.net:8443/browse/SAA-8881>`__
- Updated the policy effect from 'Audit' to 'Deny' for usage ``Production`` on policy ``APG DRCP Azure Disk creation is not allowed`` to prevent the creation of Azure Disk, because IAAS isn't supported. `[SAA-8308] <https://jira.office01.internalcorp.net:8443/browse/SAA-8308>`__
- While running the maintenance run for Environments the security baseline for Subscriptions will get checked automatically. `[SAA-9209] <https://jira.office01.internalcorp.net:8443/browse/SAA-9209>`__
- Updated :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>` with new naming for ServiceNow approval role. `[SAA-9804] <https://jira.office01.internalcorp.net:8443/browse/SAA-9804>`__
- Updated policy ``APG DRCP Azure Disk creation is not allowed`` and ``APG DRCP Azure Disk cannot use network access and disk export`` with DRCP control 'drcp-sub-14' in non-compliance message. `[SAA-8308] <https://jira.office01.internalcorp.net:8443/browse/SAA-8308>`__
- Updated :doc:`Incident remediation Subscription <../../Azure-components/Subscription/Incident-remediation>` with DRCP control 'drcp-sub-14'. `[SAA-8308] <https://jira.office01.internalcorp.net:8443/browse/SAA-8308>`__