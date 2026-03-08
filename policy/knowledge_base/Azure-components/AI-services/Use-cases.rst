Use cases AI services
=====================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. note:: Please note that the following AI services requires an approval for usage. Please contact the Product Owner DRCP.

AI services
-----------
AI services is a suite of cloud-based tools and APIs provided by Microsoft Azure to help developers integrate advanced AI capabilities into their applications. APG supports the following AI services:

* **OpenAI** - Azure OpenAI provides REST API access to OpenAI's language models including the GPT and Embeddings model series. DevOps teams can adapt these models to a specific task including but not limited to content generation, summarization, image understanding, semantic search, and natural language to code translation.

* **Language** - Azure AI Language is a cloud-based service that provides Natural Language Processing (NLP) features for understanding and analyzing text.


Use cases and follow-up
-----------------------

AI Services
-----------

Kinds
^^^^^
Azure AI services is a family of `different AI services <https://learn.microsoft.com/en-us/azure/ai-services/what-are-ai-services>`__ like for example: OpenAI, Document Intelligence, Custom Vision and etc.

**Follow-up:**
DRCP allows DevOps teams to use Language and OpenAI kinds.

Authentication methods
^^^^^^^^^^^^^^^^^^^^^^
OpenAI supports two distinct authentication methods, which verify the identity of the user or application accessing the service:

* `Local authentication (key access control) <https://learn.microsoft.com/en-us/azure/ai-services/disable-local-auth>`__: This method uses API keys to authenticate requests. Each key serves as a unique credential for accessing the service, enabling quick and straightforward integration. While effective, this approach lacks the centralized management and security features of modern identity-based authentication.

* `Microsoft Entra ID <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/role-based-access-control>`__: This method leverages organizational identities for authentication. It provides centralized, secure management of credentials and integrates seamlessly with Azure's role-based access control (RBAC) for managing permissions across services.

**Follow-up:**
DRCP prohibits the use of local authentication and mandates Microsoft Entra ID for all components. This ensures robust identity management and alignment with security baselines and compliance standards.

Managed Identity
^^^^^^^^^^^^^^^^
OpenAI and Language supports having system and user assigned identities.

* A *system-assigned* managed identity is an identity that has the same lifecycle as the assigned Azure resource.

* A *user-assigned* managed identity lives independently from the Azure resource and different Azure resources can have the same identity.

`Here <https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/managed-identity-best-practice-recommendations>`__ are Microsoft recommendations which to use.

**Follow-up:**
DRCP requires enabling managed identity to provide a way to authenticate with other Azure resources in a secure way.

Language
--------

Client libraries
^^^^^^^^^^^^^^^^
| Language offers `different client libraries <https://learn.microsoft.com/en-us/azure/ai-services/language-service/concepts/developer-guide>`__, also called as Software Development Kits (SDK), for local development in some programming languages.
| DevOps teams can choose any programming language they prefer to interact with and develop against Language, based on the specific needs of their application and the team's preferences.
| Common programming languages for this purpose include Python, C#, or JavaScript, as they integrate well with Azure SDKs and APIs.

**Follow-up:**

| DevOps teams can choose any client libraries, but they must use Artifactory for storing and distributing software.
| Artifactory is mandatory on APG workstations and Azure DevOps pipelines because it ensures secure and reliable software distribution and usage.
| Artifactory helps manage dependencies and ensures integrity and trustworthiness.
| Note that if you plan to use the Python SDK, it's important to know that the `relevant <https://pypi.org/project/azure-ai-textanalytics/>`__ package is available via PyPI, by Artifactory.

LoggingOptOut
^^^^^^^^^^^^^
During catastrophic failures, Microsoft can temporarily store and access data in AI Language for debugging purposes. Keep note that the most features disable this by default, but some features enable it.

**Follow-up:**
DRCP disallows data access by default for Microsoft support. This allows DevOps teams to have control over their own data and who has or needs access. Because of this reason, DRCP requires DevOps teams to set the LoggingOptOut parameter to disable this behavior.

Set the `LoggingOptOut parameter <https://learn.microsoft.com/en-us/legal/cognitive-services/language-service/data-privacy#how-is-data-retained-and-what-customer-controls-are-available>`__ for the PII and health feature endpoints. Since the parameter is already disabled by default for other endpoints, such as Language Detection, Key Phrase Extraction, Sentiment Analysis, and Named Entity Recognition, there is no action required.

If, for example, you call a PII endpoint with the REST API:
``https://<your-language-resource-endpoint>/language/:analyze-text?api-version=2022-05-01``

You include the LoggingOptOut parameter as defined here:

.. code-block:: powershell

   {
      "kind": "PiiEntityRecognition",
      "parameters":
      {
         "loggingOptOut": "False",
         "modelVersion": "latest",
         "piiCategories" :
         [
               "Person"
         ]
      },
      "analysisInput":
      {
      "documents":
      [
         {
         "id":"1",
         "language": "en",
         "text": "my text"
         }
      ]
      },
      "kind": "PiiEntityRecognition",
      "parameters": {
               "redactionPolicy": {
               "policyKind": "MaskWithCharacter"
               //MaskWithCharacter|MaskWithEntityType|DoNotRedact
               "redactionCharacter": "*"
   }

`Source <https://learn.microsoft.com/en-us/azure/ai-services/language-service/personally-identifiable-information/how-to-call>`__.

Authorization
^^^^^^^^^^^^^
Language offers `Role-Based Access Control (RBAC) roles <https://learn.microsoft.com/en-us/azure/ai-services/language-service/concepts/role-based-access-control>`__ to manage granular access, allowing organizations to control which actions users can perform within the service.

**Follow-up:**

DevOps teams can assign the following roles based on specific needs:

* Cognitive Services Language *Reader*: For validating and review Language apps. They may want to review the application's assets to notify developers of any changes, but don't have direct access to make them.

* Cognitive Services Language *Writer*: For building and modifying Language apps in any way, train those changes and validating and test in the portal.

* Cognitive Services Language *Owner*: For full access to any of the underlying functions and thus can view and access any changes for authoring and runtime environments.

OpenAI
------

Client libraries
^^^^^^^^^^^^^^^^
| OpenAI offers `different client libraries <https://learn.microsoft.com/en-us/azure/ai-services/openai/supported-languages?tabs=dotnet-secure%2Csecure%2Cpython-secure%2Ccommand&pivots=programming-language-python>`__, also called as Software Development Kits (SDK), for local development in some programming languages.
| DevOps teams can choose any programming language they prefer to interact with and develop against OpenAI, based on the specific needs of their application and the team's preferences.
| Common programming languages for this purpose include Python, C#, or JavaScript, as they integrate well with Azure SDKs and APIs.

**Follow-up:**

| DevOps teams can choose any client libraries, but they must use Artifactory for storing and distributing software.
| Artifactory is mandatory on APG workstations and Azure DevOps pipelines because it ensures secure and reliable software distribution and usage.
| Artifactory helps manage dependencies and ensures integrity and trustworthiness.
| Note that if you plan to use the Python SDK, it's important to know that the `relevant <https://pypi.org/project/openai/>`__ package is available via PyPI, by Artifactory.

Deployment types
^^^^^^^^^^^^^^^^
| OpenAI provides `deployment types <https://learn.microsoft.com/en-us/azure/ai-foundry/foundry-models/concepts/deployment-types>`__ which have varied capabilities that provide trade-offs on: throughput, SLA, and price.
| Global deployment types allow traffic going to any Azure region based on their capacity.

**Follow-up:**
DRCP requires DevOps teams to use regional deployment types to ensure that data will stay within the deployed region. This means Standard or Provisioned Managed `deployment types <https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models?tabs=global-ptum%2Cstandard-chat-completions#models-by-deployment-type>`__ and **not** the Global Standard & Global Provisioned Managed variants.

Available models
^^^^^^^^^^^^^^^^
.. vale Microsoft.Acronyms = NO

OpenAI provides different `Large Language Models (LLMs) <https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/models?tabs=python-secure%2Cglobal-standard%2Cstandard-chat-completions>`__ like GPT models, DALL-E or Whisper, each tailored to specific tasks and use cases.

.. vale Microsoft.Acronyms = YES

Models are typically selected based on features, cost, and performance. Azure also retains legacy models for compatibility, but Microsoft recommends newer versions due to improved capabilities.

**Follow-up:**
As of now, DRCP approves the use of the following models for DevOps teams:

Using the latest OpenAI models may cause this error: "The current Subscription doesn't have access to this model." Contact Microsoft to request access to the latest models using the following `link <https://customervoice.microsoft.com/Pages/ResponsePage.aspx?id=v4j5cvGGr0GRqy180BHbR7en2Ais5pxKtso_Pz4b1_xUQ1VGQUEzRlBIMVU2UFlHSFpSNkpOR0paRSQlQCN0PWcu>`__ .

* **Text-embedding-3-large**: The latest and most efficient embedding model for tasks involving semantic search or data categorization.

* **Text-embedding-ada-002**: The previous embedding model for tasks involving semantic search or data categorization.

* **GPT-4o**: Recommended for conversational AI and other GPT-based interactions.

* **GPT-4o-mini**: Recommended as lightweight, fast, and cost-efficient variant of GPT-4o. Ideal for simple tasks.

* **GPT-4.1**: Recommended for high reasoning ability, nuanced understanding, and strong language generation.

* **GPT-4.1-mini**: Recommended as lightweight, fast, and cost-efficient variant of GPT-4.1. Ideal for simple tasks.

* **GPT-4.1-nano**: Recommended for ultra-fast, low-cost tasks like simple text generation, lightweight chatbots, and high-volume automation with minimal reasoning.

* **GPT-5**: Recommended for advanced reasoning, complex problem-solving, multimodal tasks (text, images, possibly audio), and enterprise-grade applications requiring high accuracy, creativity, and adaptability across domains.

* **GPT-5-mini**: Recommended for fast, cost-efficient tasks that still need strong reasoning and creativity, such as lightweight coding help, quick summaries, brainstorming, and real-time conversational AI with better performance than GPT-4.1-mini.

* **GPT-5-nano**: Recommended for ultra-lightweight, high-speed, and low-cost tasks like simple text generation, basic automation, and large-scale operations for minimal reasoning and maximum efficiency.

* **GPT-5-chat**: Recommended for interactive, conversational experiences where context retention, natural dialogue flow, and nuanced understanding are critical.

* **GPT-5.1**: Recommended for tasks requiring adaptive reasoning, multimodal input handling, and ultra-large context processing with a balance of speed and accuracy.

* **GPT-5.1-chat**: Recommended for interactive, context-rich, and nuanced conversations—offering adaptive routing between fast ("Instant") and deep ("Thinking") reasoning modes, customizable tone/personality, and richer multimodal understanding.

Any other needed models for specific use cases, DRCP will assess and approve them as necessary.

Content filters
^^^^^^^^^^^^^^^
OpenAI's `content filters <https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/content-filter?tabs=warning%2Cuser-prompt%2Cpython-new>`__ feature helps prevent the generation of harmful content by filtering both the input prompts and the output completions from GPT models. The system runs these through an ensemble of classification models designed to identify and block harmful content.

Here are the primary categories of harmful content that the filters check for:

* Hate, sexual content, self-harm and violence.

These filters ensure responsible use of AI by detecting and blocking content that violates guidelines.

**Follow-up:**
DRCP maintains the default content filtering settings and disallows creating custom content filters. This policy is in place because custom filters allow users to adjust sensitivity levels, allowing less restrictive filtering. The default content filters are a good starting point as a baseline for responsible AI use, as agreed by Security.

To loosen filtering restrictions, the appropriate :doc:`APG AI policy controls <Security-Baseline>` and APG IT Security teams must review the changes to ensure they align with security and ethical standards.

Quota management
^^^^^^^^^^^^^^^^
| Every model available in OpenAI has limits called `quota <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota?tabs=rest#introduction-to-quota>`__ ,set per Subscription per region. It means that calls to such model can't exceed number of `TPM (Tokens Per Minute) <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota?tabs=rest#introduction-to-quota>`__ and RPM (Requests Per Minute).
| Every model deployment in OpenAI must have quota assigned. The sum of all deployments that use the same model, can't exceed quota available for such model. Example `here <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/quota?tabs=rest#introduction-to-quota>`__.

**Follow-up:**
DRCP recommends adjusting model deployment quotas to the required thresholds, enabling DevOps teams to manage and control costs.

DRCP recommends following `Microsoft's process <https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits?tabs=REST#request-quota-increases>`__ to increase `quota <https://learn.microsoft.com/en-us/azure/ai-foundry/openai/quotas-limits?tabs=REST#regional-quota-capacity-limits>`__ if it's needed.

DRCP recommends following `Microsoft best practices <https://learn.microsoft.com/en-us/azure/ai-services/openai/quotas-limits#general-best-practices-to-remain-within-rate-limits>`__ to stay within quota limits.

Network options
^^^^^^^^^^^^^^^
OpenAI has a couple of different `networking options <https://learn.microsoft.com/en-us/azure/ai-services/cognitive-services-virtual-networks>`__. It can be available from public internet, from selected networks and IP addresses, or through private endpoints.

An option `"Allow Azure services on the trusted services list" <https://learn.microsoft.com/en-us/azure/ai-services/cognitive-services-virtual-networks?tabs=portal&WT.mc_id=Portal-Microsoft_Azure_ProjectOxford#grant-access-to-trusted-azure-services-for-azure-openai>`__ allows trusted services to connect to the OpenAI regardless of networking settings.

**Follow-up:**
DRCP disallows public network access, ensuring that all traffic goes through the private network. This setup necessitates the use of private endpoints to securely connect to the required resources.

DRCP requires DevOps teams to disallow trusted services to connect to OpenAI.

Persisted data
^^^^^^^^^^^^^^
OpenAI's `fine-tuning <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/fine-tuning?tabs=azure-openai%2Cturbo%2Cpython-new&pivots=programming-language-studio>`__ feature allows the customization of pre-trained models by training them on user-provided data to optimize their performance for specific tasks. This process stores both the fine-tuned model and the associated training data within the service to ensure reproducibility and traceability.

**Follow-up:**

| Please note that training data is temporarily retained during the fine-tuning process. Once training is complete, DevOps teams should delete this data to reduce unnecessary storage usage, mitigate security risks, and align with data governance policies.
| To further enhance data management and security, DRCP recommends:

* Auditing fine-tuned models and removing those no longer in use.

* Deleting training data after the process is complete.

Authorization
^^^^^^^^^^^^^
OpenAI offers `Role-Based Access Control (RBAC) roles <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/role-based-access-control#summary>`__ to manage granular access, allowing organizations to control which actions users can perform within the service.

**Follow-up:**

DevOps teams can assign the following roles based on specific needs:

* Cognitive Services *OpenAI User*: For interacting with models, such as GPT conversations.

* Cognitive Services *OpenAI Contributor*: For creating and deploying models or fine-tuning them.

* Cognitive Services *Usages Reader*: For viewing service usage and quota information.

* Cognitive Services *Contributor*: For broader access, covering all actions not included in the previous roles.

For a full overview, `click here <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/role-based-access-control#azure-openai-roles>`__.

Availability and disaster recovery
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The service doesn't have built-in geo-redundancy or zone-redundancy features. It's possible to create solutions to `increase availability and help disaster recovery <https://learn.microsoft.com/en-us/azure/ai-services/openai/how-to/business-continuity-disaster-recovery>`__, but they need one more region.

**Follow-up:**
DRCP allows components in one approved region.

Microsoft performs disaster recovery on their best efforts.

Prompts and completions retention
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To detect and mitigate abuse of service usage, OpenAI stores all prompts and generated content for up to 30 days. This storage allows an authorized Microsoft employee to review the data if they detect abuse patterns. More information `here <https://learn.microsoft.com/en-us/azure/ai-foundry/responsible-ai/openai/data-privacy?tabs=azure-portal#preventing-abuse>`__.

**Follow-up:**
DevOps teams can't disable this functionality, as DevOps teams also can't disable content filtering (which relates to this mechanism).

OpenAI Studio
^^^^^^^^^^^^^
`OpenAI Studio <https://learn.microsoft.com/en-us/azure/ai-studio/what-is-ai-studio>`__ is a portal where DevOps teams can develop, test, and refine features of OpenAI. Is it accessible by `this URL <https://ai.azure.com>`__. The studio integrates with Azure subscriptions and uses RBAC controls, meaning it inherits the permissions of the Microsoft Entra ID user who logs into it.

**Follow-up:**
DRCP allows DevOps teams to use OpenAI Studio for development usages. DRCP restricts the studio for use in test, acceptance, and production environments. This limitation exists because user permissions in development usages are more flexible. In other usages, DRCP permits the Azure DevOps service connection to access OpenAI Studio, ensuring stricter control over critical stages of deployment.

Data privacy
^^^^^^^^^^^^
DevOps teams can read further Microsoft's statements of what the service is and what isn't doing with customers data `here <https://learn.microsoft.com/en-us/legal/cognitive-services/openai/data-privacy?tabs=azure-portal>`__.
