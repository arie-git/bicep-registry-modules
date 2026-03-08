Release 24-2 06
===============
Release date: June 4, 2024

What's new for users
--------------------
- Updated the AKS use case documentation with Private DNS Zone Resource ID for Sweden Central, see :doc:`Kubernetes Service Use cases <../../Azure-components/Kubernetes-Service/Use-cases>`. `[SAA-7419] <https://jira.office01.internalcorp.net:8443/browse/SAA-7419>`__
- Updated the DRCP API for AKS with Private DNS Zone role assignment for Sweden Central. `[SAA-7419] <https://jira.office01.internalcorp.net:8443/browse/SAA-7419>`__
- Implemented auditing and reporting of Databricks Workspaces for the remaining security baseline items. `[SAA-7011] <https://jira.office01.internalcorp.net:8443/browse/SAA-7011>`__
    - Removed Databricks workspace security baseline controls 6 and 9, see :doc:`Security baseline Databricks <../../Azure-components/Databricks/Security-Baseline>`.
    - After removing the Databricks workspace security baseline controls 6 and 9, renumbered the remaining Databricks workspace security baseline controls, see :doc:`Security baseline Databricks <../../Azure-components/Databricks/Security-Baseline>`.
    - Changed Databricks workspace security baseline control 5, see :doc:`Security baseline Databricks <../../Azure-components/Databricks/Security-Baseline>`.
    - Moved Databricks policy security baseline control 9 to Databricks workspace security baseline controls, see :doc:`Security baseline Databricks <../../Azure-components/Databricks/Security-Baseline>`.
    - Removed 'Data Engineering: data exploration and ad-hoc data analysis by power-users' from 'not supported use cases', see :doc:`Use cases Databricks <../../Azure-components/Databricks/Use-cases>`.

Preparing for the future
------------------------
- Added base integration for AKS, SQL server & SQL database in the internal DRCP regression test for both regions 'West Europe' and 'Sweden Central'. `[SAA-7419] <https://jira.office01.internalcorp.net:8443/browse/SAA-7419>`__
- Merged input and request variables into one object to support the move of Azure DevOps variable groups to ServiceNow. `[SAA-7046] <https://jira.office01.internalcorp.net:8443/browse/SAA-7046>`__
- Moved data from Azure DevOps variable groups to ServiceNow variable store and metadata for configuration item in preparation of configuration file. `[SAA-7026] <https://jira.office01.internalcorp.net:8443/browse/SAA-7026>`__
