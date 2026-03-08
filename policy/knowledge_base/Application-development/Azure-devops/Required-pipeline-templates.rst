Required pipeline templates
===========================

Performing actions in Azure using a pipeline must meet certain needs. Examples of these needs are creating a change and performing an vulnerability scan. For every service connection to Azure, Azure DevOps defines an extends template. Pipelines which perform actions in Azure requires the use of the extends template.

Please follow the link for `more information on extends templates <https://learn.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops&pivots=templates-extends>`__.

Use of the extends pipeline
---------------------------
The repository of the extends pipeline:

**Repository extends pipeline**

.. code-block:: yaml

    resources:
      repositories:
      - repository: templates
        type: git
        name: DRCP-Templates/templates
        ref: 'refs/heads/main'

.. warning:: The name to reference this repository should always be 'templates'.
.. note:: The name of the extends pipeline is mandatory-template.yml.
.. note:: If you desire to update more information in the automated change, it's possible by using the custom :doc:`DRCPAdoServiceNow task <Custom-drcp-ado-tasks>`.

The extends pipeline has the following parameters for inserting steps, jobs, or stages:

**Parameters extends pipeline**

.. code-block:: yaml

    parameters:
    - name: pipelineStages
      type: stageList
      default: []
    - name: pipelineJobs
      type: jobList
      default: []
    - name: pipelineSteps
      type: stepList
      default: []

Contents of the extends pipeline
--------------------------------
The extends pipeline inserts a PreActions stage.

| The PreActions stage checks if there is an open change in ServiceNow on the environment. If so, the pipeline will fail.
| If there isn't an open change in ServiceNow, the PreActions stage creates a standard change and links it to the Application system.

| After the build completes, the change stays open for about 60 minutes. During this open time, the system adds more details about the build to the change record. 
| Once all details are in place, the system closes the change automatically to maintain proper documentation and compliance.

Examples of the use of the extends pipeline
-------------------------------------------

For an example of a pipeline with stages see :doc:`Build and release pipelines <Build-and-release-pipelines>` .

.. confluence_expand::
   :title: Example pipeline with multiple jobs

   .. code-block:: yaml
      :linenos:

       trigger: none

       pool: CPP-Ubuntu2204-Latest-A

       resources:
          repositories:
          - repository: templates
            name: DRCP-Templates/templates
            type: git
            ref: main

       extends:
         template: mandatory-template.yml@templates
         parameters:
           pipelineJobs:
           - job: DevJob
             steps:
             - task: AzurePowerShell@5
               displayName: DEV action
               name: DevAction
               inputs:
                 azureSubscription: $(serviceConnectionDEV)
                 scriptType: 'InlineScript'
                 inline: 'Get-AzResourceGroup'
                 failOnStandardError: true
                 azurePowerShellVersion: 'LatestVersion'
                 pwsh: true

           - job: TestJob
             steps:
             - task: AzurePowerShell@5
               displayName: TST action
               name: TstAction
               inputs:
                 azureSubscription: $(serviceConnectionTST)
                 scriptType: 'InlineScript'
                 inline: 'Get-AzResourceGroup'
                 failOnStandardError: true
                 azurePowerShellVersion: 'LatestVersion'
                 pwsh: true

.. confluence_expand::
   :title: Example pipeline with multiple steps

   .. code-block:: yaml
      :linenos:

       trigger: none

       pool: CPP-Ubuntu2204-Latest-A

       resources:
         repositories:
         - repository: templates
           name: DRCP-Templates/templates
           type: git
           ref: main

       extends:
         template: mandatory-template.yml@templates
         parameters:
           pipelineSteps:
           - task: AzurePowerShell@5
             displayName: DEV action
             name: DevAction
             inputs:
               azureSubscription: $(serviceConnectionDEV)
               scriptType: 'InlineScript'
               inline: 'Get-AzResourceGroup'
               failOnStandardError: true
               azurePowerShellVersion: 'LatestVersion'
               pwsh: true

           - task: AzurePowerShell@5
             displayName: TST action
             name: TstAction
             inputs:
               azureSubscription: $(serviceConnectionTST)
               scriptType: 'InlineScript'
               inline: 'Get-AzResourceGroup'
               failOnStandardError: true
               azurePowerShellVersion: 'LatestVersion'
               pwsh: true
