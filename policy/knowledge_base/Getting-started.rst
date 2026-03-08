Getting started
===============

.. toctree::
   :maxdepth: 2
   :glob:
   :caption: Contents
   :titlesonly:

   Getting-started/*

Purpose
-------

| This section provides DevOps teams with information for getting started with Azure Cloud and using the DRCP platform.
| It explains shared :doc:`definitions and abbreviations <Getting-started/Definitions-and-abbreviations>` often used when working with the DRCP platform and provides some :doc:`guidelines and standards <Getting-started/Application-System-and-Environments>` when creating an Application system. It also outlines :doc:`naming conventions <Getting-started/Naming-conventions>` that form the basis of organizing cloud resources.
| Then it explains the :doc:`onboarding process <Getting-started/Onboarding-process>` for moving towards APG Azure Cloud.
| The section on :doc:`responsibilities <Getting-started/Responsibilities>` explains DevOps teams' duties for developing and maintaining their application systems. It also details which aspects the DRCP platform team delivers.

Generic workflow
----------------

| Before you can start using the DRCP platform, you have to onboard your application.
| See the :doc:`Onboarding process <Getting-started/Onboarding-process>` for a description on how to onboard a new application. Part of the onboarding is for the BU CCC to create and  :doc:`Application system <Getting-started/Definitions-and-abbreviations>`. This is necessary to group all Environments to your application. Contact the BU CCC of your business unit for the onboarding of an application and the creation of an Application system.
| After the onboarding, the next aspect is requesting an :doc:`Environment <Getting-started/Application-System-and-Environments>`. From this point, DevOps teams are able to run their workloads in Azure and Azure DevOps.

See below for the general workflow:

#. **Request an Environment**.
   To request an Environment, click the **Add** button on the **Dashboard** of the DRDC portal. For more information see also the section about requesting an Environment :doc:`here <Getting-started/Application-System-and-Environments>`.
#. **Manage the Environment**.
   Add infrastructure components to the Environment by opening the Azure Portal, selecting the Environment dashboard and performing Quick actions on the Environment. Check the requests, changes and incidents for the Environment. Find more information about managing an Environment :doc:`here <Getting-started/Application-System-and-Environments>`. When a new release is available, refresh the Environment to apply the latest DRCP changes, using the Quick action button **Refresh Environment** in the portal.
#. **Remove Environment**.
   Time to remove and improve. Working with the DRCP means working with the mindset that an unused Environment is *waste*. Remove it when it's not used anymore. Make sure to first remove all Azure components that are in the Environment's Subscription. After the removal of the Environment, DRCP triggers an API call to Microsoft to cancel the Subscription.

.. note:: The CMDB of ServiceNow determines the name of the Azure Subscription (for example ``OURAS-ENV12345-ACC``, where ``ENV12345`` serves as the Environment identifier within Application system ``OURAS``.). It's impossible to change this name.
.. warning:: The removal of an Environment is irreversible and may lead to data loss! The removal of Azure resources within the Environment's Subscription by the DevOps team is mandatory, before the ServiceNow workflow is able to proceed.
.. warning:: The platform gives you the ability to register app registrations, and the DevOps team needs to delete these *before* removing the Environment.

Getting started guidelines from the Business Units
--------------------------------------------------

DevOps teams follow the guidelines and standards from their BU-CCC:

- Asset Management: `Using the DRCP <https://confluence.office01.internalcorp.net:8453/spaces/ACC/pages/202212223/Using+the+DRCP>`__.
- FB/DWS: `Getting Started <https://confluence.office01.internalcorp.net:8453/spaces/FBDWSCCCKB/pages/297241832/Getting+Started>`__.