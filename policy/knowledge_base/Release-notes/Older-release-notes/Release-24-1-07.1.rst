Release 24-1 07.1
=================
Release date: March 12, 2024

.. warning:: Breaking change: DRCP will set the policy ``APG DRCP CosmosDB Disable key based metadata write access`` from Audit to Deny for all usages. `[SAA-7061] <https://jira.office01.internalcorp.net:8443/browse/SAA-7061>`__

What's new for users
--------------------
- Enabled feature toggle for Databricks. `[SAA-4786] <https://jira.office01.internalcorp.net:8443/browse/SAA-4786>`__
- Promoted the Databricks component to beta. `[SAA-4797] <https://jira.office01.internalcorp.net:8443/browse/SAA-4797>`__
- Added :doc:`Databricks Use Cases documentation <../../Azure-components/Databricks/Use-cases>` to the Knowledge Base. `[SAA-6654] <https://jira.office01.internalcorp.net:8443/browse/SAA-6654>`__
- The support group email address stored in ServiceNow is now included in the list of recipients for `Defender for Cloud email notifications <https://learn.microsoft.com/en-us/azure/defender-for-cloud/configure-email-notifications>`__. When this field is empty, DRCP uses the email address of the Application system product owner instead. `[SAA-6575] <https://jira.office01.internalcorp.net:8443/browse/SAA-6575>`__
- Prevented the creation of Network Manager and DDoS protection plans.`[SAA-7158] <https://jira.office01.internalcorp.net:8443/browse/SAA-7158>`__
