Incident remediation App Service
================================

.. |AzureComponent| replace:: App Service
.. include:: ../../_static/include/incident-remediation-header.txt

.. list-table::
   :widths: 8 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-aps-01
     - Disable public network access.
     - Disable public network access to the App Service app and `use a private endpoint <https://learn.microsoft.com/en-us/azure/app-service/overview-private-endpoint>`__.

   * - drcp-aps-02
     - Enforce HTTPS.
     - Enforce HTTPS by configuring the property ``httpsOnly`` boolean to ``true``.

   * - drcp-aps-03
     - Enforce HTTP 2.0.
     - Enforce HTTP version 2.0 by configuring the property ``https20Enabled`` boolean to ``true``.

   * - drcp-aps-04
     - Deny lower / legacy TLS versions.
     - Ensure the configured TLS version is at least ``1.2`` by configuring the property ``minTlsVersion``.

   * - drcp-aps-05
     - Deny public network access to App Service Environments.
     - Ensure to configure the App Service Environment instance with its internal load balancer (property ``internalLoadBalancingMode`` shouldn't contain ``2``, ``3``, ``Web`` or ``Publishing``) and an IP address in a virtual network.

   * - drcp-aps-06
     - Deny lower / legacy TLS versions on App Service Environments.
     - Ensure that the App Service Environment instance doesn't use lower / legacy TLS versions by `configuring the cluster settings <https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#change-tls-cipher-suite-order>`__.

   * - drcp-aps-07
     - Deny Cross-Origin Resource Sharing (CORS) from all domains.
     - Don't allow all domains to access the app with Cross-Origin Resource Sharing (CORS) (property ``web.cors.allowedOrigins``). Restrict interaction with your app to required domains.

   * - drcp-aps-08
     - Audit for injection of App Service apps into a virtual network.
     - Ensure that the App Service app `integrates in a virtual network <https://learn.microsoft.com/en-us/azure/app-service/configure-vnet-integration-enable>`__ (properties ``hostingEnvironmentProfile.id`` and ``virtualNetworkSubnetId``).

   * - drcp-aps-09
     - Audit for enabling of configuration routing of App Service apps.
     - Ensure that the App Service app `routes to the Azure Virtual Network <https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration#application-routing>`__ by configuring boolean properties ``vnetImagePullEnabled`` and ``vnetContentShareEnabled`` to ``true``.

   * - drcp-aps-10
     - Audit for enabling outbound non-RFC 1918 traffic to Azure Virtual Network.
     - Ensure that all outbound traffic originating from the App Service app `routes to the Azure Virtual Network <https://learn.microsoft.com/en-us/azure/app-service/overview-vnet-integration#application-routing>`__ by configuring the boolean property ``vnetRouteAllEnabled`` to ``true``.

   * - drcp-aps-11
     - Deny FTP access.
     - Ensure to disable FTP access to the App Service app (property ``ftpsState``). Environments with usage Development allow secure FTP (value ``FtpsOnly``).

   * - drcp-aps-12
     - Deny local authentication methods for FTP and SCM deployments to App Service.
     - Ensure to disable local authentication methods (require Microsoft Entra ID identities for authentication, property ``basicPublishingCredentialsPolicies``). Learn more `here <https://aka.ms/app-service-disable-basic-auth>`__.

   * - drcp-aps-13
     - Deny lack of internal encryption of App Service Environments.
     - Configure the property ``InternalEncryption`` in the `cluster settings <https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings>`__ of the App Service Environment instance to true encrypts the page file, worker disks, and internal network traffic between the front ends and workers.

   * - drcp-aps-14
     - Deny weak TLS Cipher suites in App Service Environments.
     - Ensure that the App Service Environment instance doesn't use lower / legacy TLS versions by `configuring the cluster settings <https://learn.microsoft.com/en-us/azure/app-service/environment/app-service-app-service-environment-custom-settings#change-tls-cipher-suite-order>`__.

   * - drcp-aps-15
     - Audit for legacy App Service Environment versions.
     - Ensure to configure the property ``Kind`` to ``ASEV3``. Older versions are no longer available.

   * - drcp-aps-16
     - Audit for enabling of remote debugging.
     - Ensure to configure the property ``web.remoteDebuggingEnabled`` to ``false`` on App Service apps.

   * - drcp-aps-17
     - Audit for latest version of application framework.
     - DRCP restricts the use of App Service programming languages and their versions to the specified list on the :doc:`Use cases App Service article <Use-cases>`.

   * - drcp-aps-18
     - Deny anonymous authentication.
     - Ensure to configure the boolean property ``siteAuthEnabled`` to ``true`` on App Service apps.

   * - drcp-aps-19
     - Audit for managed identity.
     - Ensure to configure a managed identity for the App Service app.

   * - drcp-aps-20
     - Microsoft Defender for Cloud.
     - Ensure to enable `Defender for Azure App Service <https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-app-service-introduction>`__.