Incident remediation Subscription
=================================

.. |AzureComponent| replace:: Subscription
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-sub-01
     - Network internet routing.
     - Ensure the default route of the route tables point to the central firewall instead of directly to the internet (see page :doc:`Networking <../../Platform/Networking>` for more information).

   * - drcp-sub-02
     - Default network route.
     - Ensure the default route of the route tables point to the central firewall instead of directly to the internet (see page :doc:`Networking <../../Platform/Networking>` for more information).

   * - drcp-sub-03
     - Deny next hop as internet.
     - Ensure that routes with destination (property ``nextHopType``) ``Internet`` point to the central firewall (see page :doc:`Networking <../../Platform/Networking>` for more information).

   * - drcp-sub-04
     - Network address space settings.
     - DRCP manages the network address space settings of the VNet in the environment. Changes aren't allowed. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-05
     - VNet peering.
     - DRCP manages the peering between the VNet in the environment and the hub. Changes aren't allowed. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-06
     - VNet subnet NSG.
     - Ensure to configure a Network Security Group (NSG) for each subnet that's created. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-07
     - Cross Subscription private links.
     - Private links can't span scopes outside of the Subscription. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-08
     - Automated private link DNS integration.
     - When deploying a private endpoint that connects to a DRCP supported resource, ensure to clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-sub-09
     - Private links.
     - | To ensure resource connectivity, use private links/endpoints since public network access isn't allowed by the majority of the DRCP components.
       | Also, when creating a subnet, ensure to configure `Network Policy for Private Endpoints <https://learn.microsoft.com/en-us/azure/private-link/disable-private-endpoint-network-policy?tabs=network-policy-portal>`__. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-10
     - SIEM logging.
     - DRCP manages the Subscription diagnostic settings, which connect to the central SIEM solution of APG. Changes aren't allowed.

   * - drcp-sub-11
     - Role Based Access Control.
     - No remediation information available. See page :doc:`Role Based Access Control policies <Role-Based-Access-Control-policies>` for more information.

   * - drcp-sub-12
     - Custom contributor role.
     - DevOps teams aren't granted the built-in ``Contributor`` role since it interferes with the DRCP guardrails. See page :doc:`roles and authorizations <../../Getting-started/Roles-and-authorizations>` for more information.

   * - drcp-sub-14
     - Deny Azure Disk.
     - IAAS isn't supported on DRCP. For granted exemptions: use the ``NetworkAccessPolicy`` property with ``DenyAll`` setting in code.

   * - drcp-sub-15
     - Defender for Storage Malware Scanning.
     - Refresh the environment to automatically enable it on existing storage account.

   * - drcp-sub-16
     - Load Balancer private IP.
     - Ensure load balancer private ip addresses in frontend configuration. See page :doc:`Networking <../../Platform/Networking>` for more information.

   * - drcp-sub-17
     - Location restriction (Azure data center regions).
     - Ensure to configure the deployment with the allowed location belonging to the Environment.

   * - drcp-sub-18
     - Resource type restriction.
     - Ensure to use resource types that are within scope of a DRCP component or the platform itself.

   * - drcp-sub-19
     - Defender for Cloud configuration.
     - Refresh the Environment through the DRDC portal in ServiceNow. This remediates the Defender for Cloud plans to their desired state.

   * - drcp-sub-20
     - DRCP platform critical configuration protection.
     - You can't perform actions such as (but not limited to) renaming the Subscription or changing the VNet address space, as they're marked as platform critical configuration. See pages :doc:`Need help <../../Need-help>` and the :doc:`FAQ <../../Frequently-asked-questions>` for more information.
