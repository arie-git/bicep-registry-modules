Custom DRCP ADO Tasks
=====================
DRCP builds custom Azure DevOps tasks to support and streamline your pipelines.
These tasks help automate processes, improve integrations, and ensure consistency across deployments.

DRCP ADO ServiceNow
-------------------
To enhance the integration between Azure DevOps and ServiceNow, DRCP developed a custom Azure DevOps task. This allows teams to update specific fields within the ServiceNow change record created in a pipeline.
This task is optional and enables teams to enrich the automated change records with relevant data when needed, for example compliance data or audit purposes.

Used Service Connections are automaticly stored in the deployment change in ServiceNow as affected configuration items. If your deployment uses other Environments, you can specify them using the Environments parameter to ensure your change record is complete

.. warning:: This task requires the :doc:`Required pipeline template <Required-pipeline-templates>`.

**DRCPAdoServiceNow: Update Change information**

.. code-block:: yaml

  variables:
    - group: DRCPVariables

  extends:
    template: mandatory-template.yml@templates
    parameters:
      pipelineJobs:
      - job: Update Change information
        steps:
        - task: DRCPAdoServiceNow@0
          displayName: 'Update Change information'
          inputs:
            updates: '{"changePlan":"string", "implementationPlan":"string", "acceptanceCriteria":"string", "testPlan":"string", "environments":"ENVD1234,ENVD1235"}'


You can use the following parameters in the updates input as JSON:

.. list-table::
   :widths: 20 20 40 20
   :header-rows: 1

   * - Paramters
     - Type
     - Description
     - Max lenght
   * - changePlan
     - String
     - Enter an outline describing the detailed steps and actions required for a successful change.
     - 4000
   * - implementationPlan
     - String
     - ``Enter sequential steps to implement this change. In addition, enter dependencies between steps and assignee details for each step.``
     - 4000
   * - acceptanceCriteria
     - String
     - ``Enter details of the acceptance critiria for a successfull change.``
     - 4000
   * - testPlan
     - String
     - ``Enter details of planned and completed tests prior to implementation that indicates the potential success of this change.``
     - 4000
   * - environments
     - String
     - A list of Environments as comma seperated strings.
     - -
        
