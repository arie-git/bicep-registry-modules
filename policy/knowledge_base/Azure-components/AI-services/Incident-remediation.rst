Incident remediation AI services
================================

.. |AzureComponent| replace:: AI services
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-ai-01
     - Disallow local authentication.
     - `Disable local authentication methods <https://learn.microsoft.com/en-us/azure/ai-services/disable-local-auth>`__ in AI services improves security by ensuring that AI service requires Microsoft Entra identities for authentication.

   * - drcp-ai-02
     - Use a managed identity.
     - `Use a managed identity <https://learn.microsoft.com/en-us/azure/search/search-howto-managed-identities-data-sources>`__ in AI services improves security by not using secrets from other services, such as credentials in the connection strings.

   * - drcp-ai-03
     - Disallow public network access.
     - `Disable public network access <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource?pivots=web-portal#option-3-disable-network-access>`__ on an AI service.
   
   * - drcp-ai-04
     - Allow supported kinds.
     - `Allow supported kinds <https://learn.microsoft.com/en-us/azure/ai-services/multi-service-resource>`__ ensures that customers can deploy assessed and approved AI services from a security perspective.

   * - drcp-ai-o01
     - Disallow Global deployment models.
     - `Disable Global deployment models <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource?pivots=web-portal#deploy-a-model>`__ in OpenAI makes sure that the processed data doesn't leave the target region.

   * - drcp-ai-o02
     - Disallow trusted services.
     - `Disable trusted services <https://learn.microsoft.com/en-us/azure/ai-services/cognitive-services-virtual-networks?tabs=portal#using-the-azure-cli>`__ in OpenAI makes sure that other services can't connect to the OpenAI service in other way than by using Private Endpoints.
     
   * - drcp-ai-o03
     - Allow approved models.
     - `Allow approved models <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/create-resource?pivots=web-portal#deploy-a-model>`__ in OpenAI makes sure that customers can deploy assessed and approved models from a security perspective.
     
   * - drcp-ai-o04
     - Disable custom content filters.
     - `Disable custom content filters <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/content-filters>`__ in OpenAI makes sure that customers aren't allowed to create their own custom content filters.

   * - drcp-ai-l01
     - Language accounts should use customer owned storage.
     - `Language accounts should use customer owned storage <https://learn.microsoft.com/en-us/azure/ai-services/speech-service/bring-your-own-storage-speech-resource>`__ to control the data stored at rest in Language service.

Scope
-----

Supported Azure AI services:

- Language
- OpenAI

Some policies are applicable to all AI services, and some are applicable to a particular AI service like OpenAI for example.