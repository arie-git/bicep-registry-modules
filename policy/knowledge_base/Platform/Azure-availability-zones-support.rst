Azure Availability Zones support
================================
| Microsoft maintains the physical data centers that host the Azure Cloud.
| Due to high demand and capacity constraints Microsoft limited the availability of Azure Availability Zones.
| This limitation goes against the best-pratice of Microsoft for production workloads where a zone-redundancy of 3 zones is the Microsoft standard to avoid undue outages.
| For some components these outages can even impact the availability of data in case of hardware failures.
| Microsoft is working on extending the data center ( Phase 4 ) and this limitation is active until the extension of the physical data center is ready.

Work-a-round
=============
| APG's Microsoft Account Manager has suggested to work-a-round the issue which takes around 1 to 2 weeks to approve within Microsoft.

| This process involves the Platform team and the Account Manager of Microsoft.
| To start this, per Azure Component, the platform team creates a Microsoft ticket with the following required information:

* Subscription ID:
* Region:
* Requested Number of Instances:
* Requested new SKU:
* Long Term # of Instances/SKU:
* OS Type: (Windows/Linux):
* Resource group:

.. warning::
   in-place upgrading has limits - always create with zone-redundancy during instantiation.

Impact:
--------
* 1 to 2 weeks of delay (after creating an production environment) when elements require zone-redundancy.
* DevOps teams need to switch for zone redundancy in configuration between A and P deployments.

Affected items:
================
| Creating items without a zone redundancy impacts the formal SLA for the following items:

.. list-table::
   :widths: 30 10 10 10
   :header-rows: 1

   * - Azure Component
     - 1 Zone Availability
     - 3 Zone Availability
     - Data Loss Risk
   * - CosmosDb
     - 99.99%
     - 99.995%
     - Yes
   * - Azure SQL (Business Critical SKU)
     - 95%
     - 99.99%
     - No
   * - PostgreSQL
     - 99.9%
     - 99.99%
     - No
   * - Azure Kubernetes Services - Nodes
     - 99.9%
     - 99.99%
     - No
   * - AppServices
     - 99.95%
     - 99.95%
     - No
