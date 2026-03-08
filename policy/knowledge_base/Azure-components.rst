Azure components
================

.. toctree::
   :maxdepth: 1
   :glob:
   :caption: Contents

   Azure-components/*

Purpose
-------

| This section describes the Azure components that are available on the DRCP platform.
| Each Azure component has a security baseline describing its system security settings and conditions to which the component has to comply.
| Also, for each component a general description of its purpose and potential use-cases are available.
| The abbreviation originates from `Microsoft's Cloud Adoption Framework <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations?source=recommendations>`__.

What are Azure platform components
----------------------------------
According to the Ignite Cloud Vision V2.0, an Azure platform component is:

``The result of the execution of (a combination of) building blocks. An Application system is accessed, run, and changed through a platform component.
We both have platform components that we use (Azure platform components) and that we deploy ourselves on those Azure platforms (APG platform components). The Azure platform component that a customer DevOps team deploy is also the responsibility of that customer DevOps team, but the guardrails on them are created and maintained as building blocks by DRCP.``

In other words, the list of components visible below in the overview are Azure resources that meet the guardrail corresponding to their building block phase.

You can find more information in the general section under :doc:`Building block phases <Processes/Building-block-phases>`.

.. warning:: APG doesn't allow the use of new AI features in components. See :doc:`FAQ <Frequently-asked-questions>`

Enabling Azure resource providers
---------------------------------
| By default, DRCP doesn't enable all these components for every Application system.
| The (DHT approved) design of each Application system defines the allowed components.
| To enable components please use the :doc:`Quick action <Platform/DRDC-portal/Quick-actions>` 'Enable resource provider' on the Application system in the DRDC portal.

Overview
^^^^^^^^

.. list-table::
   :widths: 20 20 40 20 20
   :header-rows: 1

   * - Component
     - Abbreviation
     - Short description
     - Building block phase
     - Scoped to
   * - :doc:`AI Search <Azure-components/AI-Search>`
     - srch
     - Managed service for indexing and searching.
     - MVP
     - for approved Application Systems.
   * - :doc:`AI services <Azure-components/AI-Services>`
     - ai, lang, oai
     - A set of different services with AI capabilities.
     - MVP
     - Language, OpenAI for approved Application Systems.
   * - :doc:`App Configuration <Azure-components/App-Configuration>`
     - appcs
     - Provides a service to centrally manage application settings and feature flags.
     - MVP
     -
   * - :doc:`Application Gateway <Azure-components/Application-Gateway>`
     - agw
     - A load balancer and web application firewall to manage traffic to your webapplications.
     - MVP
     - Includes the WAF functionality.
   * - :doc:`App Service <Azure-components/App-Service>`
     - aps
     - Create enterprise-ready web and mobile apps for any platform or device, and deploy them on a scalable and reliable cloud infrastructure.
     - MVP
     - Web App, Logic App v2, Function App, API App, App Service Environment v3, App Service Plan (only SKUs that support private links)
   * - :doc:`Container Registry <Azure-components/Container-Registry>`
     - cr
     - A registry of Docker and Open Container Initiative (OCI) images, with support for all OCI artifacts.
     - MVP
     -
   * - :doc:`Cosmos DB <Azure-components/Cosmos-DB>`
     - cosmos
     - Build or modernize scalable, high-performance apps.
     - MVP
     - All capabilities except MongoDB, Apache Cassandra, Apache Gremlin and, Table.
   * - :doc:`Databricks <Azure-components/Databricks>`
     - adb
     - Azure Databricks is a fully managed first-party service that enables an open data lakehouse in Azure.
     - MVP
     -
   * - :doc:`Data Factory <Azure-components/Data-factory>`
     - adf
     - Azure ETL Service.
     - MVP
     -
   * - :doc:`Event Hubs <Azure-components/Event-Hubs>`
     - evh
     - A big data streaming platform and event ingestion service.
     - MVP
     -
   * - :doc:`Key Vault <Azure-components/Key-Vault>`
     - kv
     - Safeguard cryptographic keys and other secrets used by cloud apps and services.
     - MVP
     -
   * - :doc:`Kubernetes Service <Azure-components/Kubernetes-Service>`
     - aks
     - Deploy and scale containers on managed Kubernetes.
     - MVP
     -
   * - :doc:`Monitor <Azure-components/Monitor>`
     - amo
     - Azure Monitor features of Microsoft Azure including Azure Managed Grafana, Azure Managed Prometheus, Application Insights and Log Analytics Workspace.
     - MVP (except Managed Grafana, which is beta)
     -
   * - :doc:`Notification-Hubs <Azure-components/Notification-Hubs>`
     - log
     - Notification Hubs send and push notifications to devices across platforms.
     - MVP
     - No generic use. Specific permitted Application systems can use this component.

   * - :doc:`PostgreSQL <Azure-components/PostgreSQL>`
     - psql
     - `Azure Database for PostgreSQL flexible server <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/service-overview>`__ is a relational database service based on the `open source PostgreSQL database engine <https://www.postgresql.org>`__ .
     - Beta
     - No generic use. Specific permitted Application systems can use this component.

   * - :doc:`Redis <Azure-components/Redis>`
     - redis
     - A fully managed in-memory data store based on the open source Redis engine.
     - MVP
     - Azure Managed Redis
   * - :doc:`Service Bus <Azure-components/Service-Bus>`
     - sbns
     - A fully managed enterprise message broker with message queues and publish-subscribe topics.
     - MVP
     -
   * - :doc:`SQL Database <Azure-components/SQL-Database>`
     - sql
     - Build apps that scale with managed and intelligent SQL database in cloud.
     - MVP
     -
   * - :doc:`Storage Account <Azure-components/Storage-Account>`
     - st
     - Azure Storage data objects, including blobs, file shares, queues, tables, and disks.
     - MVP
     -
   * - :doc:`Subscription <Azure-components/Subscription>`
     - sub
     - A logical container used to provision resources in Azure. Within DRCP, a Subscription has a 1:1 relation to an Environment.
     - MVP
     -

Upcoming components
^^^^^^^^^^^^^^^^^^^^
For more information about upcoming components, see the :doc:`components roadmap <Processes/Roadmap>`.
