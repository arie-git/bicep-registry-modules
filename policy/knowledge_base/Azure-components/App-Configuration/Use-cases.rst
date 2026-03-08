Use cases App Configuration
===========================

.. include:: ../../_static/include/component-usecasepage-header.txt

App Configuration
-----------------
| `Azure App Configuration <https://learn.microsoft.com/en-us/azure/azure-app-configuration/overview>`__ provides a service to centrally manage Application settings and feature flags.
| Modern programs running in a cloud, contains in general components that distributes in nature.
| Spreading configuration settings across these components can lead to hard-to-troubleshoot errors during an application deployment.
| Use App Configuration to store all the settings for your application and secure their accesses in one place.

**Out of scope**

Not applicable.

Use cases and follow-up
-----------------------

The usage
^^^^^^^^^
| The simplest method to integrate an App Configuration store into your application is through Microsoft's client library.
| Click `here <https://learn.microsoft.com/en-us/azure/azure-app-configuration/overview#use-app-configuration>`__ to explore connection options based on your preferred language and framework.
| DevOps teams have the freedom to choose between client libraries or quick starts according to their preferences.

Interface with Azure Key Vault
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
App Configuration works alongside Azure Key Vault, although they serve distinct purposes in application development:

- App Configuration manages non-sensitive application settings and values.
- Azure Key Vault secures secrets, keys, and certificates.

.. warning:: Both components can store confidential information, but ensure to use each component for its intended purpose.

Costs
^^^^^
| At moment of writing, all tiers support the use of private endpoints except the Free tier. This is mandatory due to the security baseline that prohibits public network access.
| Also, the component has a relative high risk in generating excessive costs. DRCP advices to make an estimation upfront about handling requests and to avoid throttling.
| Learn `here <https://learn.microsoft.com/en-us/azure/azure-app-configuration/faq#how-do-i-estimate-the-number-of-requests-my-application-may-send-to-app-configuration>`__ how to estimate the number of requests.

| One other best practice is to increase the refresh timeout, if your configuration values don't change frequently. Specify a new refresh timeout using the `SetCacheExpiration method <https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.configuration.azureappconfiguration.azureappconfigurationrefreshoptions.setcacheexpiration>`__.
| Find other best practices `here <https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-best-practices#reduce-requests-made-to-app-configuration>`__ and understand the `pricing <https://azure.microsoft.com/en-us/pricing/details/app-configuration/>`__. Please take both into consideration.

Supported tiers
^^^^^^^^^^^^^^^
| App Configuration offers `4 tiers <https://azure.microsoft.com/en-us/pricing/details/app-configuration/>`__, each with its own sizing and quotas. Please consider your business needs:
|	- Developer tier is ideal for development cases. It's 10x cheaper than Standard tier, but doesn't support SLA.
|	- Standard tier supports SLA and matches most use cases.
|	- Premium tier costs 8x higher than Standard tier. (99,95% versus 99,99% SLA). It's important to have a good use case to back up the enormous cost for a small SLA increase.
| Free tier isn't supported, because the lack of Private Link support.

Authentication and authorization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| Azure App Configuration uses Microsoft Entra ID to authenticate and allow requests.
| Microsoft Entra ID allows you to use Azure RBAC to grant permissions to a security principal.
| A security principal may be a user, a `managed identity <https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview>`__ or an `Application service principal <https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals>`__.

| Azure provides `built-in roles <https://learn.microsoft.com/en-us/azure/azure-app-configuration/concept-enable-rbac#azure-built-in-roles-for-azure-app-configuration>`__ for authorizing access to App Configuration data using Microsoft Entra ID.
| DRCP provides DevOps teams the flexibility to manage and grant these roles to assign permissions which are configuration store specific:

.. list-table::
   :widths: 5 20
   :header-rows: 1

   * - Role
     - Permission

   *  - App Configuration Data Owner
      - Allows read, write and delete access to App Configuration data.
   *  - App Configuration Data Reader
      - Allows read access to App Configuration data.

.. warning:: Both roles provides access to the date plane. For the control plane you will need the reader or DRCP contributor role as described :doc:`here <../../Getting-started/Roles-and-authorizations>`.

.. note:: Keep in mind that DevOps teams needs to use Microsoft Entra ID for authentication and authorization, DRCP disables access keys.

Provisioning
^^^^^^^^^^^^
| When it comes down to provisioning the component there are 2 authentication modes within the **dataPlaneProxy property**: local and pass-through.
| Since DRCP blocks local authentication (**disableLocalAuth property** enabled), the dataPlaneProxy property is no longer relevant.

Encryption
^^^^^^^^^^
| DRCP supports Microsoft managed keys for encryption at rest to prevent loss of key. APG doesn't support a centralized customer managed key solution, so CMK isn't recommended.

Availability
^^^^^^^^^^^^
| Beside the SLA that Microsoft `offers <https://www.azure.cn/en-us/support/sla/app-configuration/index.html>`__, App Configuration supports Availability Zones in the chosen region.
| This allows applications to be resilient to data center outages. DevOps teams derive from this and in that sense already have improved availability by default.
| Keep in mind that App Configuration also provides a geo-replication feature. While this option enhances component availability, they're not available to DevOps teams due to region limitations.

Recovery
^^^^^^^^
Azure offers the following recovery options. DRCP doesn't enforce or control these options in anyway, so consider as DevOps team whether it might be useful to enable and use it.

.. list-table::
   :widths: 5 5 15
   :header-rows: 1

   * - Functionality
     - Setting
     - Description

   *  - Days to save stores
      - Default is 7 days
      - The maximum number of days to save a configuration store if you accidentially deleted it.
   *  - Purge protection
      - Disabled by default
      - Turn on purge protection to prevent the permanent deletion (purge) of your configuration store and its contents during the selected retention period.

Manageability
^^^^^^^^^^^^^
App Configuration has a `diagnostics setting <https://learn.microsoft.com/en-us/azure/azure-app-configuration/monitor-app-configuration?tabs=portal#log-collection>`__ that DevOps teams can enable to collect component-specific logs like ``HTTPRequests``, ``Audit`` and ``AllMetrics``.
DevOps teams can decide whether to enable and use the logs as they wish, such as application monitoring, audit, or compliance purposes.

.. warning:: Keep in mind that costs of diagnostics logs can increase quick if the scope of the logs isn't well-defined.

Lifecycle
^^^^^^^^^^
| App Configuration as a service follows the LCM process of Microsoft, which takes care of updates and do so within the agreed SLA.

| When managing the lifecycle of functionality, it use best practices such as using prefixes and labels for organizing keys.
| This approach facilitates easy organization and management of keys, providing visibility into their usage status.
| This visibility helps in identifying keys that are actively used versus those that are ready for a clean up when no longer needed.
