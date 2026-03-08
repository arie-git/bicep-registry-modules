Release 24-2 04
===============
Release date: May 7, 2024

.. warning:: Upcoming breaking change: on the release of May 21st DRCP will remove the existing ADO service connections to SonarQube (non-Enterprise). Please switch to using the new SonarQube Enterprise version by refreshing existing Application systems, after which a new service connection with name ``SonarQubeEnterprise`` becomes available in ADO. `[SAA-7076] <https://jira.office01.internalcorp.net:8443/browse/SAA-7076>`__

.. warning:: DRCP restricts the allowed region for resources to the region of the Environment. In other words, new Environments located in region 'Sweden Central' can't host resources in other regions, such as 'West Europe', and vice versa. Please note that resource type ``Microsoft.Web/staticSites`` is still allowed in region 'West Europe' since Microsoft doesn't support this component in region 'Sweden Central'.

What's new for users
--------------------
.. note:: As announced, Microsoft has a higher demand for data center region 'West Europe' then they can build out, due to regulatory and availability of external infrastructure (power supply). The reduction in available hardware, directly impacts APG's ability to create High-Available components. After consultation with Business Owners and Privacy Officers, this means that within DRCP, starting from **May 7** new Environments deploy in data center region 'Sweden Central'. All existing Environments remain supported in data center region 'West Europe'. Please note, DRCP plans further alignment of the infrastructure in the upcoming PI.

- The documentation on the KB now reflects the change of region ('Sweden Central') for Environments. `[SAA-7429] <https://jira.office01.internalcorp.net:8443/browse/SAA-7429>`__
- Added a new Azure SQL Server policy to audit restrict outbound network access. The exact policy name is ``APG DRCP SQL Server Restrict outbound network access``. `[SAA-4839] <https://jira.office01.internalcorp.net:8443/browse/SAA-4839>`__
- Added :doc:`documentation <../../Azure-components/SQL-Database/Use-cases>` about the restrict outbound network access setting. `[SAA-4839] <https://jira.office01.internalcorp.net:8443/browse/SAA-4839>`__
- Added new policies for Azure Key Vault to audit for expiring `secrets <https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Fb0eb591a-5e70-4534-a8bf-04b9c489584a>`__ and `certificates <https://portal.azure.com/#view/Microsoft_Azure_Policy/PolicyDetailBlade/definitionId/%2Fproviders%2FMicrosoft.Authorization%2FpolicyDefinitions%2Ff772fb64-8e40-40ad-87bc-7706e1949427>`__ after 60 days. `[SAA-4833] <https://jira.office01.internalcorp.net:8443/browse/SAA-4833>`__
- Changed the actions in de 'Request a manual action by SIS' form in the DRDC portal. Added an action for the creation of DNS records in DNS zone azurebase.net and removed the action for AKS managed identities permissions. `[CCC-104] <https://jira.office01.internalcorp.net:8443/browse/CCC-104>`__

Fixed issues
------------
- Fixed an issue where the policy ``APG DRCP App Service Static Sites Private DNS zones`` wasn't able to determine the exact partition id of the :doc:`Static Web App <../../Azure-components/App-Service/Use-cases>` for deployment of the private DNS registration. `[SAA-7494] <https://jira.office01.internalcorp.net:8443/browse/SAA-7494>`__
- Fixed an issue where the Quick action ``Request temporary access`` failed when the Application system name contained a hyphen. `[SAA-7483] <https://jira.office01.internalcorp.net:8443/browse/SAA-7483>`__

Preparing for the future
------------------------
.. note:: As announced in :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` DRCP will remove the Microsoft provided agent pool ``Azure Pipelines`` in Release 24-2 05 on **May 21st, 2024**. Please check your pipelines and (when applicable) change it to use the APG internal build agent pool ``CPP-Ubuntu2204-Latest`` or ``CPP-Windows2022-Latest`` (only available for certain teams).

- Adapted the internal DRCP regression test to perform tests in both regions 'West Europe' and 'Sweden Central'. `[SAA-7409] <https://jira.office01.internalcorp.net:8443/browse/SAA-7409>`__