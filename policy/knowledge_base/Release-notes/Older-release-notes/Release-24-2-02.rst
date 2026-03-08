Release 24-2 02
===============
Release date: April 9, 2024


What's new for users
--------------------
- Updated the ``APG DRCP RBAC Owner role`` policy to allow Databricks resource provider as owner on the Databricks managed resource group. `[SAA-7226] <https://jira.office01.internalcorp.net:8443/browse/SAA-7226>`__
- Updated the :doc:`branch policy <../../Application-development/Azure-devops/Build-and-release-pipelines>` to enable commits to hotfix and release branch without pull request. `[SAA-7086] <https://jira.office01.internalcorp.net:8443/browse/SAA-7086>`__
- Added a :doc:`role <../../Getting-started/Roles-and-authorizations>` ``Production Reader`` to the Application system which provides read access to Environments with usage production. `[SAA-6752] <https://jira.office01.internalcorp.net:8443/browse/SAA-6752>`__

   .. note:: For the new role to become active you'll need execute the next steps:

      1. Refresh the Application system (executed by Azure Ignite team during the release),
      2. Refresh the Environment,
      3. Next day: add users to the new role within `IAM <https://iam.office01.internalcorp.net/aveksa/main>`__.

- Extended the internal DRCP regression test with DRCP API tests. `[SAA-5907] <https://jira.office01.internalcorp.net:8443/browse/SAA-5907>`__

Preparing for the future
------------------------
- Created the initial Inspec framework for automated controls within the DRCP platform. `[SAA-6890] <https://jira.office01.internalcorp.net:8443/browse/SAA-6890>`__
- Created a new Quick action to start an automated control run using the Inspec framework. `[SAA-6914] <https://jira.office01.internalcorp.net:8443/browse/SAA-6914>`__
- Created a framework for the auditing and reporting of Databricks workspace baseline items `[SAA-6728] <https://jira.office01.internalcorp.net:8443/browse/SAA-6728>`__