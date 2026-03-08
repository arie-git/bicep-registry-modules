Release 24-3 03
===============
Release date: July 30, 2024

.. warning:: Upcoming breaking change: DRCP will harden Azure Disk by denying unattached disks to align with corporate policy and DRCP environment design in upcoming releases this PI. See the linked feature to learn when DRCP releases the related Azure policies for which usage. `[ISF-6574] <https://jira.office01.internalcorp.net:8443/browse/SAA-6574>`__

.. warning:: Breaking change: During this release, DRCP will deny the creation of Azure Disk in usages Development and Test. `[SAA-8298] <https://jira.office01.internalcorp.net:8443/browse/SAA-8298>`__

.. warning:: Breaking change: DRCP will deny the adding of BGP community strings to Virtual Networks. `[SAA-8189] <https://jira.office01.internalcorp.net:8443/browse/SAA-8189>`__

.. warning:: DRCP will communicate a deadline when all Application systems should have build validation enabled. `[SAA-4822] <https://jira.office01.internalcorp.net:8443/browse/SAA-4822>`__


Fixed issues
------------
- Fixed Subscription removal flow for Network Watcher subresources. `[SAA-8810] <https://jira.office01.internalcorp.net:8443/browse/SAA-8810>`__
- Fixed an issue where incompliant none DRCP Azure policies create incidents. `[SAA-8815] <https://jira.office01.internalcorp.net:8443/browse/SAA-8815>`__

What's new for users
--------------------
- Added support for encryption at host for AKS. `[SAA-8886] <https://jira.office01.internalcorp.net:8443/browse/SAA-8886>`__
- Updated the policy effect from 'Audit' to 'Deny' for usages Development and Test on policy ``APG DRCP Azure Disk creation is not allowed`` to prevent the creation of Azure Disk, because IAAS isn't supported. `[SAA-8298] <https://jira.office01.internalcorp.net:8443/browse/SAA-8298>`__
- Exempted Databricks resource group from policy ``APG DRCP Azure Disk creation is not allowed`` and ``APG DRCP Azure Disk cannot use network access and disk export``. `[SAA-8298] <https://jira.office01.internalcorp.net:8443/browse/SAA-8298>`__
- Pre-removal of the network policies ``APG DRCP Network disable BGP community strings`` and ``APG DRCP Network Route Table Disable BGP route propagation`` to always report green. `[SAA-8994] <https://jira.office01.internalcorp.net:8443/browse/SAA-8994>`__
- Security baseline results for Application systems are visible in the DRDC portal. `[SAA-8159] <https://jira.office01.internalcorp.net:8443/browse/SAA-8159>`__
- Users can start extra runs of security baseline checks with the Quick action 'Run automated controls for LZ3'. `[SAA-8243] <https://jira.office01.internalcorp.net:8443/browse/SAA-8243>`__
- Added support for :doc:`build validation <../../Application-development/Azure-devops/Build-validation>` in Azure DevOps. `[SAA-4822] <https://jira.office01.internalcorp.net:8443/browse/SAA-4822>`__
