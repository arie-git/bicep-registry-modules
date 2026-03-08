Incident remediation Container Registry
=======================================

.. |AzureComponent| replace:: Container Registry
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-cr-01
     - Anonymous authentication.
     - Ensure to configure the boolean property ``anonymousPullEnabled`` to ``false`` to disable anonymous authentication.

   * - drcp-cr-02
     - ARM audience token authentication.
     - Ensure to disable the ARM audience token authentication

   * - drcp-cr-03
     - Local administrator account.
     - Ensure to configure the boolean property ``adminUserEnabled`` to ``false`` to disable the local administrator account.

   * - drcp-cr-04
     - Public network access.
     - Ensure to configure the property ``publicNetworkAccess`` to ``Disabled`` to disable public network access. Also, ensure to either remove the default action in the network rule set, or set it to ``Deny`` instead of ``Allow``.

   * - drcp-cr-05
     - Repository scoped access token.
     - Ensure to disable the use of repository scoped access tokens.

   * - drcp-cr-06
     - Disable exports.
     - DRCP denies exporting data from container registries.

   * - drcp-cr-08
     - Private endpoints.
     - When deploying a private endpoint that belongs to a container registry, clear the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ since DRCP policies remediate this configuration.

   * - drcp-cr-09
     - Connected Registries.
     - DRCP denies the usage of ``connectedRegistries``. You can use a change process that runs via a workflow, pipeline or other means.
