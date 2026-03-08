Security baseline Application Gateway Web Application Firewall
==============================================================

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
     - July 21, 2023
     - Ivo Huizinga
     - Initial version.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.
   * - 1.1
     - October 28, 2024
     - Raymond Smits
     - Added baseline control ``drcp-agw-11``.

.. |AzureComponent| replace:: Application Gateway
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

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
   * - drcp-agw-01
     - Frontend IP configuration
     - Application Gateway doesn't `support the use of private IP address <https://learn.microsoft.com/en-us/azure/application-gateway/configuration-frontend-ip#public-and-private-ip-address-support>`__ without configuring a Public IP address. DevOps teams needs to configure a public and, private IP address, but that doesn't mean they need to use the public IP for the listener. With this policy, DRCP ensures that the listener doesn't use any public IP.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and check (audit) whether the configured associated listener uses the Public IP address.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-02
     - ``Backend settings``
     - To function, an Application Gateway needs at least one ``Backend settings`` connected to a rule. Options are protocol, port, cookie-based affinity and connection draining for instance. DRCP enforces a policy to make sure the connection always uses a secure protocol.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny applying ``Backend settings`` with HTTP as protocol enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-03
     - Listeners
     - A `listener <https://learn.microsoft.com/en-us/azure/application-gateway/configuration-listeners>`__ is a logical entity that checks for incoming connection requests by using the port, protocol, host, and IP address. When you configure the listener, you must enter values for these that match the corresponding values in the incoming request on the gateway.

       To make sure that the traffic between the client and listener encrypts, the secure protocol will enforce by policy. Keep in mind that DevOps teams needs to think about SSL certificates and may choose to use Azure Key Vault.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and deny applying a HTTP listener as protocol.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-04
     - Application Gateway SKU
     - It offers 4 available SKUs but some of them will `deprecate <https://learn.microsoft.com/en-us/azure/application-gateway/migrate-v1-v2>`__ or doesn't include WAF, like the V1 versions.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy to prevent other SKUs than Standard V2 and WAF v2.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-11
     - Application Gateway TLS policy
     - DRCP expects DevOps teams to use at least TLS protocol version 1.2 to keep up with the latest security rules.
     - L
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy to prevent using a TLS version older then 1.2.
     - Microsoft Defender for Cloud. Compliant policy.

These policies are WAF specific:

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
   * - drcp-agw-05
     - WAF policy state
     - It's possible to disable the WAF policy functionality.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and make sure the WAF policy state stays enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-06
     - WAF mode
     - The WAF has two modes in which it operates: detection and prevention. In detection none of the rules are blocking requests, so typically it's used in DTA usages for testing and troubleshoot purposes. The prevention mode blocks traffic based on rules (sets).
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and enforce prevention mode on production usages. DevOps teams can use both usages in DTA usages.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-07
     - Custom rules and exclusions
     - Custom rules override the default rule sets provided by the WAF, allowing DevOps teams bypassing mandatory rules, which is why DRCP prevents the use of custom rules and exclusions, unless when the rule type includes a rate limit.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy to prevent custom rules and exclusions, unless when the rule type includes a rate limit.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-08
     - Rule sets
     - A variety of `rule sets <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules>`__  are available to choose from, but DRCP expects DevOps teams to use at least DRS 2.1 to keep up with the latest security rules.
       It must be possible for DevOps teams to use the `bot <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection>`__  rule set addition to the DRS.
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and enforce the default rule set, DevOps teams may use other sets too.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-09
     - Rule sets
     - Rule sets can disable as a group; DevOps teams can use this to bypass the rules in it, so for this reason DRCP prevents disabling the DRS rule set (as mentioned).
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce the policy and prevent the disabling of the default rule set.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-agw-10
     - DRS rules
     - To prevent false-positivies or avoid double rules, DevOps teams needs the ability to tune the DRS and so disable/enable certain rules or change it's status. `The following rules are optional to disable. <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules?tabs=drs21%2Cowasp30#default-rule-set-21>`__
     - H
     - C = 1/3
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy which enables certain rules in the DRS to change it's state or status.
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt