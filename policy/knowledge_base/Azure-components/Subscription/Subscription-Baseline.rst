Security baseline Subscription
==============================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 0.1
     - January, 2023
     - Bas van den Putten
     - Initial version.
   * - 0.2
     - September 19, 2023
     - Onno Hettema
     - Updated baseline controls for global design.
   * - 0.3
     - August 25, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - June 25, 2024
     - Cyprian Zurek
     - Added routing version 2.0.
   * - 1.2
     - July 11, 2024
     - Cyprian Zurek, Wieshaal Jhinnoe
     - Updated blocked resource types controls and Azure disk hardening.
   * - 1.3
     - August 21, 2024
     - Bhavani Meena
     - Updated controls for allowing Malware Scanning of Defender for Storage.

.. contents::
   Contents:
   :local:
   :depth: 2

Motivation
----------
The organization has a need for a security configuration baseline specific to an Azure Subscription. It serves as reference and reference work, as a standard environment when deploying new Application systems and as a standard for testing the security level.


Scope and owner
---------------
.. warning:: DRCP (specifically LZ3 and LZ5) manages this baseline, which limits to the APG Landing zone. The related hubs and other Azure Landing zones are explicitly out-of-scope.

The scope of the document relates to Azure Subscription.

The PO of DRCP carries the ownership of this security configuration baseline which gets checked/tested two times per year.
If one wants to deviate from this, submit it to IRSM with business and security justification.

.. note:: Determined test cycle periodicity: every 6 months.

The security configuration baseline describes the security level that a product (component) must meet.

This document doesn't contain all parameters related to the entire environment. This may require the interplay of security configuration baselines, each of which relates to components used within a Subscription.

.. note:: Some policy effects (for example deny or audit) deviate between development and other usages (test, acceptance, and production). All :doc:`Policy exemptions <../../Azure-components/Subscription/Policy-exemptions>`.

Way of working
--------------
Using the security configuration template and guidance from IT Security, DRCP creates a security configuration baseline for an APG product (component).

These channels (not exhaustive) have provided input for the content:

-	APG information security policy
-	Threat modelling
-	APG security architecture
-	Supplier best practices
-	Best practices (for example CIS benchmarks, community guidelines, security forums)

The product/service owners are responsible for reviewing and recalibrating each security configuration baseline at least annually.
The product/service owners, IRSM, and IT Security approve the final version of a security configuration baseline.


Exceptions
----------
If a product (component) in the landscape deviates from the security configuration baseline, someone must submit an exception and handle it according to the Exception IT Policy procedure.


Maintenance
-----------
The product/service owners are responsible for reviewing and recalibrating the security configuration baseline at least annually. Afterward, the product/service owner, IRSM, and IT Security approve the resulting new final version of the security configuration baseline.

.. note:: Determined baseline evaluation cycle: every year.


System settings and conditions
------------------------------
This paragraph describes what the security-related system and configuration parameters of Azure Subscription should be.

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-sub-01
     - Network internet routing.
     - To prevent open connections to the internet, but still allow AKS routes to continue, DRCP denies direct routes to internet.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: no route to internet.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-02
     - Default network route.
     - All routes default to the NVA (Palo Alto firewall in Azure).
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a policy: default route is automatically set to the NVA.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-03
     - Deny next hop as internet.
     - Prevents 'Internet' as next hop in route tables except for given routes address prefixes.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: prevents internet as next hop in route tables.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-04
     - Network address space settings.
     - Prevents users from changing the address space of the VNet that's set upon Subscription creation.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: unable to change the address space on a VNet from the values defined.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-05
     - VNet peering.
     - VNet peering with the Hub is nessesary. Other peerings are security risks.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: no VNet peerings other then to the Hub.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-06
     - VNet subnet NSG.
     - Denies the creation of subnets without a NSG except GatewaySubnet, AzureFirewallSubnet and AzureFirewallManagementSubnet.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: creation of subnets without an NSG.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-07
     - Cross Subscription private links.
     - Blocking communication via private links to other Subscriptions.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: cross Subscription private links.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-08
     - Automated private link DNS integration.
     - If you use a private link, the DNS setting is automatically configured in the Azure Hub DNS.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a auto remediation policy: DNS settings are automatically set on the private link.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-09
     - Private links.
     - To enforce usage of private links to applicable components and not use public IPs for communication.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a policy: enforce the use of private links.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-10
     - SIEM logging.
     - To prevent data loss of diagnostics, DRCP will enable auto remediation. Otherwise logs might be in a decentralized location and there is no control.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a policy: auto remediation of diagnostic settings.
     - Diagnostic settings inside Subscription.
   * - drcp-sub-11
     - Role Based Access Control.
     - Not using the built-in roles of Microsoft Entra ID but instead use custom roles with less privileges.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: Microsoft Entra ID built-in roles.
     - Diagnostic settings inside Subscription.
   * - drcp-sub-12
     - Custom contributor role.
     - Not using the built-in contributor role but instead use custom contributor role with less privileges.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Assign the custom role.
     - Diagnostic settings inside Subscription.
   * - drcp-sub-14
     - Deny Azure Disk
     - Prevents the creation of Azure Disk, because IAAS isn't supported.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy: creation of Azure Disk.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-15
     - Defender for Storage Malware Scanning
     - Event Grid is specifically allowed for enabling the Malware Scanning feature of Defender for Storage, and it blocks all other scenarios.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce an audit policy for allowing Event Grid for the scenario of Enabling Malware Scanning feature for Defender for Storage.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-16
     - Load Balancer private IP addresses
     - Load Balancer private IP addresses in frontend configuration.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce Load Balancer private IP addresses in frontend configuration.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-17
     - Location restriction (Azure data center regions)
     - To prevent running applications outside of the allowed Azure data center regions determined by APG.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy that restricts deployments of Azure resources to the allowed locations (Azure data center regions) determined by the platform.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-sub-18
     - Resource type restriction
     - To restrict the use of Azure resource types to the ones that are within scope of a DRCP component.
     - M
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce a deny policy that prevents deployments of Azure resource types that aren't in scope of a DRCP component or the platform itself.
     - Microsoft Defender for Cloud. Compliant policy.

   * - drcp-sub-19
     - Defender for Cloud configuration
     - Microsoft Defender for Cloud is a Cloud Native Application Protection Platform (CNAPP) consisting of security measures and practices designed to protect cloud-based applications from cyberthreats and vulnerabilities.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce an audit policy that checks the enablement and desired configuration of Defender for Cloud.
     - Microsoft Defender for Cloud. Compliant policy.

   * - drcp-sub-20
     - DRCP platform critical configuration protection
     - To restrict DevOps teams from altering mandatory configurations of critical elements provided by DRCP in the Environment Subscription.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - Team Azure Ignite
     - Enforce deny policies that prevents changes in critical resources deployed by DRCP in the Environment Subscription, a policy that applies mandatory tag inheritance, and configure specific ``NotActions`` within the custom DRCP Contributor role.
     - Microsoft Defender for Cloud. Compliant policy.


Guidance for determining contents
---------------------------------
A security configuration baseline contains standards in the form of configuration / settings / parameters within a product (component) in relation to security.

Procedural measures (controls performed by people or systems) aren't described in the security configuration baseline but in the Risk Control framework.

IT Management & security processes
----------------------------------
The security of a product strongly depends on the quality of the management & security processes followed. This includes, the controlled implementation of changes, access, authorizations based on least privilege, and need to know need to have. Also the application of security updates/patches and monitoring systems for suspicious patterns.

Security measures within processes such as change, access, incident, vulnerability and configuration management aren't part of the security configuration baseline. They're part of the risk-control framework.
