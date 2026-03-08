Need help
=========

.. contents::
   Contents:
   :local:
   :depth: 2

Purpose
-------

| Need help? This page guides DRCP platform customers when they need help.
| Are you missing any information, please contact your BU CCC (Business Unit Cloud Competence Center).

Report an incident
------------------

| Please follow `this link <https://apgprd.service-now.com/drdc?id=drdc_sc_item&table=sc_category&sys_id=1c86c407dba09810ea69193405961917>`__ to the **incident** section in the DRDC portal.
| Choose an Environment and describe the incident as accurately as possible.

Please select one of the following categories prefixed with **DRCP**:
   - *DRCP - ServiceNow portal*
   - *DRCP - Azure Portal*
   - *DRCP - Deployments*

| The incident gets first assigned to the CCC of your business unit.
| They will know how to further analyse and solve the issue.
| The (re)assigned team solving the issue, adds intermediate progress updates or questions to the ticket in ServiceNow.

| The incident process used within APG includes a minor variation in this form. It has the benefit that most of the mandatory fields and incident assignment are automatically filled.
| This also means all incidents get the same priority: solved within 16 working hours.
| If you need a different priority, call the IT service desk and explain why it requires higher priority.
| The solving team will use the same process to solve incidents as the rest of APG.
| For more information about the APG incident process see `this <https://cloudapg.sharepoint.com/:w:/r/sites/ProcesManagement/_layouts/15/Doc.aspx?sourcedoc=%7B67C9ABDB-8A8F-4274-BFCE-A7C4CE1E21D1%7D&file=QRC%20Incident%20Management%20-%20SN%203.0%20EN.doc&action=default&mobileredirect=true>`__ quick reference card or `this <https://cloudapg.sharepoint.com/:w:/r/sites/ProcesManagement/_layouts/15/Doc.aspx?sourcedoc=%7B39359A6E-5E33-49C7-AADE-6F6D50C60384%7D&file=BPM%20-%20Incident%20Management%201.5%20ENG.docx&action=default&mobileredirect=true>`__ full description of the process.
| You can still call the IT service desk or use the ServiceNow portal to create incidents.

Questions
---------

If you have any questions, please take a look at the :doc:`FAQ <Frequently-asked-questions>` page. If the question isn't listed, follow the instructions provided.

| Follow `this link <https://apgprd.service-now.com/drdc?id=drdc_sc_item&table=sc_category&sys_id=f99f79eedb2c98100228bc45f39619b1>`__ to the **Ask a question** section in the DRDC portal.
| Describe the question as accurately as possible.

Please select one of the following categories prefixed with **DRCP**:
   - *DRCP - ServiceNow portal*
   - *DRCP - Azure Portal*
   - *DRCP - Deployments*


| The question gets assigned to the CCC of your business unit.
| They will know how to address the question.
| The (re)assigned team solving the question, adds intermediate progress updates or questions to the ticket in ServiceNow.

.. note:: Please take a look at the FAQ page before creating the ticket.

DRCP status page
----------------
| To know the status of the DRCP platform, you can see the current state of open and resolved incidents related to it.
| To find more information about availability, check the section showing the status of specific monitored DRCP services and connections. In case a service isn't available DRCP updates the status page and provides more information on the degrade service.status page and provides more information on the degraded service.
| To visit the DRCP status page follow `this link <https://apgprd.service-now.com/drdc?id=drcp_status>`_.

Manual actions
--------------

| The teams providing the DRCP platform haven't automated all actions yet.
| Requesting DNS records remains one of these actions.
| To request these actions use `this form <https://apgprd.service-now.com/drdc?id=drdc_sc_item&source=drdc_sc_ce_index&table=sc_category&sys_id=8bcfc88e87f5f1505ee3eb583cbb3543>`__.
| Please describe in the form what your team needs from the SIS platform providing or supporting teams.
| Provide your request with a short description, all necessary information and choose one of the predefined actions.

.. note:: If the action you require isn't available in the list, please use the *'Ask a question'* to check how to approach this.

InSpark / Microsoft support
-----------------------------------

| If you need extra help solving an incident or question, APG has an agreement with InSpark for third-line support for Microsoft services, including Azure. InSpark can forward requests to Microsoft if necessary. During office hours, CCCs can access InSpark to create tickets for the DevOps teams. DevOps teams should use the incident or question forms as described earlier on this page to access this support.
| To request InSpark support outside office hours for critical incidents, DevOps teams can ask 'the bridge' at APG to create a ticket with InSpark. In the ticket they will ask InSpark to contact the DevOps team.
| To give InSpark access to you Environment use the Quick action :doc:`Request support access for LZ3 <Platform/DRDC-portal/Quick-actions>` in ServiceNow once you received the ticket number from InSpark.

.. note:: 'The bridge' monitors the ICT infrastructure at APG and outside office hours they're the IT service desk. You can reach them at ``045-5796222``.

Support outside office hours
-----------------------------------

In the case an incident occurs outside office hours DRCP has standby available. To see who is available the check `this page <https://cloudapg.sharepoint.com/teams/ICT-OPERATIONS/Lists/StandByroosterSISITPSDRCPAzure?viewid=8180cfeb%2D644b%2D4484%2Da8a3%2Dd8d6eb026d60&viewpath=%2Fteams%2FICT%2DOPERATIONS%2FLists%2FStandByroosterSISITPSDRCPAzure>`__ and contact them via 'the bridge'.

Outside office hours DRCP supports critical incidents:

 - The customer process is fully disrupted, the DevOps team can't continue, and no work-around is available.
 - Solving the incident can't wait for the next day. This doesn't mean that if it bothers the DevOps team they can call. There should be a good reason that demonstrates the urgency of solving the incident.
 - The service is fully unusable. Temporary worse performance or some delays aren't enough to call standby support. From the moment the performance is so bad it's basicly unusable standby feel free to contact standby.
 - The incident concerns Environments with production usage.

In these cases the support is possible for the following services delivered by the DRCP team:

 - Requests done in the DRDC portal, created by the DRCP team. These can for example be the creation of an Environment in Landing zone 3 or Quick actions on an Environment. The standby support includes the full handling of the request, from ServiceNow to Azure.
 - The policies the DRCP created in Azure.
 - The mandatory templates used in the pipelines of the DevOps team.

This means there is no support in the following cases:

 - The incident concerns something broken in Azure. For this InSpark support is available.
 - Questions created in the DRDC portal aren't answered during standby.
 - If the performance is worse as normal but still functional, solving the incident can wait until the next day.
 - Some requests require approvals from the DRCP team. These aren't given outside office hours.
 - Environments with development, test, or acceptance usage aren't supported.

Others
------

| Didn't find what you were looking for?
| Or having a different question related to Azure Cloud or the DRCP platform unanswered in this knowledge base?
| Please contact your business unit Cloud Competence Center (BU CCC).


.. note:: Are you a SIS DevOps team that wants to get in touch with the BU CCC SIS? Please get in contact via Microsoft Teams following `this link <https://teams.microsoft.com/l/channel/19%3a_p_zLiPXw3RKf9JVvASNbSLiClvnfF2yatqW8do-1t81%40thread.tacv2/General?groupId=4949f184-94f8-4524-b604-d92d25c2e022&tenantId=c1f94f0d-9a3d-4854-9288-bb90dcf2a90d>`__.

