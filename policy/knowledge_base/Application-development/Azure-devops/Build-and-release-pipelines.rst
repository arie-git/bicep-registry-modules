Build and release pipelines
===========================

In this article, you'll learn how to start with a build stage and deploy to development, test, acceptance, and production. This by using a multi-stage YAML pipeline in your Azure DevOps project.

Build and deployment pipeline
-----------------------------
.. note:: Engineers have access to the Azure portal in the development environments to enable visual provisioning of Azure components. They don't have change permissions in Test, Acceptance, and Production environments. The Azure DevOps Service Connection has change permissions to Test-, Acceptance-, and Production environments.

A common setup of a multi-stage CI/CD pipeline consists of the following stages:

- Build phase (including code quality and unit tests).

   In this stage the code is build into deployable packages and code quality tests can be automatically included. Certain deployments, such as infra-as-code, don't always require a build step.

- Deployment to Development (including regression tests).

   This stage deploys the artifacts/code created during the build stage to the environment with usage Development. Unit tests typically take place in this stage.

- Deployment to Test

   This stage requires the use of pipelines since Engineers don't have change permissions in the Azure portal anymore. In this stage regression tests and integration tests take place to see if the deployment breaks the interaction with other parts of the environment.

- Deployment to Acceptance (including Acceptance approval step)
- Deployment to Production (including Production approval step and Release approval step)

Each stage of the pipeline depends on a successful run of the previous stage to prevent deployments with errors taking place.

DRCP doesn't allow deployment to Acceptance and Production for all branches and requires a pull request (PR) for certain branches, see :doc:`Branch protection <Branch-protection>`.

Approval steps
--------------
A deployment to an Acceptance environment or Production environment requires an approval step. The service connections for the usage Acceptance and Production have one or two configured approval groups.

Acceptance approval
~~~~~~~~~~~~~~~~~~~
The role AcceptanceApprover gives a user the permission to approve pipeline deployments to an Acceptance environment.

Production approval
~~~~~~~~~~~~~~~~~~~
The deployment to Production requires an approval of either a member of the ProductionApprover role or a member of the ReleaseManager role.

Example
-------
An example of a YAML multi-staged pipeline:

.. confluence_expand::
   :title: Example multi-staged CI/CD pipeline

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
       - name: usage
         default: Development
       - name: runManualActions
         default: false
         type: boolean

       # Include YAML pipeline files for appropriate input.
       variables:
       - name: logicalName
         value: '<value>'
       - name: runManualActions
         value: ${{ parameters.runManualActions }}
       - template: Variables/Usage/${{ parameters.usage }}.yml
       - template: Variables/Generic.yml

       extends:
         template: mandatory-template.yml@templates
         parameters:
           pipelineStages:
           - stage: Build
             jobs:
             - job: Build
               steps:
               - template: build-steps.yml

           - stage: DEV
             displayName: 'DEV environment'
             dependsOn: Build
             - job: DevJob1
               variables:
               - template: Pipelines/Variables/Dev-vars.yml@self
               steps:
               - template: deploy-steps.yml

           - stage: TST
             displayName: 'TST environment'
             dependsOn: Build
             - job: TstJob1
               variables:
               - template: Pipelines/Variables/Test-vars.yml@self
               steps:
               - template: deploy-steps.yml

           - stage: ACC
             displayName: 'TST environment'
             dependsOn: Build
             - job: TstJob1
               variables:
               - template: Pipelines/Variables/Acc-vars.yml@self
               steps:
               - template: deploy-steps.yml

           - stage: PRD
             displayName: 'TST environment'
             dependsOn: Build
             - job: TstJob1
               variables:
               - template: Pipelines/Variables/Prd-vars.yml@self
               steps:
               - template: deploy-steps.yml

.. note:: The name of the extends pipeline is ``mandatory-template.yml``.
.. note:: Please check the required parameters in the :doc:`mandatory template <Required-pipeline-templates>` for using stages, jobs, and steps.

.. tip::

   For more information on multi-staged pipelines please go to https://learn.microsoft.com/en-us/training/modules/create-multi-stage-pipeline/
