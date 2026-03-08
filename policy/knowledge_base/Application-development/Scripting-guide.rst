Scripting guide
===============

.. contents::
   Contents
   :local:
   :depth: 2

This page contains tips, tricks, and known issues related to scripting languages in your development environment on the DRCP platform.

PowerShell
----------

Microsoft Graph authentication
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

| Please be aware when using the ``Microsoft.Graph`` PowerShell module, that Microsoft changed the authentication method in the ``Connect-MgGraph`` command from module major version 2 and higher.
| Module version 1.x requires to leverage the ``AzureRmProfileProvider`` object to retrieve a valid token from the current PowerShell Azure context, while version 2.x and higher requires to use ``Get-AzAccessToken``.
| Below you'll find a code snippet you can use to make your code compatible with both major versions.

.. code-block:: powershell

   # Authenticate to Microsoft Graph API.
   if ((Get-Module -Name $graphModuleName -ListAvailable | Sort-Object Version -Descending)[0].Version.Major -lt 2) {
         $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
         $graphToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.microsoft.com").AccessToken
   }
   else {
         $graphtoken = (Get-AzAccessToken -ResourceTypeName MSGraph -AsSecureString).token
   }
   Connect-MgGraph -AccessToken $graphToken
