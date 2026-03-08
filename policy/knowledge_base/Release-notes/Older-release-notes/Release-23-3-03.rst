Release 23-3 03
===============
Release date: August 1, 2023


What's new for users
--------------------
- Enabled the use of Environments in the customer Azure DevOps projects.
- Added documentation to the Development section on the Knowledge Base for :doc:`getting started with the DRCP Azure DevOps project <../../Application-development/Azure-devops>`, :doc:`the flow from development to production <../../Application-development/Azure-devops/Build-and-release-pipelines>`, :doc:`configuration management <../../Application-development/Azure-devops/Variables-and-secrets>`, and :doc:`release management <../../Application-development/Azure-devops/Release-management>`.
- Set the FTP access policy effect to Audit in the component baseline for App Service.
- Removed the latest software version policy from the component baseline for App Service.
- Added the :doc:`Security baseline for Azure Container Registry <../../Azure-components/Container-Registry/Security-Baseline>`.
- Added information about platform :doc:`monitoring <../../Platform/Monitoring>`.

Fixed issues
------------
- Added a policy that blocks certain (sub) resource types that are out of scope for the DRCP components.
- Added a policy that denies public network access to Static Web Apps (``Microsoft.Web/staticSites``) as part of the :doc:`DRCP App Service baseline <../../Azure-components/App-Service/Security-Baseline>`.
- Added policies for Web App slots to fix the issue where public access was possible for Web App slots and the DNS record creation for private endpoints wasn't handled.
- Fixed an issue where creating a managed identity for Web App via the portal was impossible.
