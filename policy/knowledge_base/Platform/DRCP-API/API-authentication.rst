API authentication
==================

Authentication to the DRCP APIs requires a bearer token. Request this token through the service connection which is also responsible for deployments. This page details on how to use the service connection in Azure DevOps to request a token for the DRCP API.

Requesting the Microsoft Entra ID bearer token
----------------------------------------------
Please find below an example on how to authenticate to the DRCP APIs.

Take note of the following:

* The ``azureSubscription:`` service connection for your Subscription.
* ``addSpnToEnvironment:`` set to ``true`` to allow anonymous identity and secret extraction for authentication.
* ``scope=`` in the bearer token set to ``api://<apiApplicationId>/.default`` where the ``<apiApplicationId>`` is the identity of the application registration functioning as the authentication provider for the API. This may vary per API.
* First request a Microsoft Entra ID bearer token, with its scope set to the API, and use that bearer token to call the ``<apiUrl>`` API functions.
* The task in this example uses ``AzureCLI`` to get some environment (``$env:servicePrincipalId``, ``$env:servicePrincipalKey``, ``$env:tenantId``) variables which aren't available in an ``AzurePowerShell`` task. You may split the task and first retrieve the environment variables with an ``AzureCLI`` task and proceed with an ``AzurePowerShell`` task to execute the API calls.

.. code-block:: yaml

    - task: AzureCLI@2
      name: ExampleAccessDrcpApi
      displayName: Example for accessing the DRCP API
      continueOnError: false
      inputs:
        azureSubscription: SC-<ApplicationSystemName>-<EnvironmentName>
        scriptType: pscore
        scriptLocation: inlineScript
        addSpnToEnvironment: true
        inlineScript: |
          # Get the bearer token to access the DRCP API.
          $param  = @{
              Uri     = 'https://login.microsoftonline.com/$env:tenantId/oauth2/v2.0/token'
              Method  = "POST"
              Body    = @{
                  grant_type    = "client_credentials"
                  client_id     = $env:servicePrincipalId
                  client_secret = $env:servicePrincipalKey
                  scope         = "api://<apiApplicationId>/.default"
              }
          }
          $bearerToken = (Invoke-RestMethod @param).access_token

          # Accessing the API with a GET operation.
          $param = @{
              Uri     = "<apiUrl>"
              Method  = 'GET'
              Headers = @{
                  'Authorization'  = "Bearer $bearerToken"
                  'Content-Type'   = 'application/json'
              }
          }
          $response = Invoke-RestMethod @param
