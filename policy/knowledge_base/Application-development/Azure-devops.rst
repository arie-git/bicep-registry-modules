Azure DevOps
============

.. toctree::
   :maxdepth: 2
   :glob:
   :caption: Contents

   Azure-devops/*


Getting started with Azure DevOps
---------------------------------

| When DRCP creates a new :doc:`Application system (AS) <Azure-devops/Required-pipeline-templates>` in ServiceNow, DRCP automation also creates and configures an Azure DevOps project including the required IAM roles.
| In this article, you'll learn how to get started with the DRCP Azure DevOps project.

Project location
----------------
| The automation of DRCP creates an Azure DevOps project in this Azure DevOps organization: https://dev.azure.com/connectdrcpapg1.

.. vale Microsoft.Acronyms = NO

| For example the Application system **DRCP-DEMO** has the URL https://dev.azure.com/connectdrcpapg1/S01-App-**DRCP-DEMO**.

.. vale Microsoft.Acronyms = YES

| Here S01 stands for SIS. S02 stands for Asset Management and S03 stands for Fondsenbedrijf/DWS.

Access and permissions
----------------------
| The IAM system of APG controls the access to the Azure DevOps project. When DRCP creates a new Application system (AS), associated roles become available in the IAM system.
| The following IAM roles give access to the Azure DevOps project:

- A user with the ``TR-DRCP-<AS>_engineer`` role has an APG custom role with the highest permissions in the project (within the APG boundaries). This role gives permission to manage pipelines, repositories, code, variables, but not to manage permissions and default repository policies.
- A user with the ``TR-DRCP-<AS>_user`` role has the Azure DevOps default role Contributor in the project. This role gives permission to manage code, create pull requests and run pipelines, but not to manage pipelines, repositories, permissions, and policies.
- A user with the ``TR-DRCP-<AS>_reader`` role has the Azure DevOps default role Reader. This role gives permission to read code, pipelines, and status information, but a user with just this role can't change anything in the project.
- A user with the ``TR-DRCP-<AS>_acceptanceapprover`` role needs to approve every deployment to an Acceptance Environment. DRCP adds this role to the Azure DevOps default role Reader in the project.
- A user with the ``TR-DRCP-<AS>_productionapprover`` role needs to approve every deployment to a Production Environment. DRCP adds this role to the Azure DevOps default role Reader in the project.
- A user with the ``TR-DRCP-<AS>_releasemanager`` role is the second approver for every deployment to a Production Environment. DRCP adds this role to the Azure DevOps default role Reader in the project.

| For more information about these Azure DevOps related IAM roles, see the section :doc:`roles and authorizations <../Getting-started/Roles-and-authorizations>`.
| Please follow `this link <https://learn.microsoft.com/en-us/azure/devops/organizations/security/permissions-access?view=azure-devops>`__ for more information on the default role Contributor and Reader.
| DRCP will add more information on the APG custom role Engineer in a future iteration.

First use
---------
DRCP delivers the project with an empty default repository. An Engineer uses this repository and adds code to it or creates a new repository, depending on the needs of the DevOps team. A user can contribute to the code.

| All repositories have a default branch policy, controlled by DRCP. This policy, for instance, prohibits a direct push to the main branch, which means code changes require a pull request and a branch. The 4-eye principle is also enforced by this policy.
| DRCP will add more information on the branch policy in a future iteration.

First deployment
----------------
| Before you can deploy to Azure, you need to create an :doc:`Environment <../Getting-started/Application-System-and-Environments>` in ServiceNow. When this new Environment is available, a service connection in the project becomes available with the name SC-<AS>-<Environment name>.
| On this service connection DRCP enforces the use of an extend template. This means when you want to deploy to your Azure environment, you should extend a :doc:`DRCP managed required template <Azure-devops/Required-pipeline-templates>`.

Here is an example of a starter pipeline that extends this required template:

.. confluence_expand::
   :title: Example pipeline with stages, jobs, and steps

   .. code-block:: yaml
      :linenos:

      trigger: none

      pool: '$(agentPool)'

      resources:
        repositories:
        - repository: templates
          name: DRCP-Templates/templates
          type: git
          ref: main

      parameters:
      - name: namePerson
        type: string

      variables:
      - template: ../Variables/Generic.yml

      extends:
        template: mandatory-template.yml@templates
        parameters:
          pipelineStages:
          - stage: FirstCustomerStage
            jobs:
            - job: MyFirstJob
              steps:
              - task: AzurePowerShell@5
                inputs:
                  azureSubscription: $(serviceConnectionDEV)
                  ScriptType: 'InlineScript'
                  Inline: 'Get-AzResourceGroup'
                  FailOnStandardError: true
                  azurePowerShellVersion: 'LatestVersion'
                  pwsh: true

            - job: MySecondJob
              steps:
              - task: AzurePowerShell@5
                inputs:
                  azureSubscription: $(serviceConnectionACC)
                  ScriptType: 'InlineScript'
                  Inline: 'Get-AzResourceGroup'
                  FailOnStandardError: true
                  azurePowerShellVersion: 'LatestVersion'
                  pwsh: true

          - stage: SecondCustomerStage
            jobs:
            - job: MyFirstJobInSecondStage
              steps:
              - task: AzurePowerShell@5
                inputs:
                  azureSubscription: $(serviceConnectionPRD)
                  ScriptType: 'InlineScript'
                  Inline: 'Get-AzResourceGroup'
                  FailOnStandardError: true
                  azurePowerShellVersion: 'LatestVersion'
                  pwsh: true

            - job: MySecondJobInSecondStage
              variables:
              - name: secondAlternativeGreeting
                value: 'good afternoon'
              steps:
              - bash: echo $(secondAlternativeGreeting) ${{ parameters.namePerson }}

.. note:: The name of the extends pipeline is mandatory-template.yml
.. note:: Please also check the mandatory template's :doc:`required pipeline parameters <Azure-devops/Required-pipeline-templates>` when using stages, jobs, and steps.
