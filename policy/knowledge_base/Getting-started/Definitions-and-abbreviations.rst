Definitions and abbreviations
=============================

| This page describes important abbreviations and terminology used in the context ITPS, the DRCP platform and this knowledge base.
| For more information related to the ITPS term `Application system` see also the section :doc:`guidelines and standards <Application-System-and-Environments>`.

.. note:: Industry-standard terminology, such as 'IAM', 'ACL' etc. isn't described here on purpose.

Abbreviations
-------------
.. list-table::
   :widths: 10 40 100
   :header-rows: 1

   * - Abbreviation
     - Definition
     - Remarks

   * - DRCP
     - DevOps Ready Cloud Platform
     - The automated Azure platform in Landing zone 3 you're using.

   * - DRDC
     - DevOps Ready Data Center
     - The automated data center of APG in Landing zone 2.

   * - LLDC
     - Low Level Data Center
     - Within APG there are 2 LLDC teams: one for on premises and one for Azure. Within the context of DRCP, the documentation refers to the 'Azure LLDC' team. This team manages the tenant, management groups and network configuration. This includes but isn't limited to shared services and utilities such as network integration, firewalls, audit-logs etc.

   * - AS
     - Application system
     - See below.

   * - (BU) CCC
     - (Business Unit) Cloud Competence Center
     - Each business unit has its own CCC: AM, FB/DWS and SIS. These support DevOps teams during the lifecycle of their application including the onboarding to the Azure platform.

   * - ITPS
     - IT Platform Services
     - Value Stream that includes (but not limited to) the teams Azure Ignite, ESA, etc. `Learn more <https://cloudapg.sharepoint.com/sites/TeamAPG-SIS/SitePages/Agile-Teams-binnen-SIS.aspx>`__.

   * - SIS
     - Shared IT Services
     - The Business Unit that's responsible for IT within APG. `Learn more <https://cloudapg.sharepoint.com/sites/TeamAPG-SIS>`__.

Terminology
-----------
.. list-table::
   :widths: 20 105
   :header-rows: 1

   * - Term
     - Definition

   * - Customer
     - In the context of this knowledge base, this refers to a DevOps team.

   * - Building Block
     - APG-maintained code used in the IaC, CaC process. In the context of DRCP, Building Blocks are (on the one hand) the code for the guardrails (maintained by the DRCP DevOps team), and (also) the code the DevOps team creates to deploy their IT in Azure. Combinations of code Building Blocks realize components.

   * - Application system (AS)
     - The name of the application/service that's created by the business DevOps team. The term "Application system" is also used within ServiceNow. :doc:`Learn more <Definitions-and-abbreviations>`.
        * An Application system is a collection of functionalities that's considered as a whole. When referred, it's the name of the application/service that's created by the business DevOps team. The term is also used within ServiceNow.
        * The related processes within ServiceNow are re-used to automatically create and maintain the DRCP Customer DevOps project and the DRCP Environment.
        * The orchestration spans external Application systems including IAM, Azure DevOps and is future-proof extendable for other ITPS teams. The process provides the requester with two Microsoft products: an Azure DevOps project (1 per Application system) and an Environment (Azure Subscription).
        * An Application system may contain zero, one or more Environments, with each Environment dedicated to a selected usage.
        * An Application system is in control of a single DevOps team. In the other way around, a DevOps team may control more than 1 Application system.
        * An Application system contains a default :doc:`approval group <../Platform/DRDC-portal/Approval-overview>` with an associated IAM role.
        * To request a new Application system please :doc:`contact <../Need-help>` your business unit Cloud Competence Center.

   * - Environment
     - This is an Azure Subscription with a Usage type in which the business DevOps team can deploy their application.
        * A DRCP Environment consists of an Azure Subscription in which the DevOps team can manage the full lifecycle of an instance of an application. It determines the generic boundary for Azure components. This includes the VNet provided for connectivity, authorizations for the DevOps team and the APG guardrails that are in place.
        * From technological perspective, a DRCP Environment consists of a single Azure Subscription (Enterprise Agreement based), dedicated to a usage (for example: Acceptance).
        * Also, a DRCP Environment is hierarchically part of an Application system. Automation access to the Subscription is possible through a pre-provisioned service connection in the Azure DevOps project that belongs to the Application system.
        * DRDC definition: A collection of components (load balancers, file shares, etc.) considered as a whole. Applications leverage these components. This definition is still fully relevant for `DRDC Environments <https://confluence.office01.internalcorp.net:8453/display/DRDCKB/Request+an+environment>`__.

   * - Usage
     - This is the set-once "DTAP-kind" of an Environment. Available usages: Development, Test, Acceptance, and Production. An Application system may contain one or more Environments, each dedicated to their own usage. An Application system may contain more than 1 Environment per usage.

   * - DRCP Platform
     - This is the complete Azure environment that DRCP provides and where the DevOps teams “land” on.

   * - Guardrails
     - The technical and procedural measures to help DevOps teams to confirm to APG standards. Examples are policies (blocking and audit), the way of working for DevOps that's enforced by the platform, team maturity checks and others.

   * - Guardrail types
     - Types:
        * **Active**. DRCP actively restricts the creation of the Azure Component.
        * **Reactive**. The adjusted component by the platform (for example DNS registrations).
        * **Passive**. When the scenario triggers, it creates an event. (An event is either a security event or application event).
        * **Outgoing Must**. What DevOps requires to do, for instance stored secrets in the Key Vault. DRCP doesn't technically enforce a restriction.

   * - Landing zone
     - An APG Landing zone (LZ) is a coherent set of Technical Infrastructure: IT-elements to (develop,) deploy, and host Application systems and data. Please note that the APG term 'Landing zone' differs from the industry-standard term. The IT landscape of APG consists of a total of 7 Landing zones, for which DRCP hosts 3 and 5. Also please note, Landing zone 3 **accent**, built by DRDC Azuris, will deprecate. `Learn more (page 53 and further) <https://cloudapg.sharepoint.com/sites/APGDigiSquare/Gedeelde%20documenten/Forms/AllItems.aspx?id=%2Fsites%2FAPGDigiSquare%2FGedeelde%20documenten%2FIT%20Vision%20and%20strategy%2FTI%20Vision%20and%20Strategy%202021%2Epdf&parent=%2Fsites%2FAPGDigiSquare%2FGedeelde%20documenten%2FIT%20Vision%20and%20strategy>`__ about APG Landing zones.

   * - Microsoft Entra ID
     - Directory service within Azure, previous known as Azure Active Directory.

   * - Azure Policy
     - Azure Policy is a service in Azure which allows you create polices which enforce and control the properties of a resource.

   * - Maintenance
     - This is the window where the DRCP has time to do maintenance on the Environment. :doc:`Learn more <../Processes/Release-and-maintenance>`.

   * - LCM (Lifecycle Management)
     - LCM is the administration of a system (or component) from provisioning, through operations, to retirement.
