Release 24-4 03
===============
Release date: November 5, 2024

.. warning:: Breaking change: DRCP enforces the enablement of zone redundancy for Cosmos DB production Environments. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the Load Balancer Private IP in frontend configuration. `[SAA-10168] <https://jira.office01.internalcorp.net:8443/browse/SAA-10168>`__

.. warning:: Upcoming breaking change: During upcoming releases, DRCP enforces the minimum TLS 1.2 protocol version for Application Gateway production Environments. `[SAA-9969] <https://jira.office01.internalcorp.net:8443/browse/SAA-9969>`__

Fixed issues
------------


What's new for users
--------------------
- Added Application Gateway policy to prevent using older TLS version then version 1.2. `[SAA-9969] <https://jira.office01.internalcorp.net:8443/browse/SAA-9969>`__
- Added :doc:`Disable custom content filters security baseline <../../Azure-components/AI-services/Security-Baseline>` in the KB. `[SAA-9566] <https://jira.office01.internalcorp.net:8443/browse/SAA-9566>`__
- Disabled policy ``APG DRCP AKS Key Management Service (KMS) enabled`` due dependency of preview feature API server VNet Integration. `[SAA-10427] <https://jira.office01.internalcorp.net:8443/browse/SAA-10427>`__
- Added Application Gateway policy to prevent using older TLS versions then version 1.2. `[SAA-9969] <https://jira.office01.internalcorp.net:8443/browse/SAA-9969>`__
- Added :doc:`AI Search <../../Azure-components/AI-Search/Security-Baseline>` to DRCP's regression tests. `[SAA-8557] <https://jira.office01.internalcorp.net:8443/browse/SAA-8557>`__
- Re-added DenyAction policy effect on ``APG DRCP Generic Deny resource deletion`` after a migration of the Action Group location from global to the Subscription location to again prevent the deletion of the DRCP Action Group. `[SAA-9994] <https://jira.office01.internalcorp.net:8443/browse/SAA-9994>`__
- Created a Catalog item to request an App registrations in ServiceNow. IAM-DA will process this request. Please, do no longer use this `Infrastructure Catalog request <https://apgprd.service-now.com/now/nav/ui/classic/params/target/com.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3Ded04dd36871111105ee3eb583cbb3550%26sysparm_link_parent%3Dde8f430b87af91505ee3eb583cbb3575%26sysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__. `[SAA-9854] <https://jira.office01.internalcorp.net:8443/browse/SAA-9854>`__
- Investigated the use of Elastic Jobs in Azure SQL Database. Due to security constraints DRCP doesn't support this feature at this moment. `[SAA-8785] <https://jira.office01.internalcorp.net:8443/browse/SAA-8785>`__
- In the production usage, CosmosDB requires having zone redundancy enabled. `[SAA-9149] <https://jira.office01.internalcorp.net:8443/browse/SAA-9149>`__

Preparing for the future
------------------------
- Created a Catalog item to request an Azure Policy exemption in ServiceNow. `[SAA-9419] <https://jira.office01.internalcorp.net:8443/browse/SAA-9419>`__
- Implemented the Azure policies for Azure OpenAI. `[SAA-9576] <https://jira.office01.internalcorp.net:8443/browse/SAA-9576>`__
- Implemented the Azure policies for Azure AI Language. `[SAA-8490] <https://jira.office01.internalcorp.net:8443/browse/SAA-8490>`__
