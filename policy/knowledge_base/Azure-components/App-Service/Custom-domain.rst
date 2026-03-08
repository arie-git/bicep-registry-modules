Set custom domain
=================

.. contents::
   Contents:
   :local:
   :depth: 2

Introduction
------------
Azure provides a way to map a custom Domain Name System (DNS) name to an App Service.
This document describes the steps needed to achieve this. It focuses on the way to perform these steps within APG. At this moment some of these steps are manual, DRCP will in the future provide ways to automate these steps.

.. note:: The DRCP platform doesn't allow to access App Services directly from the public internet, so custom domains for App Services will always resolve to internal APG ip-addresses.

.. warning:: Important! Use the DNS zone ``azurebase.net`` for custom domains.

.. note:: This manual instructs the reader how to request an **internal** signed certificate. See page :doc:`Request external certificate <../../Application-development/Certificates/Request-external-certificate>` for requesting an **external certificate**. For more generic information, see the `APG Cyber Security Knowledge Hub <https://cloudapg.sharepoint.com/sites/TeamAPG-SecurityFirst/SitePages/Inf.aspx>`__.

Actions
-------
Perform all the following actions to create a custom domain.

.. note:: An alternative for the steps 'Export the .pfx-file from the Key Vault' and 'Import the certificate in the web app'. Access the certificate in the Key Vault from the Web App, but that requires granting the 'get' permission to the ``Microsoft.Azure.Websites`` resource provider, see `configure SSL certificate <https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-certificate?tabs=apex#authorize-app-service-to-read-from-the-vault>`__. In the DRCP platform the use of IAM access control is mandatory, this blocks granting permissions.

1. Create a ``.csr`` file by using a Key Vault to create a certificate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To request a signed certificate within APG, create a ``.csr`` file first. Use a key vault to create the ``.csr`` file. See `Creating and merging a certificate signing request in Azure Key Vault <https://learn.microsoft.com/en-us/azure/key-vault/certificates/create-certificate-signing-request?tabs=azure-powershell#add-certificates-in-key-vault-issued-by-non-partnered-cas>`__.
The following script will put a ``.csr`` in the key vault and create a file.

.. code-block:: powershell

  $domainCertificateName = "example"
  $certificateDNS = "$domainCertificateName.azurebase.net"
  $certificateSubjectName = "CN=$certificateDNS,OU=ICT,O=APG Groep N.V.,L=Heerlen,ST=Limburg,C=NL"
  $certificateValidityInMonths = 12
  $keyVaultName = "examplekv"

  $policy = New-AzKeyVaultCertificatePolicy -SubjectName "$certificateSubjectName" -ValidityInMonths $certificateValidityInMonths -IssuerName Unknown -DnsName "$certificateDNS"
  $existing = Get-AzKeyVaultCertificate -VaultName $keyVaultName -Name $domainCertificateName
  if (!$existing) {
      $csr = Add-AzKeyVaultCertificate -VaultName $keyVaultName -Name $domainCertificateName -CertificatePolicy $policy
      $csr.CertificateSigningRequest

      $csrFile = Join-Path -Path $(Build.ArtifactStagingDirectory) -ChildPath "$(domainCertificateName).csr"
      $csrContent = "-----BEGIN CERTIFICATE REQUEST-----`n"
      $csrContent += $csr.CertificateSigningRequest
      $csrContent += "`n"
      $csrContent += '-----END CERTIFICATE REQUEST-----'
      $csrContent | Set-Content -Encoding UTF8 -Path $csrFile
  }
  else {
      Write-Host -Message "Do not accidentally overwrite an existing certificate."
  }

See `certificates <https://cloudapg.sharepoint.com/sites/SecurityFirst/SitePages/Certificates.aspx?xsdata=MDV8MDJ8fDY1MDgwZmMyNTcwMjRhZTVlZTYxMDhkYmZiYmI1NDk2fGMxZjk0ZjBkOWEzZDQ4NTQ5Mjg4YmI5MGRjZjJhOTBkfDB8MHw2MzgzODA1NTQxOTk4NDcwNzR8VW5rbm93bnxWR1ZoYlhOVFpXTjFjbWwwZVZObGNuWnBZMlY4ZXlKV0lqb2lNQzR3TGpBd01EQWlMQ0pRSWpvaVYybHVNeklpTENKQlRpSTZJazkwYUdWeUlpd2lWMVFpT2pFeGZRPT18MXxMMk5vWVhSekx6RTVPalpoWVRSall6UXdMVGcxWXprdE5HRTRZUzA0Tm1NNExUTXlOemsxTjJZeE1qRmhZVjlsWmpJMVkyWXlOeTAyWXpZd0xUUmxOakV0T1RRM1lTMHhORFpoWVRBd056WTVZelpBZFc1eExtZGliQzV6Y0dGalpYTXZiV1Z6YzJGblpYTXZNVGN3TWpRMU9EWXhPVFF4TXc9PXxmNmE1OWNkYTVmNDI0ZTA3ZWU2MTA4ZGJmYmJiNTQ5NnxkZTcxNDYxZTU2MWM0OTlmODE5ODU1OTVkYjhjMTNiMA%3D%3D&sdata=VnR2V1pMUUpud2NDRXBHY0hBeVpkaUlUTlQ2Z2RyRWppRUdpd2UwYlplYz0%3D&ovuser=c1f94f0d-9a3d-4854-9288-bb90dcf2a90d%2Charmien.beimers%40apg.nl&OR=Teams-HL&CT=1702549805208&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yMzExMDIyNDcwNSIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D>`__ for the description of the APG certificate process and the needs for the ``csr`` files.
Check the ``csr`` in `DigiCert <https://www.digicert.com/ssltools/view-csr/>`__. Make sure the certificate is valid.

2. Request the internal or external signed certificate
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Request the internal signed certificate via ServiceNow through the `Infrastructure Catalog <https://apgprd.service-now.com/now/nav/ui/classic/params/target/catalog_home.do%3Fsysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > `Security Services <https://apgprd.service-now.com/now/nav/ui/classic/params/target/com.glideapp.servicecatalog_category_view.do%3Fv%3D1%26sysparm_parent%3D8b450b7d4fd9a200eec9cda28110c758%26sysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > **APG Internal Certificate**. Only APG key-users are able to do so.

Request the external signed certificate via ServiceNow through the `Infrastructure Catalog <https://apgprd.service-now.com/now/nav/ui/classic/params/target/catalog_home.do%3Fsysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > `Security Services <https://apgprd.service-now.com/now/nav/ui/classic/params/target/com.glideapp.servicecatalog_category_view.do%3Fv%3D1%26sysparm_parent%3D8b450b7d4fd9a200eec9cda28110c758%26sysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__ > **APG External Certificate**. Only APG key-users are able to do so.

A tutorial is also available on the `APG Security Knowledge Hub <https://cloudapg.sharepoint.com/sites/TeamAPG-SecurityFirst/SitePages/How-to-request-an-internal,-external-or-government-certificates.aspx?web=1>`__.

.. note:: The ``.csr`` file is mandatory input for this request.

Use the following information for the request:

.. list-table::
   :widths: 10 25
   :header-rows: 1

   * - Request field
     - Value
   * - Requested for
     - When the certificate is ready, this person gets a mail from ServiceNow with the resulting .cer-file
   * - Certificate Action
     - Request New certificate
   * - Certificate Usage
     - Server Certificate
   * - Server/Client Name
     - The certificate DNS name, for instance ``example.azurebase.net``
   * - Common name
     - The CN of the certificate, for instance ``example.azurebase.net``

See `information about internal APG certificates <https://cloudapg.sharepoint.com/sites/SecurityFirst/SitePages/Inf.aspx>`__ for further information.
After approval from security the certificate is automatically signed, the process adds the resulting ``cer`` file to the ServiceNow request. The process signs the certificate with the CA02-DC certificate.

3a. Import the internal signed certificate in the Key Vault
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Import the complete certificate chain in the Key Vault. Concatenate the ``cer`` file with the CA02-DC and CA01-APG certificates and import it in the Key Vault:

.. code-block:: powershell

  $apiCertFile = Join-Path -Path $(Build.SourcesDirectory) -ChildPath "path of the cer file from the ServiceNow request"
  $domainCertificateName = "example"
  $keyVaultName = "examplekv"

  $ca02CertFile = Join-Path -Path $(Agent.TempDirectory) -ChildPath CA02-DC.crt
  Invoke-WebRequest -Outfile $ca02CertFile -Uri http://prime03.office01.internalcorp.net/crt/CA02-DC.crt
  $ca01CertFile = Join-Path -Path $(Agent.TempDirectory) -ChildPath CA01-APG.crt
  Invoke-WebRequest -Outfile $ca01CertFile -Uri http://prime03.office01.internalcorp.net/crt/CA01-APG.crt

  $certFile = Join-Path -Path $(Agent.TempDirectory) -ChildPath "$domainCertificateName.cer"
  Get-Content -Path $apiCertFile, $ca02CertFile, $ca01CertFile | Set-Content -Path $certFile
  Import-AzKeyVaultCertificate -VaultName $keyVaultName -Name $domainCertificateName -FilePath $certFile

See `add certificates in Key Vault <https://learn.microsoft.com/en-us/azure/key-vault/certificates/create-certificate-signing-request?tabs=azure-powershell#add-certificates-in-key-vault-issued-by-non-partnered-cas>`__.

3b. Import the external signed certificate in the Key Vault
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Import the complete certificate chain in the Key Vault. Concatenate the ``cer`` file with the DigiCertCA certificate and import it in the Key Vault:

.. code-block:: powershell

  $apiCertFile = Join-Path -Path $(Build.SourcesDirectory) -ChildPath "path of the cer file from the ServiceNow request"
  $intermediateCertFile = Join-Path -Path $(Build.SourcesDirectory) -ChildPath "path of the DigiCertCA file from the ServiceNow request"
  $domainCertificateName = "example"
  $keyVaultName = "examplekv"

  $certFile = Join-Path -Path $(Agent.TempDirectory) -ChildPath "$domainCertificateName.cer"
  Get-Content -Path $apiCertFile, $intermediateCertFile | Set-Content -Path $certFile
  Import-AzKeyVaultCertificate -VaultName $(apiKeyVaultName) -Name $(domainCertificateName) -FilePath $certFile

See `add certificates in Key Vault <https://learn.microsoft.com/en-us/azure/key-vault/certificates/create-certificate-signing-request?tabs=azure-powershell#add-certificates-in-key-vault-issued-by-non-partnered-cas>`__.

4. Query the host name bindings and remove the existing bindings
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. note:: This step applies when the web app already has a host name binding. According to `configure bindings <https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-bindings>`__, you can use the command ``Remove-AzWebAppSSLBinding`` for a combination of importing the certificate and securing the custom DNS name with a TLS/SSL binding. 3 policies deny this: ``DRCP-Generic-AppServiceSiteHttpsOnlyEnabled``, ``DRCP-Generic-AppServiceSitePublicNetworkAccessEnabled`` and ``DRCP-Generic-AppServiceSiteVNetRouteAll``. The command ``Remove-AzWebAppSSLBinding`` generates a deployment with all default Web App settings.

.. code-block:: powershell

  $webAppName = "$(functionAppName)"
  $resourceGroupName = "$(apiResourceGroupName)"
  $sslBindings = Get-AzWebAppSSLBinding -ResourceGroupName $resourceGroupName -WebAppName $webAppName

You can use a bicep for disable host name bindings.

.. code-block:: powershell

  resource disableHostNameBinding 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
    parent: functionApp
    name: customDomain
    properties: {
      sslState: 'Disabled'
    }
  }

5. Map the custom DNS domain name
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
See `Map existing custom DNS name <https://learn.microsoft.com/en-us/azure/app-service/app-service-web-tutorial-custom-domain?tabs=subdomain%2Cpowershell#optional-automate-with-scripts>`__.

.. code-block:: powershell

  Set-AzWebApp -Name $appName -ResourceGroupName $resourceGroupName -HostNames @("$certificateDNS","$defaultHostName")

6. Export the .pfx-file from the Key Vault
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
The Key Vault contains the signed certificate, including the private key. Export the certificate from the Key Vault, see `Export certificates from Azure Key Vault <https://learn.microsoft.com/en-us/azure/key-vault/certificates/how-to-export-certificate?tabs=azure-powershell>`__.

.. code-block:: powershell

  $certPassword = "keepThisSecret"
  $pfxSecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $domainCertificateName -AsPlainText
  $secretByte = [Convert]::FromBase64String($pfxSecret)
  $x509Cert = New-Object -TypeName Security.Cryptography.X509Certificates.X509Certificate2($secretByte, $null, [Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
  $pfxByte = $x509Cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, "$certPassword")
  $pfxBytesBase64 = [Convert]::ToBase64String($pfxByte)

7. Import the certificate in the Web App
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note:: According to `configure bindings <https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-bindings>`__, you can use the command ``New-AzWebAppSSLBinding`` for a combination of importing the certificate and securing the custom DNS name with a TLS/SSL binding. 3 policies deny this: ``DRCP-Generic-AppServiceSiteHttpsOnlyEnabled``, ``DRCP-Generic-AppServiceSitePublicNetworkAccessEnabled`` and ``DRCP-Generic-AppServiceSiteVNetRouteAll``. The command ``New-AzWebAppSSLBinding`` generates a deployment with all default Web App settings.

You can use a bicep for this action.

.. code-block:: powershell

  resource cert 'Microsoft.Web/certificates@2022-09-01' = {
    name: certificateName
    location: location
    properties: {
      password: certPassword
      pfxBlob: pfxBytesBase64
      serverFarmId: plan.id
    }
  }

8. Secure the custom DNS name with a TLS/SSL binding
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
You need the thumbprint of the certificate, use the command:

.. code-block:: powershell

  $thumbprint = (Get-AzKeyVaultCertificate -VaultName $KeyVaultName -Name $domainCertificateName).Thumbprint

You can use the following bicep for this action:

.. code-block:: powershell

  resource binding 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = {
    parent: functionApp
    name: certificateDNS
    properties: {
      siteName: functionAppName
      sslState: 'SniEnabled'
      thumbprint: thumbprint
    }
  }

See `configure bindings <https://learn.microsoft.com/en-us/azure/app-service/configure-ssl-bindings>`__.

9. Register a CNAME record in the private DNS zone azurebase.net
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Request registration of a CNAME record in the private DNS zone 'azurebase.net' via a request in ServiceNow.

.. list-table::
   :widths: 10 25
   :header-rows: 1

   * - Request field
     - Value
   * - Name
     - The domain certificate name, for instance 'example'
   * - TTL
     - Time to live, default = 3600 (one hour)
   * - Value
     - The default host name, for instance 's1abcenv12345wefa-dev01.s1abcenv12345wease-dev01.appserviceenvironment.net'

10. Call the app
^^^^^^^^^^^^^^^^
You can now test the new name to call the app.
To call the app from the build server using a private certificate, add the internal root certificates to the private build agents trust store, see :doc:`Internal root certificate chain <../../Application-development/Certificates/Internal-root-certificate-chain>`.