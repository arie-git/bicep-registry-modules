Incident remediation Azure DevOps
=================================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
------------
The items of the :doc:`Security baseline Azure DevOps <Security-baseline>` are automatically audited and monitored. Deviations on the security baseline will lead to incidents in ServiceNow on Application system level, since the Azure DevOps project is an Application system level instance.

This page describes remediations for these incidents. The listed items are the security baseline items on project-level. The organization-level items aren't included here yet.

Azure DevOps project incidents
==============================

.. list-table::
   :widths: 12 20 80
   :header-rows: 1

   * - ID
     - Description
     - Remediation

   * - drcp-ado-01
     - Disallow public projects.
     - When this incident happens, something has gone wrong with the automation of DRCP when creating the project. To remediate this incident, refresh your Application system by using the :doc:`Refresh Landing zone 3 Quick action <../../Platform/DRDC-portal/Quick-actions>` on the DRDC portal.
   * - drcp-ado-03
     - Project policy: Commit author email validation.
     - Check the Project Settings --> Repositories --> Policies if the **Commit author email validation** is still on and has the APG email domains present. To remediate this incident, refresh your Application system by using the :doc:`Refresh Landing zone 3 Quick action <../../Platform/DRDC-portal/Quick-actions>` on the DRDC portal.
   * - drcp-ado-04
     - Require a minimum number of reviewers for a pull request.
     - Check the Project Settings --> Repositories --> Policies if the **Branch Policies** for the develop and main branch are present and configured with **Minimum number of reviewers** to 1. To remediate this incident, refresh your Application system by using the :doc:`Refresh Landing zone 3 Quick action <../../Platform/DRDC-portal/Quick-actions>` on the DRDC portal.
   * - drcp-ado-07
     - Microsoft Entra ID groups, managed by IAM, get permissions in ADO. Individual users shouldn't have permissions in an APG ADO project.
     - Because ADO has a link to Microsoft Entra ID, you can assign permissions to Microsoft Entra ID groups. Individual users shouldn't have permissions assigned in ADO projects or ADO organizations, instead grant access to Microsoft Entra ID groups, controlled by IAM. To remediate this incident, please check your ADO permissions and remove all individual users or refresh your Application system by using the :doc:`Refresh Landing zone 3 Quick action <../../Platform/DRDC-portal/Quick-actions>` on the DRDC portal. If the individual users require access, request access for them to the desired DRCP role through IAM.
   * - drcp-ado-12
     - An automated change process is in place by using required template for pipelines.
     - Check for all the Environments within your Application system: the Project Settings --> Service Connections --> Open the Service Connection of the Environment --> Approvals and checks --> Check if the :doc:`required template <Required-pipeline-templates>` is present. If the template is missing or misconfigured for a specific environment, refresh that specific Environment from the DRDC portal to remediate.