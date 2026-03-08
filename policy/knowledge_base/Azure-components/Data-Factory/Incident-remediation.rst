Incident remediation Data Factory
=================================

.. |AzureComponent| replace:: Data Factory
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-adf-01
     - Establish network segmentation boundaries.
     - Ensure to use a Self-Hosted integration runtime. Microsoft-managed integration runtimes aren't allowed by DRCP.

   * - drcp-adf-02
     - Disable public network inbound access for Self-Hosted Integration Runtimes.
     - Ensure to disable public network access (configure property ``publicNetworkAccess`` to ``Disabled``).

   * - drcp-adf-03
     - Ensure access to Azure Data Factory portal from APG network is via a private network.
     - Under construction. See the security baseline of this component for more information.

   * - drcp-adf-04
     - Restrict the exposure of credential and secrets.
     - See the details at corresponding control id on the security baseline of this component for more information.

   * - drcp-adf-05
     - Use approved data services.
     - Ensure to use data services listed in the allowed linked service types (see input parameter ``allowedLinkedServiceResourceTypes`` of policy ``APG DRCP Data Factory Linked service should be in the whitelist of allowed linked services``. DRCP denies services that aren't listed.

   * - drcp-adf-06
     - Ensure DevOps way-of-working suitable for ADF.
     - Ensure to use Data Factory together with Azure DevOps as described on the :doc:`Use cases Data Factory article <Use-cases>`.

   * - drcp-adf-07
     - Purview integration isn't allowed.
     - Ensure to clear any configuration containing a link to Purview.
