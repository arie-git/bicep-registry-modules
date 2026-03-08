Use cases Application Gateway
=============================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. warning:: Limited :doc:`Azure Availability Zones support <../../Platform/Azure-availability-zones-support>` applies.

Application Gateway
-------------------
| `Azure Application Gateway <https://learn.microsoft.com/en-us/azure/application-gateway/overview>`__ is a web traffic (OSI layer 7) load balancer that enables you to manage traffic to your web applications.
| It can make routing decisions based on attributes of an HTTP request, for example URI path or host headers.
| You can route traffic based on the incoming URL. If /images is in the incoming URL, route traffic to a specific set of servers (known as a pool) configured for images.

Application Gateway Web Application Firewall
--------------------------------------------
| `Application Gateway WAF <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview>`__ protects web applications from common vulnerabilities and exploits.
| Azure-managed rule sets provide an easy way to deploy protection against a common set of security threats. Since such rule sets are Microsoft Azure managed, the rules get updates as needed to protect against new attack signatures.

| The Default Rule Set (DRS) includes Microsoft Threat Intelligence Collection rules. Microsoft Threat Intelligence Center wrote these rules to increase coverage, patch specific vulnerabilities, and reduce false positives.
| The Open Web Application Security Project (OWASP) has incorporated DRS 2.1 of the Core Rule Set (CRS) 3.3.2 and includes proprietary protection rules. For these reasons, this DRS is the set that DRCP will follow and enforce for DevOps teams.

**Out of scope**

The following options are out of scope and therefor not available in DRCP:

- WAF on Azure FrontDoor
- WAF on Azure Content Delivery Network

Use cases and follow-up
-----------------------

Supported SKUs
^^^^^^^^^^^^^^
DRCP supports the ``Standard_v2`` and ``WAF_v2`` SKUs. The policy denies `deprecated <https://learn.microsoft.com/en-us/azure/application-gateway/migrate-v1-v2>`__ SKUs like v1 because they lack critical features such as autoscaling and Key Vault integration for HTTPS listeners and private links.

**Follow up:**
DRCP blocks other SKUs than v2, so please use ``Standard_v2`` or ``WAF_v2``.

.. note:: Be aware that the deployment can take up to 10 minutes.

Deployment
^^^^^^^^^^
When a DevOps team deploys the ``WAF_v2`` SKU, it's required to provide a WAF policy, because otherwise it fails.

- `Learn here how with a Bicep template <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/quick-create-bicep?tabs=CLI>`__
- `Or with a ARM template <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/quick-create-template>`__

.. note:: The examples documented in the Microsoft documentation use the OWASP rule set, which isn't compliant with the DRCP policies. For more information, see documentation below.

This WAF policy includes a required DRS per APG policy, along with rule sets applicable to the specific application.

.. note:: Keep in mind that DRCP prevents disabling the WAF policy state, to keep security risks as small as possible.

``Default rule set``
^^^^^^^^^^^^^^^^^^^^
| As just mentioned, DRCP will force the entire `DRS 2.1 <https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-drs?tabs=drs21#drs-21>`__, but some rules needs a `tune <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21>`__ to prevent false positives or avoid double rules.
| This means that DevOps teams needs to disable or change a status for some rules in the DRS. Find the full list `here <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21>`__.
| Furthermore DRCP acknowledges that not all rules have to apply for every DevOps team, or that exceptions may arise. Security and DRCP will discuss that accordingly, depending on what comes in.
| Last, but not least, if a new DRS releases and contains certain changes, DRCP will coordinate it with Security again. If existing DRS rules or policies changes, the CCC informs DevOps teams.

**Follow up:**
Tune the DRS rules as mentioned accordingly and so, apply it in the WAF.
Also when the DRS changes (when a new version becomes available), start to test in DTA usages, so that there is time to troubleshoot and adapt new changes. Then migrate to production.

Extra rule sets
^^^^^^^^^^^^^^^
| A DevOps team can add extra rule sets to the WAF policies, for example the `bot protection rule set <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection>`__.
| The DevOps team will choose which rule set or rules are applicable for their application. Be aware that DRS is the bare minimum.

**Follow up:**
Determine whether it makes sense and adds value to your application to activate rule sets to make your application (landscape) more secure.

Custom rules and exclusions
^^^^^^^^^^^^^^^^^^^^^^^^^^^
| WAF offers the use of `custom rules <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/custom-waf-rules-overview>`__ and `exclusions <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-waf-configuration?tabs=portal>`__, but these can avoid or override the mandatory rules in the DRS.
| By disabling or whitelisting rules, the DRS rules no longer have any effect. That's why DRCP prevents using it.
| One exception in the use of custom rules is rate limit. Choose rule type rate limit to take advantage of its `functionality <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/rate-limiting-overview>`__.

Prevention and detection mode
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| The WAF has two modes of operation: `detection and prevention <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview#waf-modes>`__.
| Detection mode doesn't block anything but logs malicious activity. Prevention mode blocks malicious traffic and logs as well.

**Follow up:**
APG policy requires prevention mode in production usages to limit the risks of vulnerabilities.
In DTA usages it's possible to use prevention and detection mode for analyse purposes and prevent false positives.

Dedicated subnet
^^^^^^^^^^^^^^^^
| It requires a dedicated subnet that can contain solely Application Gateways, so don't use this subnet for other resources.
| Please visit this `link <https://learn.microsoft.com/en-us/azure/application-gateway/quick-create-portal#create-an-application-gateway>`__ for more information.

Frontend configuration
^^^^^^^^^^^^^^^^^^^^^^
| Application Gateway requires a public and private IP address by default.
| To prevent public use, the frontend IP configuration allows the use and configuration of the private IP address for the associated listener. The use of public IP address isn't allowed by policy.

**Follow up:**
Create a new public IP address and configure the subnet with a useable private IP address. Then let the public IP address unused.

.. note:: That a fully private Application Gateway is still in `preview <https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-private-deployment?tabs=portal>`__ that doesn't require a public IP address. Because of it's preview status it may contain bugs and for that reason not suitable for production usages.

.. note:: Keep in mind that the public IP isn't used but does incur `costs <https://azure.microsoft.com/en-us/pricing/details/ip-addresses/>`__.

Encryption
^^^^^^^^^^
Encrypted traffic on the Frontends and the Backends is APG policy and therefor DRCP enforces HTTPS as protocol on the ``Listeners`` and the ``Backend targets`` configurations. The HTTP protocol isn't allowed.

**Follow up:**
| Keep in mind that DevOps teams need to request SSL certificates in ServiceNow. ``Frontend`` and ``Backend`` configuration require a SSL certificate and the required place to store and manage certificates is Azure Key Vault.
| Use the available Key Vault `integration <https://learn.microsoft.com/en-us/azure/application-gateway/key-vault-certs>`__ and don't upload certificates manually.

Zone redundancy
^^^^^^^^^^^^^^^^
DRCP requires the use of `zone redundancy <https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-autoscaling-zone-redundant>`__ to achieve zonal failure resiliency, and so limit downtime as much as possible.

**Follow up:**
During deployment keep in mind to configure zone 1, 2, and 3 for the zone redundancy setting.

`An example how to configure it <https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-autoscale-ps>`__
