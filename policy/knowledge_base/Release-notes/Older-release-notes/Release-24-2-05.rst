Release 24-2 05
===============
Release date: May 21, 2024

.. warning:: Breaking change: DRCP will remove the existing ADO service connections to SonarQube (non-Enterprise). Please switch to using the new SonarQube Enterprise version by refreshing existing Application systems, after which a new service connection with name ``SonarQubeEnterprise`` becomes available in ADO. `[SAA-7076] <https://jira.office01.internalcorp.net:8443/browse/SAA-7076>`__

.. note:: As announced in :doc:`DRCP Build agent setup <../../Application-development/Azure-devops/Build-agent-setup>` DRCP will remove the Microsoft provided agent pool ``Azure Pipelines`` in this release. Please check your pipelines and (when applicable) change it to use the APG internal build agent pool ``CPP-Ubuntu2204-Latest`` or ``CPP-Windows2022-Latest`` (only available for certain teams).

What's new for users
--------------------
- Added documentation on how to use the Databricks CLI in Azure DevOps Pipelines, see :doc:`Databricks tools <../../Application-development/Tools/DatabricksCLI>`. `[SAA-6963] <https://jira.office01.internalcorp.net:8443/browse/SAA-6963>`__
- Added documentation on how to use the Databricks CLI on the client, see :doc:`Databricks tools <../../Application-development/Tools/DatabricksCLI>`. `[SAA-7138] <https://jira.office01.internalcorp.net:8443/browse/SAA-7138>`__
- Updated Databricks Use cases documentation with extra firewall rule information and small improvements, see :doc:`Databricks Use cases <../../Azure-components/Databricks/Use-cases>`. `[SAA-7399] <https://jira.office01.internalcorp.net:8443/browse/SAA-7399>`__
- Implemented auditing and reporting of Databricks Workspaces for the next 10 security baseline items. `[SAA-7006] <https://jira.office01.internalcorp.net:8443/browse/SAA-7006>`__
- Added documentation on how to use Azure DevOps Environment, see :doc:`Environments <../../Application-development/Azure-devops/Environments>`. `[SAA-6958] <https://jira.office01.internalcorp.net:8443/browse/SAA-6958>`__
- Added a :doc:`Frequently asked questions <../../Frequently-asked-questions>` page. `[SAA-6000] <https://jira.office01.internalcorp.net:8443/browse/SAA-6000>`__
- Improved ServiceNow workflows by moving query code to script includes. `[SAA-7041] <https://jira.office01.internalcorp.net:8443/browse/SAA-7041>`__
- Removed the use of the Microsoft provided agent pool ``Azure Pipelines``. `[SAA-5753] <https://jira.office01.internalcorp.net:8443/browse/SAA-5753>`__

Fixed issues
------------
- Fixed an issue where the policy ``APG DRCP App Service Environment App Network Private DNS zones`` required manual post-deployment remediation to correct the private DNS zone configuration to the corresponding private DNS zone (``appserviceenvironment.net``). The policy ``APG DRCP App Service Site Network Private DNS zones`` now handles both private DNS zones. `[SAA-7623] <https://jira.office01.internalcorp.net:8443/browse/SAA-7623>`__
