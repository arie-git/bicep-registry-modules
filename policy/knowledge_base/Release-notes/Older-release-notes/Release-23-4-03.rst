Release 23-4 03
===============
Release date: November 7, 2023

.. warning:: Upcoming breaking change: on the release of November 21st, the recent introduced App Service policies will change from Audit to Deny. See `[SAA-5435] <https://jira.office01.internalcorp.net:8443/browse/SAA-5435>`__ for an overview of policies involved.

What's new for users
--------------------
- Added user documentation for :doc:`Application Gateway and Web Application Firewall <../../Azure-components/Application-Gateway/Use-cases>`. `[SAA-4209] <https://jira.office01.internalcorp.net:8443/browse/SAA-4209>`__
- Updated the :doc:`App Service baseline <../../Azure-components/App-Service/Security-Baseline>` to clarify the split in responsibility between DRCP and DevOps teams. `[SAA-2981] <https://jira.office01.internalcorp.net:8443/browse/SAA-2981>`__
- Changed the dispatching of questions and incidents to the BU-CCCs. `[SAA-4930] <https://jira.office01.internalcorp.net:8443/browse/SAA-4930>`__
- Created a `new request item <https://apgprd.service-now.com/drdc?id=drdc_sc_item&source=drdc_sc_ce_index&table=sc_category&sys_id=8bcfc88e87f5f1505ee3eb583cbb3543>`__ in the DRDC portal to request manual actions from SIS. `[SAA-4933] <https://jira.office01.internalcorp.net:8443/browse/SAA-4933>`__
- Data Factory is now available for AM-CCC in a beta phase. `[SAA-3108] <https://jira.office01.internalcorp.net:8443/browse/SAA-3108>`__

Fixed issues
------------
- Fixed an issue where the import of a new certificate in Azure KeyVault failed due to maximum validity period. `[SAA-5430] <https://jira.office01.internalcorp.net:8443/browse/SAA-5430>`__
- Fixed an issue where assigning data access to user groups wasn't possible due to policy blocking users and groups. `[SAA-5691] <https://jira.office01.internalcorp.net:8443/browse/SAA-5691>`__

Preparing for the future
------------------------
- Implemented automation of environments in Mule Anypoint, as part of the preparations for integrating DRCP with Mule. `[SAA-4723] <https://jira.office01.internalcorp.net:8443/browse/SAA-4723>`__