Release 24-3 02
===============
Release date: July 16, 2024

.. warning:: Upcoming breaking change: DRCP will harden Azure Disk by denying unattached disks to align with corporate policy and DRCP environment design in upcoming releases this PI. See the linked feature to learn when DRCP releases the related Azure policies for which usage. `[ISF-6574] <https://jira.office01.internalcorp.net:8443/browse/SAA-6574>`__

.. warning:: Upcoming breaking change: DRCP releases policy ``APG DRCP Azure Disk creation is not allowed`` with effect 'Deny' for usages Developent and Test next release (r24-3 03). `[SAA-8298] <https://jira.office01.internalcorp.net:8443/browse/SAA-8298>`__

.. warning:: Breaking change: During this release, DRCP removes the component **API Management**. `[SAA-7705] <https://jira.office01.internalcorp.net:8443/browse/SAA-7705>`__

.. warning:: Breaking change: During the release on July 30th, DRCP will deny the adding of BGP community strings to Virtual Networks. `[SAA-8189] <https://jira.office01.internalcorp.net:8443/browse/SAA-8189>`__


Fixed issues
------------
- Improved the "Add Private Link Service id" information on the :doc:`Quick Actions page <../../Platform/DRDC-portal/Quick-actions>`. `[SAA-8743] <https://jira.office01.internalcorp.net:8443/browse/SAA-8743>`__
- Improved the RBAC policies information on the :doc:`Role Based Access Control policies page <../../Azure-components/Subscription/Role-Based-Access-Control-policies>`. `[SAA-8596] <https://jira.office01.internalcorp.net:8443/browse/SAA-8596>`__
- Fixed Databricks collector for use in Sweden Central. `[SAA-8767] <https://jira.office01.internalcorp.net:8443/browse/SAA-8767>`__
- Fixed baseline reporting from Azure DevOps to ServiceNow. `[SAA-8778] <https://jira.office01.internalcorp.net:8443/browse/SAA-8778>`__
- Fixed approval flow for ``Enable Mule`` Quick action in ServiceNow. `[SAA-8810] <https://jira.office01.internalcorp.net:8443/browse/SAA-8810>`__

What's new for users
--------------------
- Added :doc:`Incident remediation page for Azure DevOps security controls <../../Application-development/Azure-devops/Incident-remediation>`. `[SAA-8238] <https://jira.office01.internalcorp.net:8443/browse/SAA-8238>`__
- Added :doc:`Azure DevOps security baseline <../../Application-development/Azure-devops/Security-baseline>` to the KB. `[SAA-8238] <https://jira.office01.internalcorp.net:8443/browse/SAA-8238>`__
- Removed the component ``API Management``. `[SAA-7705] <https://jira.office01.internalcorp.net:8443/browse/SAA-7705>`__
- Reviewed the component ``App Service`` and updated the documentation. `[SAA-7775] <https://jira.office01.internalcorp.net:8443/browse/SAA-7775>`__
- Removed the ASEv1 and ASEv2 allowed values from ``APG DRCP App Service Environment Allowed versions`` * policy definition. `[SAA-7787] <https://jira.office01.internalcorp.net:8443/browse/SAA-7787>`__
- Added use case documentation about :doc:`Azure Service Bus <../../Azure-components/Service-Bus/Use-cases>`. `[SAA-6704] <https://jira.office01.internalcorp.net:8443/browse/SAA-6704>`__
- Updated the Web App language version ``APG DRCP App Service Site [language] version`` policies for Java, PHP and Python to ``APG DRCP App Service Site Linux [language] version``. `[SAA-7424] <https://jira.office01.internalcorp.net:8443/browse/SAA-7424>`__
- Updated the Web App language version ``APG DRCP App Service Site Slot [language] version`` policies for Java, PHP and Python to ``APG DRCP App Service Site Slot Linux [language] version``. `[SAA-7424] <https://jira.office01.internalcorp.net:8443/browse/SAA-7424>`__
- Removed unsupported language versions for Web Apps from :doc:`Use cases App Service <../../Azure-components/App-Service/Use-cases>` of the KB. `[SAA-7424] <https://jira.office01.internalcorp.net:8443/browse/SAA-7424>`__
- Added policy ``APG DRCP Network disable BGP community strings`` which audits for BGP community configurations on Virtual Networks. `[SAA-8189] <https://jira.office01.internalcorp.net:8443/browse/SAA-8189>`__
- Implemented policy ``APG DRCP Azure Disk creation is not allowed`` to prevent the creation of Azure Disk, because IAAS isn't supported. `[SAA-8268] <https://jira.office01.internalcorp.net:8443/browse/SAA-8268>`__
   - Policy configured with 'Audit' effect for all usages for now.
   - Policy effect changes to 'Deny' for Development and Test usages during next release (r24-3 03). `[SAA-8298] <https://jira.office01.internalcorp.net:8443/browse/SAA-8298>`__
   - Other usages (Acceptance and Production) follow with a phased roll out (configure to 'Deny' effect).
- Prepped :doc:`Subscription security baseline documentation <../../Azure-components/Subscription/Subscription-Baseline>` with deny on Azure Disk creation. `[SAA-8263] <https://jira.office01.internalcorp.net:8443/browse/SAA-8263>`__
- Updated :doc:`Roles and authorizations <../../Getting-started/Roles-and-authorizations>` with permissions for ServiceNow. `[SAA-8810] <https://jira.office01.internalcorp.net:8443/browse/SAA-8810>`__
