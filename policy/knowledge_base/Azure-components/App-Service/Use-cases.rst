Use cases App Service
=====================

.. include:: ../../_static/include/component-usecasepage-header.txt

.. warning:: Limited :doc:`Azure Availability Zones support <../../Platform/Azure-availability-zones-support>` applies.

App Service
------------
| Azure App Service is the name of a collection of HTTP-based services for hosting web applications, REST APIs, and mobile back ends. It supports programming and scripting languages, for example (but not limited to) .NET, .NET Core, Java, Node.js, PHP, and Python.
| Applications run and scale on both Windows and Linux-based environments, and has built-in support for load balancing, autoscaling, and automated management.
| The chosen App Service plan (`Premium V3` for `multi-tenant` or `IsolatedV2` for the use of an App Service environment) determines the billing. This billing captures compute resource settings and functionality, with possible fees or network traffic.

See `<https://learn.microsoft.com/en-us/azure/app-service/overview>`__.

Scope
^^^^^
See article :doc:`Security baseline App Service <Security-Baseline>` for an actual overview of the scope of this component.

Use cases and follow-up
-----------------------

Allowed runtime languages
^^^^^^^^^^^^^^^^^^^^^^^^^
| DRCP allows runtime language versions which still have support for security patching by their respective vendors. DRCP reviews language versions of the mentioned language by App Service kind, so either Web App or Function App. And also the operating system these components run on, so either Linux or Windows.
| DRCP also makes a distinction per operating system in relation to allowed runtime language versions.

.. note:: DRCP reviews these languages every quarter to keep up-to-date with supported App Service runtime languages. Last updated December 16, 2025.

| Allowed versions:

.. vale Microsoft.Acronyms = NO

Web App
"""""""
| LinuxFX:

- "DOTNETCORE|10.0"
- "DOTNETCORE|9.0"
- "DOTNETCORE|8.0"
- "NODE|24-lts"
- "NODE|22-lts"
- "NODE|20-lts"
- "PYTHON|3.14"
- "PYTHON|3.13"
- "PYTHON|3.12"
- "PYTHON|3.11"
- "PYTHON|3.10"
- "PHP|8.4"
- "PHP|8.3"
- "JAVA|21-java21"
- "JAVA|17-java17"
- "JAVA|11-java11"
- "JAVA|8-jre8"
- "TOMCAT|11.0-java21"
- "TOMCAT|11.0-java17"
- "TOMCAT|10.1-java21"
- "TOMCAT|10.1-java17"
- "TOMCAT|10.1-java11"
- "TOMCAT|9.0-java21"
- "TOMCAT|9.0-java17"
- "TOMCAT|9.0-java11"
- "TOMCAT|9.0-jre8"

| Windows:

- "dotnet:10"
- "dotnet:9"
- "dotnet:8"
- "ASPNET:V4.8"
- "ASPNET:V3.5"
- "NODE:22LTS"
- "NODE:20LTS"
- "NODE:18LTS"
- "JAVA:21"
- "JAVA:17"
- "JAVA:11"
- "JAVA:8"
- "TOMCAT:11.0-java21"
- "TOMCAT:11.0-java17"
- "TOMCAT:10.1-java21"
- "TOMCAT:10.1-java17"
- "TOMCAT:10.1-java11"
- "TOMCAT:9.0-java21"
- "TOMCAT:9.0-java17"
- "TOMCAT:9.0-java11"
- "TOMCAT:9.0-java8"

Function App
""""""""""""
| Linux:

- "DOTNET-ISOLATED|10.0"
- "DOTNET-ISOLATED|9.0"
- "DOTNET-ISOLATED|8.0"
- "Node|24"
- "Node|22"
- "Node|20"
- "Python|3.14"
- "Python|3.13"
- "Python|3.12"
- "Python|3.11"
- "Python|3.10"
- "Java|25"
- "Java|21"
- "Java|17"
- "Java|11"
- "Java|8"
- "PowerShell|7.4"

| Windows:

- "dotnet-isolated 10"
- "dotnet-isolated 9"
- "dotnet-isolated 8"
- "dotnet 8"
- "node 24"
- "node 22"
- "node 20"
- "java 25.0"
- "java 21.0"
- "java 17.0"
- "java 11.0"
- "java 8.0"
- "powershell 7.4"

.. vale Microsoft.Acronyms = YES

Azure App Service supports a limited set of built-in Azure roles that provide different levels of permissions.

Authentication
^^^^^^^^^^^^^^
When accessing an app, clients must authenticate themselves to the app.
DRCP requires authentication for every app. For internal APG use, use the Microsoft Entra ID authentication. Create a service principal for each app, see :doc:`Microsoft Entra Service Principals <../../Platform/Microsoft-Entra-ID/Service-principals>`.

DRCP prefers to following order of authentication:

- system assigned managed identities
- user assigned managed identities
- app registrations
- users

Authorization
^^^^^^^^^^^^^
Azure App Service supports a limited set of built-in Azure roles that provide different levels of permissions.
See :doc:`Role Based Access Control policy <../Subscription/Role-Based-Access-Control-policies>` for the use of RBAC within the DRCP platform.

Artifactory integration
^^^^^^^^^^^^^^^^^^^^^^^
| According to APG policy, DevOps teams have to scan all software for vulnerabilities. Use Artifactory for the vulnerability scanning.
| Do this by uploading all software to Artifactory in the Azure DevOps pipeline or by connecting from the app to Artifactory to download the software directly to the app.

Certificates
^^^^^^^^^^^^
| If the App Service needs to access an on premises application secured with a private certificate, you need to upload the client certificate chain to the App Service. Because a CA01 root certificate is always self-signed, you need to upload the root of the certificate chain to the LocalMachineMy location. For this scenario, use an App Service Environment to host the app.
| See `Certificates in App Service Environment <https://learn.microsoft.com/en-us/azure/app-service/environment/overview-certificates>`__.

Networking
^^^^^^^^^^
| The APG security baseline requires the use of private endpoints for Azure App Service and blocks public access.
| DNS is a shared service over all Application systems. DRCP automates this to avoid intervention cross Application systems.

**Private endpoint DNS automation**

Private endpoints belonging to App Service apps can register in private DNS zone ``azurewebsites.net`` or ``appserviceenvironment.net``, based on their domain suffix. The DRCP policy ``APG DRCP App Service Site Network Private DNS zones`` recognizes the domain suffix used by the app, and completes (remediates) the `Private DNS zone configuration <https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns-integration>`__ to the corresponding private DNS zone.

.. note:: The preceding information limits to the app private endpoints. The inbound IP addresses of App Service Environment instances are out of scope for this automation. You can use :doc:`this API <../../Platform/DRCP-API/Endpoint-for-dns-assignment>` to register DNS records (A and CNAME) for the ``appserviceenvironment.net`` zone.

Lifecycle
^^^^^^^^^^^^
Azure App Service follows the LCM process of Microsoft.

**Software versions**
DevOps teams are responsible for the LCM of the used software versions.

Known limitations
-----------------
Function App and Logic App
^^^^^^^^^^^^^^^^^^^^^^^^^^
Function Apps and Logic Apps need to connect to a Storage Account within the same Environment/Subscription. By default, the Function App uses SAS keys to establish this connection. The Storage Account security baseline enforces a policy that disallows shared key access: ``APG DRCP Storage Account Shared Key Access should be disabled``. This policy, combined with the connectivity need, creates a conflict.

To resolve the conflict for both the Function App and Logic App, assign a tag to the Storage Account. Use the following settings for FunctionApp Name: ``UsedBy``, Value: ``FunctionApp`` or for LogicApp Name: ``UsedBy``, Value: ``LogicApp``.

note: You can assign a tag, either FunctionApp or LogicApp, to a Storage Account. Using both tags on the same Storage Account isn't not allowed.

.. warning:: Use this tag for its intended purpose. Using it otherwise isn't allowed.

Static Web App
^^^^^^^^^^^^^^
Please note that Microsoft determines a random partition id for Static Web App instances, and you can't configure it upfront or post-deployment.

For example, within FQDN ``mango-forest-07f93ac03.privatelink.5.azurestaticapps.net``, ID **5** applies.

The DRCP remediation policy ``APG DRCP App Service Static Sites Private DNS zones`` retrieves this partition id during private endpoint deployment to complete the private DNS zone registration to the appropriate DNS zone in the hub.

.. note:: As for the data center region and the time of writing this article, Microsoft doesn't support region 'Sweden Central' for this component. DRCP allows region 'West Europe' for deployment of the resource type ``Microsoft.Web/staticSites``. Please note that the private endpoint still needs to deploy in the region that belongs to the environment (region 'Sweden Central' for environments created after :doc:`DRCP Release 24-2 04 <../../Release-notes/Older-release-notes/Release-24-2-04>`).