Internal root certificate chain
===============================
.. contents::
   Contents:
   :local:
   :depth: 2

For Azure components or private build agents to access internal resources protected by internal certificates, you'll need to install and trust the internal root certificate authorities.

Private build agents
--------------------
To add the internal root certificates to the private build agents trust store you can use the code below:

**Download internal root certificates and install in private build agents trust store**

.. code-block:: yaml

  - task: Bash@3
    displayName: 'Install internal trusted root certificate chain Linux'
    inputs:
      targetType: 'inline'
      script: |
        sudo curl -L -o /usr/local/share/ca-certificates/CA01-APG.crt http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-Azure.crt http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-DC.crt http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-IRIS.crt http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
        sudo update-ca-certificates

.. code-block:: yaml

  - task: PowerShell@2
    displayName: 'Install internal trusted root certificate chain Windows'
    inputs:
      targetType: 'inline'
      script: |
        Invoke-WebRequest -Outfile CA01-APG.crt -Uri http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
        Invoke-WebRequest -Outfile CA02-Azure.crt -Uri http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
        Invoke-WebRequest -Outfile CA02-DC.crt -Uri http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
        Invoke-WebRequest -Outfile CA02-IRIS.crt -URI http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
        Get-ChildItem -Filter CA0*.crt | Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root'


.. warning:: The internal root certificates have a lifetime of 10 to 20 years. The company policy prohibits you to store certificates with a lifetime longer than 12 months or 365 days in the Azure Key Vault.


Pipeline tasks requiring certificates
-------------------------------------

Pipeline tasks that use on-premises systems and use software which has its own certificate store, have specific needs.

Some examples of these on-premises systems are SonarQube, Artifactory, and Octane.

For tasks based on Node, define an environment variable named 'NODE_EXTRA_CA_CERTS', which points to a .crt or .pem file which contains the APG certificate chain. See `Npm javascript pipeline <https://confluence.office01.internalcorp.net:8453/display/DEVSUP/Npm+Javascript+pipeline>`__ for an example.

.. vale Microsoft.Acronyms = NO

For tasks based on Java, running on Windows build agents, define an environment variable named '-Djavax.net.ssl.trustStoreType=WINDOWS-ROOT'. This way, Java uses the Windows certificate store. On Ubuntu build agents this environment variable isn't necessary.

.. vale Microsoft.Acronyms = YES

To use SonarQube on an Ubuntu build agent please use the code below:

.. code-block:: yaml

  - task: Bash@3
    displayName: 'Install internal trusted root certificate chain Ubuntu'
    inputs:
      targetType: 'inline'
      script: |
        sudo curl -L -o /usr/local/share/ca-certificates/CA01-APG.crt http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-Azure.crt http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-DC.crt http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
        sudo curl -L -o /usr/local/share/ca-certificates/CA02-IRIS.crt http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
        sudo update-ca-certificates
        cat /usr/local/share/ca-certificates/CA0*.crt >> apg-ca-bundle.crt

  # Prepare Analysis Configuration task
  - task: SonarQubePrepare@5
    env:
      NODE_EXTRA_CA_CERTS: apg-ca-bundle.crt
    inputs:
      SonarQube: 'SonarQube'
      scannerMode: 'CLI'
      configMode: 'manual'
      cliProjectKey: '$(System.TeamProject)'

  # Run Code Analysis task
  - task: SonarQubeAnalyze@5

  # Publish Quality Gate Result task
  - task: SonarQubePublish@5
    env:
      NODE_EXTRA_CA_CERTS: apg-ca-bundle.crt
    inputs:
      pollingTimeoutSec: '300'

For Windows build agents the pipeline code use the code below:

.. code-block:: yaml

  - task: PowerShell@2
    displayName: 'Install internal trusted root certificate chain Windows'
    inputs:
      targetType: 'inline'
      script: |
          Invoke-WebRequest -Outfile CA01-APG.crt -Uri http://prime03.office01.internalcorp.net/crt/CA01-APG.crt
          Invoke-WebRequest -Outfile CA02-Azure.crt -Uri http://prime03.office01.internalcorp.net/crt/CA02-Azure.crt
          Invoke-WebRequest -Outfile CA02-DC.crt -Uri http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
          Invoke-WebRequest -Outfile CA02-IRIS.crt -URI http://prime03.office01.internalcorp.net/crt/CA02-IRIS.crt
          Get-ChildItem -Filter CA0*.crt | Import-Certificate -CertStoreLocation 'Cert:\LocalMachine\Root'
          Get-Content CA0*.crt | Set-Content apg-ca-bundle.crt

  # Prepare Analysis Configuration task
  - task: SonarQubePrepare@5
    env:
      NODE_EXTRA_CA_CERTS: apg-ca-bundle.crt
    inputs:
      SonarQube: 'SonarQube'
      scannerMode: 'CLI'
      configMode: 'manual'
      cliProjectKey: '$(System.TeamProject)'

  # Run Code Analysis task
  - task: SonarQubeAnalyze@5
    env:
      SONAR_SCANNER_OPTS: '-Djavax.net.ssl.trustStoreType=WINDOWS-ROOT'

  # Publish Quality Gate Result task
  - task: SonarQubePublish@5
    env:
      NODE_EXTRA_CA_CERTS: apg-ca-bundle.crt
    inputs:
      pollingTimeoutSec: '300'
