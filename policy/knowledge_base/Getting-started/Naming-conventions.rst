Naming conventions
==================

.. contents::
   Contents
   :local:
   :depth: 2

Introduction
------------

| Organizing cloud-based assets in ways that aid operational management and support accounting needs is a common challenge in large cloud adoption efforts.
| By applying well-defined naming and metadata tagging conventions to cloud-hosted resources, IT staff can find and manage resources in case of incident or a security issue.
| Well-defined names and tags can also help to align cloud usage costs with business teams by using chargeback and show back accounting mechanisms.
| Within DRCP these mechanisms use the tags set on components, not the resource names.

Management summary
------------------

The proposed choice recommends one naming convention when naming resources, instead of everyone choosing their own naming convention.

.. Note::

   DRCP recommends to use the naming convention below, which is partly based on Microsofts `Cloud Adoption Framework <https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/>`__. This includes using tools like the `Azure Naming Tool <https://aka.ms/AzureNamingTool>`__.

Why the need for a naming standard
----------------------------------

You can't rename Azure resources, hence they must follow a naming convention:

* To attach the brand name of an organization.
* To identify resources uniquely across on-premises and cloud environments.
* To identify resource BU unit / Subscription / resource group.
* To find out geographical location of a resource.
* Efficiently locate the resource from the logs during troubleshooting.
* To automate the management of resources.

Resource naming convention
--------------------------

What should a resource name made-up of
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Organization information (for example name, department code etc).
* Prefix or suffix to determine the resource type (for example ``sa``, ``sql``, ``vm``, ``df``, ``dbw``).
* Application or service or role name.
* Application usage (for example DTAP).
* Uniqueness (must for PaaS resource types, globally):
   * Though some IaaS components are resource group scoped, their name needs to be uniquely identifiable. For example a virtual machine name resolves using DNS.
* Location (preferably abbreviation for example ``sc`` instead of sweden-central).
* Sequence number:
   * It needs logic to generate next sequence number.
* Uniform casing (preferably lower casing).
* Should be within the Azure naming limits for example alphanumeric, only hyphens and underscores, name length limit varies per resource type.
* Each name should start with a letter and avoid reserved words in the name.

Parts of the name
~~~~~~~~~~~~~~~~~

In the context of DRCP, this is the recommendation:

``[<prefix>]<org><purpose = [department]+application/workload+role/function><usage><location><resource type>[<suffix>]``

+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field                   | Explanation                                                                                                                                                                                                    |
+=========================+================================================================================================================================================================================================================+
| Prefix                  | Optional. A string of characters and numbers, used in CI pipelines to add uniqueness in naming.                                                                                                                |
|                         | It can be a branch name, or a PBI number.                                                                                                                                                                      |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Org                     | Code of APG Business Unit. One of: ``s1`` (SIS), ``s2`` (AM), ``s3`` (FB/DWS).                                                                                                                                 |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Purpose                 | Code that describes an application (workload) and its subsystem (role). The DevOps team can define this to suit                                                                                                |
|                         | their needs accordingly.                                                                                                                                                                                       |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Usage                   | Environment type. One of: ``sbx`` (Sandbox), ``dev``, ``tst``, ``acc``, ``prd``.                                                                                                                               |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Location                | Azure region. One of: ``we`` or ``ne``.                                                                                                                                                                        |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Resource type           | Resource type abbreviation. Available values are here:                                                                                                                                                         |
|                         | `Abbreviation examples for Azure resources - Cloud Adoption Framework | Microsoft Learn <https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations>`__ |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Suffix                  | Optional. Use this to add a unique code to a DNS-registered PaaS resource, identify a specific resource belonging                                                                                              |
|                         | to another (for example Private Endpoint, NIC, etc), sequentially number similar resources (instances), construct a complex                                                                                    |
|                         | name in complex scenarios etc. It's advised to use "-" as a separating character to ensure readability where possible.                                                                                         |
+-------------------------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

It's not required to use all the preceding in each, use the convention to accommodate readability and adhere to the Azure naming limits. For example a VM name can be 15 characters.
Resources such as NSG or route table can have identifiers so that one can determine with which virtual network and subnet it's connected.

Give IaaS resources like Networks, VMs, NICs, and NSGs shorter names without org, department, or location. For PaaS resources, follow naming conventions to ensure global uniqueness.

Examples
~~~~~~~~

+-------------------------+------------------------------------------------------------------------------------------------------------------------+-------------------------------------------+
| Asset type              | Format                                                                                                                 | Examples                                  |
+=========================+========================================================================================================================+===========================================+
| Keyvault                | | <org><purpose><environment><location><resource type>                                                                 | | s3pvsdwsccdevwekv                       |
|                         | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwekv-01                    |
|                         | | <org><purpose><environment><location><resource type><suffix>                                                         | | s3pvsdwsccdevwekv01                     |
+-------------------------+------------------------------------------------------------------------------------------------------------------------+-------------------------------------------+
| Private endpoint        | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwepe-kv                    |
|                         | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwepe-01kv                  |
|                         | | <org><purpose><environment><location><resource type><suffix>                                                         | | s3pvsdwsccdevwepe01kv                   |
|                         | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwepe-kv01                  |
+-------------------------+------------------------------------------------------------------------------------------------------------------------+-------------------------------------------+
| NIC                     | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwenic-kv                   |
|                         | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwenic-01kv                 |
|                         | | <org><purpose><environment><location><resource type><suffix>                                                         | | s3pvsdwsccdevwenic01kv                  |
|                         | | <org><purpose><environment><location><resource type>-<suffix>                                                        | | s3pvsdwsccdevwenic-kv01                 |
+-------------------------+------------------------------------------------------------------------------------------------------------------------+-------------------------------------------+

Remarks
~~~~~~~

Some resources don't allow hyphens or underscores in name, for example:

* Container registry
* SQL server and database
* Storage account
* Virtual machine

Most of the resource names can have wider names, more than 50 characters, except:

+---------------------------------------------+------------+
| Resource                                    | Max.       |
|                                             | Characters |
+=============================================+============+
| Policy assignment                           |         24 |
+---------------------------------------------+------------+
| Virtual machines                            |         15 |
+---------------------------------------------+------------+
| Key Vault                                   |         24 |
+---------------------------------------------+------------+
| Logic App integration account               |         20 |
+---------------------------------------------+------------+
| Machine learning services workspace compute |         16 |
+---------------------------------------------+------------+
| Service Fabric Cluster                      |         23 |
+---------------------------------------------+------------+
| Storage account                             |         24 |
+---------------------------------------------+------------+

Automating resource names
~~~~~~~~~~~~~~~~~~~~~~~~~

You can use the PowerShell module on GitHub to automate name generation of Azure resources. The module `Azure Naming Tool <https://aka.ms/AzureNamingTool>`__ has a comprehensive documentation.

Microsoft Entra ID naming convention
----------------------------------------

Application registration
~~~~~~~~~~~~~~~~~~~~~~~~

Parts of the name
^^^^^^^^^^^^^^^^^
Depending on how you create the application registrations, you should use one of the following naming conventions.

In case of a manual creation use the following naming convention:
``<area>-<business unit>-<used for> (<usage>)``

In case of a automatic creation use the following naming convention:
``SP-APP-<Environment>-<used for>-<three digit sequence number>``

+-------------------------+---------------------------------------------------------------------------------+
| Field                   | Explanation                                                                     |
+=========================+=================================================================================+
| Area                    | Functional category of the application, to determine on a case by case basis.   |
+-------------------------+---------------------------------------------------------------------------------+
| Business unit           | Name of APG Business Unit. One of: ``AM``, ``DWS``, ``SIS``.                    |
+-------------------------+---------------------------------------------------------------------------------+
| Used for                | Name of the application that uses the registration.                             |
+-------------------------+---------------------------------------------------------------------------------+
| Environment             | Environment code of the DRCP environment.                                       |
+-------------------------+---------------------------------------------------------------------------------+
| Three digit sequence    | Number starting with 001 and counting up.                                       |
+-------------------------+---------------------------------------------------------------------------------+

Examples
^^^^^^^^

+-----------+---------------------------------------------------------------+
| Type      | Example                                                       |
+===========+===============================================================+
| Manual    | | D365-DWS-AzureDevOps-Connector (PRD)                        |
|           | | D365-AM-PowerPlatform (TST)                                 |
+-----------+---------------------------------------------------------------+
| Automatic | | SP-APP-ENV22021-ChatbotAdminApi-001                         |
|           | | SP-APP-ENV22021-IntentSeed-001                              |
+-----------+---------------------------------------------------------------+

References
----------

* `Resource types abbreviation <https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations>`__