App registrations
=================

Consent Limitation
------------------
| The automation of your Environment creates an app registration to use in Azure DevOps.
| It receives the Microsoft Entra ID role ``Application Developer`` and the Microsoft Graph privilege ``Application.ReadWrite.OwnedBy``.

| For ``Application.ReadWrite.OwnedBy`` the app registration needs ``admin consent``.
| A form in ServiceNow is available for requesting this consent.

   - Go to the self service infrastructure catalog in ServiceNow `here <https://apgprd.service-now.com/now/nav/ui/classic/params/target/catalog_home.do%3Fsysparm_catalog%3D0a334d003734ee003486f01643990e3b%26sysparm_catalog_view%3Dcatalog_infrastructure_catalog>`__. 
   - Select IAM services.
   - Use the form 'Request consent for app registration'.

| When a DevOps team's automation creates a service principal, their automation becomes the owner of the app registration.
| The ownership, combined with the Microsoft Graph privilege ``Application.ReadWrite.OwnedBy`` means they can maintain the setup and request privileges.

| These privileges require IAM-DA reviews.

Assigned Privileges
-------------------
| The service principal of the ADO environment has the following privileges:

   - the Built-in Role: ``Application Developer``
   - The Microsoft Graph Permission: ``Application.ReadWrite.OwnedBy``

Creating app registrations
==========================
| This allows for the creation and configuration of app registrations and service principals.
| The Pipeline can therefor run commands such as:

.. code-block:: powershell

   $environmentAppRegistration = New-MgApplication -DisplayName $EnvironmentAppRegistrationDisplayName -ErrorAction Stop

| Read `here <https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.applications/New-MgApplication?view=graph-powershell-1.0>`__ on the how to use New-MgApplication.

Requesting Graph Consent
========================
| To request the Graph consent there are two things to understand:

   1. The commands are an update for the app registration (and not an add consent).
   2. The commands use a lot of built-in GUIDs.

.. code-block:: powershell

   Connect-MgGraph -tenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
   $appId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'

   $requiredGrants = New-Object -TypeName System.Collections.Generic.List[Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess]
   $requiredResourceAccess = New-Object -TypeName Microsoft.Graph.PowerShell.Models.MicrosoftGraphRequiredResourceAccess
   $requiredResourceAccess.ResourceAppId = "00000003-0000-0000-c000-000000000000"
   $requiredResourceAccess.ResourceAccess+=@{ Id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"; Type = "Scope" }
   $requiredResourceAccess.ResourceAccess+=@{ Id = "18a4783c-866b-4cc7-a460-3d5e5662c884"; Type = "Role" }
   $requiredGrants.Add($requiredResourceAccess)

   Update-MgApplication -ApplicationId $appId -RequiredResourceAccess $requiredGrants

The three GUIDs in this code-block are:
   - ``00000003-0000-0000-c000-000000000000`` - which translate to the Microsoft Graph API.
   - ``e1fe6dd8-ba31-4d61-89e7-88639da4683d`` - which translate to the Microsoft Graph Scope ``User.Read``.
   - ``18a4783c-866b-4cc7-a460-3d5e5662c884`` - which translates to the Microsoft Graph Role ``Application.ReadWrite.All``

| Read `here <https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.applications/Update-MgApplication?view=graph-powershell-1.0>`__ on the how to use Update-MgApplication.

Graph Globally Unique Identifiers
---------------------------------
| To find appropriate GUIDs for Microsoft Graph

.. code-block:: powershell

   Find-MgGraphPermission application.Read | Format-List

| This will give you the overview to translate graph-permissions to a GUID

Creating AppRoles
=================
| When a user signs in to the application, Microsoft Entra ID emits a roles claim for each role that the user or service principal has.
| This implements claim-based authorization.

.. code-block:: powershell

   Connect-MgGraph -tenantId 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
   $appId = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
   # Get Collection of existing roles.
   $app = Get-MgApplication -ApplicationId $appId
   $appRoles = $App.AppRoles
   # Create a new role.
   $Id = [Guid]::NewGuid().ToString()
   $newAppRole = New-Object Microsoft.Graph.PowerShell.Models.MicrosoftGraphAppRole
      $newAppRole.AllowedMemberTypes = @("User", "Application")
      $newAppRole.DisplayName = $AppRoleDisplayName
      $newAppRole.Description = $AppRoleDescription
      $newAppRole.Value = $AppRoleValue
      $newAppRole.Id = $Id
      $newAppRole.IsEnabled = $true
   # Add to the collection and update.
   $appRoles += $newAppRole
   Update-MgApplication -ApplicationId $appId -AppRoles $appRoles