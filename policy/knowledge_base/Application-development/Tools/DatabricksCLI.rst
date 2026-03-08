Databricks CLI
==============

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
-------------
| This page describes the tools for configuring Databricks workspace and objects.
| The Databricks command-line interface (also known as the Databricks CLI) provides a tool to automate the Databricks platform from your terminal, command prompt, or automation scripts. See `Databricks CLI <https://learn.microsoft.com/en-us/azure/databricks/dev-tools/cli/>`__.

.. include:: ../../_static/include/tool-versiondisclaimer.txt

Databricks CLI in Azure DevOps pipelines
----------------------------------------
For using the Databricks CLI in Azure DevOps pipelines, download the Databricks CLI via JFrog Artifactory. Request a generic remote repository to `Releases - Databricks CLI <https://github.com/databricks/cli/releases>`__ by sending a mail to ``CM-DevelopmentSupport``.
Add the following steps to an Azure DevOps pipeline to use the Databricks CLI:

.. code-block:: yaml

   - task: Bash@3
     displayName: 'Install internal trusted root certificate chain Linux and load Databricks Cli in JFrog'
     inputs:
       targetType: 'inline'
       script: |
         sudo curl -L -o /usr/local/share/ca-certificates/CA01-APG.crt http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
         sudo curl -L -o /usr/local/share/ca-certificates/CA02-Azure.crt http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
         sudo curl -L -o /usr/local/share/ca-certificates/CA02-DC.crt http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
         sudo curl -L -o /usr/local/share/ca-certificates/CA02-IRIS.crt http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
         sudo update-ca-certificates
          
         curl -u <JFrog username>:<JFrog token> -O https://jfrog-platform.office01.internalcorp.net:8443/artifactory/<JFrog remote github repo>/databricks/cli/releases/download/v0.219.0/databricks_cli_0.219.0_linux_amd64.zip

    - task: JFrogGenericArtifacts@1
      displayName: 'Download Databricks CLI from JFrog'
      inputs:
        command: 'Download'
        connection: 'Artifactory2'
        specSource: 'taskConfiguration'
        fileSpec: |
          {
            "files": [
              {
                "pattern": "<JFrog remote github repo>/databricks/cli/releases/download/v0.219.0/databricks_cli_0.219.0_linux_amd64.zip",
                "explode": "true"
              }
            ]
          }
        failNoOp: true

    - task: AzureCLI@2
      displayName: 'Run Databricks CLI'
      inputs:
        azureSubscription: <service connection>
        scriptType: pscore
        scriptLocation: inlineScript
        addSpnToEnvironment: true
        inlineScript: |            
          $env:DATABRICKS_HOST = 'https://xxx.yyy.azuredatabricks.net/'
          # Simple Databricks CLI command, replace with your own commands:
          $(Build.SourcesDirectory)/databricks/cli/releases/download/v0.219.0/databricks service-principals list

On the Linux build servers, use the amd64 download. Check `GitHub <https://github.com/databricks/cli/releases>`__ for the latest version of the Databricks CLI.

Databricks CLI on the APG workstation
-------------------------------------

For using Databricks CLI on the APG workstation, request the package via `IAM tooling <https://iam.office01.internalcorp.net/aveksa>`__:

.. confluence_newline::

.. image:: ../../_static/image/databricks-package.png
    :alt:
    :width: 400 px
