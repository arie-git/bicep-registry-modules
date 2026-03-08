Use cases Data Factory
======================

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Data Factory
------------------

Azure Data Factory requires Self Hosted Integration Runtime (SHIR) . Use a SHIR to connect to data sources in an on-premises network or a virtual network.

The installation of the self-hosted integration runtime requires an on-premise machine or a virtual machine inside a private network.

To use Azure Data Factory in APG, a self-hosted integration runtime needs an on-premise (Landing zone 2 - DRDC) virtual machine.

.. warning:: The `Azure Hosted Integration Runtime <https://learn.microsoft.com/en-us/azure/data-factory/create-azure-integration-runtime?tabs=data-factory>`_ with `managed virtual network <https://learn.microsoft.com/en-us/azure/data-factory/managed-virtual-network-private-endpoint>`_ isn't available in the MVP phase. If you require managed VNet integration, you can fill in a feature request for the DRCP platform.

To do and not to do
-------------------

1. APG doesn't allow public connections. Public connection between Azure Data Factory (ADF) and Integration Runtime (IR) isn't supported.
2. APG supports self-hosted integration runtimes.
3. Data flows aren't supported.

.. warning:: If Data Flow is mandatory, please create a feature request for this with the DRCP team.

Setting up self-hosted integration runtime
------------------------------------------

Provision a virtual machine in LZ2
##################################

Self-hosted integration runtime requires a Windows virtual machine in the Landing zone 2 (`DRDC <https://apgprd.service-now.com/drdc?id=drdc_dashboard>`_). Follow below steps for the provisioning.


Application system
******************
Make sure your Application system allows to create a virtual machine in Landing zone 2.

Environment
***********
Create an environment in the DRDC portal. For creating an environment you need to provide following details:

.. list-table::
   :widths: 10 25
   :header-rows: 1

   * - Requested for
     - Portal populates the name of the requester by default. It's possible to change the name of requester.

   * - Application systems
     - Select the appropriate Application system

   * - Usage
     - Select one of the options depending on the intended use

   * - Select Landing zone
     - Select 'Landing zone 2'

   * - Approval Group
     - Select the appropriate Approval group from the list. Make sure to use the approval group named after your Application system. For example, for an Application system named 'CloudCompetenceCenter' use 'Approval CloudCompetenceCenter'.

   * - Code
     - Provide a code, this will appear as part of the name of the environment

   * - Change date
     - POrtal populated to the current date

   * - Description
     - Provide a description

Request Virtual Machine
************************
Request Virtual machine from the Environment created in the preceding steps. You need to request **Managed Windows Server v1**.

You have to first generate the `configuration file <https://confluence.office01.internalcorp.net:8453/display/DRDCKB/Create+a+configuration+file>`__ in DRDC portal for the windows server. You can use below sample configuration file to generate the configuration file.

.. code-block:: XML

    {
      "addons": {},
      "firewallrules": [
        {
          "protocol": "TCP",
          "port": "3389",
          "service_name": "rdp",
          "service_full_description": "to allow remote login using rdp",
          "service_short_description": "to allow rdp",
          "direction": "in"
        }
      ],
      "services": []
    }

Follow the `Request a server <https://confluence.office01.internalcorp.net:8453/display/DRDCKB/Request+a+server>`__ instruction on the `DRDC KB <https://confluence.office01.internalcorp.net:8453/display/DRDCKB>`__ to request a Managed Windows Server.

DRDC automates the process to request a windows virtual machine. After submitting the request, you can track the progress of your request in the DRDC portal.


How to setup self-hosted integration runtime application
########################################################

After provisioning of the windows virtual machine and available to use, use remote desktop application and provide the IP address of the virtual machine to remotely connect.


Install OpenJDK
***************
Determine whether the JDK installed in the virtual machine. If the JDK isn't installed then download the OpenJDK and install it manually.

.. note:: Install Java Runtime (JRE) version 11 from a JRE provider such as `Microsoft OpenJDK <https://download.visualstudio.microsoft.com/download/pr/b84fb0a4-aeb3-459d-929f-32355124f965/60cbca5371a7e829ae182cbd7c1e1c61/microsoft-jdk-11.0.21-windows-x64.msi>`_ 11 or `Eclipse Temurin 11 <https://adoptium.net/temurin/releases/?version=11>`_ . Ensure that the JAVA_HOME system environment variable set to the JDK folder (not just the JRE folder). You may also need to add the bin folder to your system's PATH environment variable.

Install Integration Runtime Application
***************************************
You have to download the integration runtime and install it manually. Download the latest version from `Microsoft Integration Runtime downloads <https://www.microsoft.com/en-us/download/details.aspx?id=39717>`_

Firewall Rule
*************
You have to raise a request in ServiceNow to add firewall rules.

`ServiceNow > Infrastructure Catalogue > Security Services > Request Firewall rules <https://apgprd.service-now.com/now/nav/ui/classic/params/target/com.glideapp.servicecatalog_cat_item_view.do%3Fv%3D1%26sysparm_id%3D29f13edcdb8c3410b00a5bd05b961908>`_

While requesting firewall rule these are the questions involved:

* Which ServiceNow group manages the rule?
* Is there a CHANGE number involved?
* Is there a security consultant involved?

Make sure add following firewall rules :

.. list-table::
   :widths: 10 15 30 10 10 10 10 30
   :header-rows: 1

   * - Action
     - Source
     - Destination
     - Protocol
     - Application Protocol
     - Rule action
     - Ports
     - Note

   * - Add
     - Provide Name of windows server
     - ``\*.servicebus.windows.net (mimemeld-servicebus.swedencentral)``
     - TCP
     - HTTPS
     - Allow
     - 443
     - Required by the self-hosted IR for interactive authoring

   * - Add
     - Provide Name of windows server
     - ``\*.core.windows.net``
     - TCP
     - HTTPS
     - Allow
     - 443
     - Used for copy through Azure Blob ADLS

   * - Add
     - Provide Name of windows server
     - ``\*.swedencentral.datafactory.azure.net``
     - TCP
     - HTTPS
     - Allow
     - 443
     - Used for data factory

Firewall rules
**************
The preceding firewall rule will make sure that Azure data factory works with self-hosted integration runtime. An application team will need to create separate firewall requests to arrange access to data sources and data destination.
