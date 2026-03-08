Service principals
==================

Requesting custom API consent
-----------------------------
| When using API is part of Microsoft Entra ID, the requesting app registration needs to request access and become part of an app role.
| To request this API Access, a developer needs to know three things:

| 1. The service-principal ID they want to give an App role on an API.
| 2. The APIs app registration's service principal Id.
| 3. The API of the specific App-role.

The following code-block helps to request the custom API Access for a specific app registration.

.. code-block:: powershell

   $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
   $graphToken = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, "https://graph.microsoft.com").AccessToken
   Connect-MgGraph -AccessToken $graphToken
      $appRoleAssignmentBody = @{
      PrincipalId = $ServicePrincipalId
      ResourceId  = $ApiServicePrincipalId
      AppRoleId   = $ApiAppRoleId
   }
   New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $CustomerServicePrincipalId -BodyParameter $appRoleAssignmentBody | Out-Null

| `Read here on the how to use New-MgServicePrincipalAppRoleAssignment <https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.applications/New-MgServicePrincipalAppRoleAssignment?view=graph-powershell-1.0>`__.

Assigning application roles
---------------------------

| When you configured claim based authentication on app registration, these claims are then available for assigning to users or groups.
| After authentication these claims are than assigned of the token itself.
| This gives the application the opportunity to verify the issuer of the token and also ensure that certain actions are available to its intended audience.

| The following code-snippet assigns the application roles to an Azure Microsoft Entra ID Group or User.

.. code-block:: powershell

   $appRoleAssignment = @{
      "principalId"= "f07a8d78-f18c-4c02-b339-9ebace025122" # The id of the group to which you are assigning the app role.
      "resourceId"= "1c48f923-4fbb-4d37-b772-4d577eefec9e" # The id of the resource servicePrincipal which has defined the app role.
      "appRoleId"= "00000000-0000-0000-0000-000000000000" # The id of the appRole (defined on the resource service principal) to assign to the group.
   }
   New-MgGroupAppRoleAssignment -GroupId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx' -BodyParameter $appRoleAssignment | Format-List

| `Read here on the how to use New-MgServicePrincipalAppRoleAssignment <https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.applications/new-mggroupapproleassignment?view=graph-powershell-1.0>`__.