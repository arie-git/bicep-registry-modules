Variables and secrets
=====================

In this article, you'll learn how to store and use variables and secrets in Azure DevOps for configuration management of your Azure environments.

Variables
---------

| To avoid setting up a deployment pipeline for every environment or usage, the best practice is to use one general pipeline with variables per environment for every deployment.
| Different ways to use variables in pipelines exist. Two common ways to use variables in Azure DevOps are:

- Using the pipeline library variable groups in the Azure DevOps project.

   This is the easiest way to store variables and group them together. Create a variable group per environment and store the variables. In your pipeline define a variable group per stage and the variables of that group will apply to that specific stage.

   Here is an example snippet to define and use a variable group:

   .. code-block:: yaml

      - stage: DEV
        displayName: 'DEV environment'
        dependsOn: Build
        jobs:
        - deployment: Deploy
          environment: Development
          variables:
            - group: DRCP-dev
          strategy:
            runOnce:
              deploy:
                steps:
                  - template: deploy-steps.yml

   .. tip::
      Follow the link for `more information on variable groups <https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml>`__

- Using YAML files to store variables.

.. warning:: Don't store secrets in YAML files!

   | Using YAML files in your repository has an advantage opposed to using variable groups: it enables file versioning and git history for your variables.
   | In this way working with variables is part of the development flow and changes to variables go through the pull request process.

   Here is an example snippet to define and use a YAML parameter file in your pipeline:

   .. code-block:: yaml

      - stage: DEV
         displayName: 'DEV environment'
         dependsOn: Build
         jobs:
            - deployment: Deploy
               environment: Development
               variables:
               - template: Variables/Usage/Development.yml
               strategy:
                  runOnce:
                     deploy:
                        steps:
                           - template: deploy-steps.yml

Secrets
-------

Storing secrets in plain text in a variable group or YAML file is a security risk. Because of this risk, other options exist for storing secrets in Azure DevOps:

- Storing secrets in a variable group as secret

   Within a pipeline variable group, it's possible to mark values as secret. Secret variables get encrypted at rest with a 2048-bit RSA key and are available on the agent for tasks and scripts to use.

- Storing secrets in a variable group linked to an Azure KeyVault doesn't work within APG, because the solution requires public network access to the KeyVault to work. This conflicts security configuration baseline control ``drcp-kv-01``.
