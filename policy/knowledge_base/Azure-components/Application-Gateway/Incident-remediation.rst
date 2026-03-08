Incident remediation Application Gateway
========================================

.. |AzureComponent| replace:: Application Gateway
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-agw-01
     - Frontend IP configuration.
     - Public access to Application Gateway isn't allowed. Remove any public IP address entries in the frontend IP configurations.

   * - drcp-agw-02
     - ``Backend settings``.
     - Ensure that the `request routing rules <https://learn.microsoft.com/en-us/azure/application-gateway/configuration-request-routing-rules>`__ contain a ``Backend settings`` with a secure protocol.

   * - drcp-agw-03
     - Listeners.
     - Ensure to configure the `listeners <https://learn.microsoft.com/en-us/azure/application-gateway/configuration-listeners>`__ with a secure (HTTPS) protocol.

   * - drcp-agw-04
     - Application Gateway SKU.
     - Ensure the selected SKU is either ``Standard_V2`` or ``WAF_v2``. Other SKUs aren't supported by DRCP.

   * - drcp-agw-05
     - WAF policy state.
     - Ensure to enable the `Web Application Firewall <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-web-application-firewall-portal>`__ functionality.

   * - drcp-agw-06
     - WAF mode.
     - Ensure to configure the `WAF mode <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/ag-overview#waf-modes>`__ to ``Prevention`` for Production usage environments. Other usages also allow ``Detection`` mode.

   * - drcp-agw-07
     - Custom rules and exclusions.
     - Ensure to include custom rules if they're of the rule type rate limit, other rule types aren't allowed <https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/create-custom-waf-rules>`__.

   * - drcp-agw-08
     - Rule sets.
     - Ensure to configure the managed rule set to ``Microsoft_DefaultRuleSet`` and version ``DRS 2.1``.

   * - drcp-agw-09
     - Rule sets.
     - Ensure to enable the managed rule set. See remediation info at ``drcp-agw-08``.

   * - drcp-agw-10
     - DRS rules.
     - Ensure to tune the managed rule set. See remediation info at ``drcp-agw-08``.

   * - drcp-agw-11
     - Application Gateway TLS policy.
     - Ensure the Application Gateway is always deployed with a predefined Microsoft policy that uses at least TLS version 1.2.
