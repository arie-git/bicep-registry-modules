Release 24-2 03
===============
Release date: April 23, 2024

.. warning:: Upcoming breaking change: on the release of May 21st DRCP will remove the existing ADO service connections to SonarQube (non-Enterprise). Please switch to using the new SonarQube Enterprise version by refreshing existing Application systems, after which a new service connection with name ``SonarQubeEnterprise`` becomes available in ADO. `[SAA-7076] <https://jira.office01.internalcorp.net:8443/browse/SAA-7076>`__

What's new for users
--------------------
- Automated the refresh of Application system after a release. `[SAA-7036] <https://jira.office01.internalcorp.net:8443/browse/SAA-7036>`__
- Added App Configuration regression test to improve DRCP's automatic tests of the guardrails. `[SAA-6996] <https://jira.office01.internalcorp.net:8443/browse/SAA-6996>`__
- Added :doc:`documentation <../../Azure-components/App-Configuration/Use-cases>` for App Configuration. `[SAA-6949] <https://jira.office01.internalcorp.net:8443/browse/SAA-6949>`__
- Added permissions for Build Service to create Azure DevOps environments. `[SAA-7342] <https://jira.office01.internalcorp.net:8443/browse/SAA-7342>`__
- Added permissions for :doc:`Readers <../../Getting-started/Roles-and-authorizations>` read access to Azure DevOps service connections. `[SAA-7342] <https://jira.office01.internalcorp.net:8443/browse/SAA-7342>`__
- Implemented auditing and reporting of Databricks Workspaces for the first 5 security baseline items. `[SAA-7001] <https://jira.office01.internalcorp.net:8443/browse/SAA-7001>`__
- Added DNS zone field to the Quick action ``Add Private Link service id``. `[SAA-6792] <https://jira.office01.internalcorp.net:8443/browse/SAA-6792>`__
- Added ACL to the DRCP APIs in ServiceNow. `[SAA-7021] <https://jira.office01.internalcorp.net:8443/browse/SAA-7021>`__
- Added an auto test for Application systems to improve connectivity testing between ServiceNow and Azure. `[SAA-7031] <https://jira.office01.internalcorp.net:8443/browse/SAA-7031>`__
- Added a check to make sure while requesting an Application system that the name isn't already used in MULE. `[SAA-7441] <https://jira.office01.internalcorp.net:8443/browse/SAA-7441>`__
- Added a description to the Quick action ``Update Application system Product owner`` to clarify that after a refresh or maintenance run the new Product owner will get submitted to Azure. `[SAA-7234] <https://jira.office01.internalcorp.net:8443/browse/SAA-7234>`_
- Promoted the App Configuration component to beta. `[SAA-6949] <https://jira.office01.internalcorp.net:8443/browse/SAA-6949>`__
- Updated the :doc:`Databricks Security Baseline <../../Azure-components/Databricks/Security-Baseline>` to restrict not supported Databricks features.
- Created pipeline to run Databricks collector and run Inspec checks against the Databricks security baseline. `[SAA-6733] <https://jira.office01.internalcorp.net:8443/browse/SAA-6733>`__
- Created the ``APG DRCP Generic Deny resource deletion`` denying the deletion of the DRCP Action Group and Alert Rules. `[SAA-5743] <https://jira.office01.internalcorp.net:8443/browse/SAA-5743>`__
- Created the ``APG DRCP LMA Ensure Action Group properties`` policy that requires the DRCP Action Group to have specific properties. `[SAA-5743] <https://jira.office01.internalcorp.net:8443/browse/SAA-5743>`__
- Created the ``APG DRCP LMA Ensure Activity Log Alert Rules properties`` policy that requires the DRCP Activity Log Alert Rules to have specific properties. `[SAA-5743] <https://jira.office01.internalcorp.net:8443/browse/SAA-5743>`__
- Integrated the SonarQube Enterprise (SQE) API provided by Dev Support, supporting the automated creation of a SQE application (one per AS) and related ADO service connection with name ``SonarQubeEnterprise``. `[SAA-6674] <https://jira.office01.internalcorp.net:8443/browse/SAA-6674>`__

Fixed issues
------------
- Fixed an issue where DevOps teams were able to rename Subscriptions. Renaming is now disabled. `[SAA-7435] <https://jira.office01.internalcorp.net:8443/browse/SAA-7435>`__
- Fixed an issue where DevOps teams weren't able to request temporary administrator access when the Application system name contained hyphen. `[SAA-7483] <https://jira.office01.internalcorp.net:8443/browse/SAA-7483>`__

Preparing for the future
------------------------
.. note:: As announced in :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` DRCP will remove the Microsoft provided agent pool ``Azure Pipelines`` in Release 24-2 05 on **May 21st, 2024**. Please check your pipelines and (when applicable) change it to use the APG internal build agent pool ``CPP-Ubuntu2204-Latest`` or ``CPP-Windows2022-Latest`` (only available for certain teams).

.. note:: As announced in the previous demo, Microsoft faces higher demand for the 'West Europe' data center region than they can build out, due to regulatory constraints and limited external infrastructure. The reduction in available hardware, directly impacts APG's ability to create High-Available components. After consultation with Business Owners and Privacy Officers, this means that within DRCP, starting from **May 7** new Environments deploy in data center region 'Sweden Central'. All existing Environments remain supported in data center region 'West Europe'. Please note, DRCP plans further alignment of the infrastructure in the upcoming PI.

- Adapted DRCP Environment Creation/Refresh to support new region. `[SAA-7380] <https://jira.office01.internalcorp.net:8443/browse/SAA-7380>`__
- Adapted DRCP Azure policies to support new region. `[SAA-7404] <https://jira.office01.internalcorp.net:8443/browse/SAA-7404>`__
