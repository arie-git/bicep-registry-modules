Use cases Notification Hubs
===========================

.. include:: ../../_static/include/component-usecasepage-header.txt

Azure Notification Hubs
-----------------------
| `Azure Notification Hubs <https://learn.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-overview>`__ is a scalable push notification service designed to deliver messages to devices and applications.
| DevOps teams can efficiently send targeted notifications to users on platforms, ensuring consistent and reliable communication across devices.

Authentication and Authorization
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Notification Hubs require secure authentication to ensure controlled access. DevOps teams configure authentication using **Microsoft Entra ID-based RBAC** (for control plane access) and **Shared Access Policies** (for data plane access), depending on the application's access needs.

Microsoft Entra ID enables DevOps teams to grant specific permissions to users and applications without relying on static access keys. Role assignments control who can send messages, manage hub settings, or retrieve telemetry. When configuring access through Microsoft Entra ID, DevOps teams must define the appropriate roles in Azure and assign them to the required service principals or managed identities.

Shared Access Policies provide an alternative authentication mechanism when Microsoft Entra ID isn't applicable. DevOps teams must create custom policies with the minimum necessary permissions to ensure system security. DevOps teams must not grant **Full Access** to Notification Hubs. This could increase the risk of accidental or malicious actions that compromise system integrity. DevOps teams must review all policies periodically to ensure compliance with security baselines.

Scaling and Performance
^^^^^^^^^^^^^^^^^^^^^^^
Notification Hubs operate within defined capacity limits based on the selected pricing tier. DevOps teams are responsible for ensuring that their Notification Hubs operate within the limits set by the selected pricing tier, while also maintaining reliable message delivery. See article `Notification Hubs pricing <https://azure.microsoft.com/en-us/pricing/details/notification-hubs/>`__ for an actual overview.

Throughput and quota restrictions depend on the **tier selection**. When a Notification Hub approaches its message quota, the system might delay or drop messages. DevOps teams must track usage metrics to ensure that throughput remains within acceptable thresholds.

Scope
^^^^^
See article :doc:`Security baseline Notification Hubs <Security-Baseline>` for an actual overview of the scope of this component.

Use cases and follow-up
-----------------------

Enable resource logging for security investigation
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Notification Hubs generate resource logs that provide enhanced service-specific metrics and logging. Customers can configure these logs for both Notification Hubs and Notification Hub namespaces, and send them to their own data sink, such as a storage account or Log Analytics workspace.

Disallowed configuration of cross-region disaster recovery
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Azure Notification Hubs offers disaster recovery via Geo-DR, replicating your hub to a secondary region for fail-over. DRCP disallows the replication because APG doesn't have active paired regions, and configuring this will incur costs without more uptime.

Availability zones Sweden Central are mandatory
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| You can enable availability zones on new namespaces. Because Notification Hubs doesn't support the migration of existing namespaces, you can't disable zone redundancy after enabling it on your namespace.
| To learn how to set up a new namespace with availability zones, check the `Quickstart: Create an Azure notification hub in the Azure portal <https://learn.microsoft.com/en-us/azure/notification-hubs/create-notification-hub-portal>`__ documentation at the Microsoft website.

Compliance control on Shared Access Policies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
DRCP prohibits the existence of the default Shared Access Policies (``DefaultFullSharedAccessSignature`` and ``DefaultListenSharedAccessSignature``) through :doc:`security baseline <Security-Baseline>` control ``drcp-ntf-01`` and it's related Azure policy. 

DevOps teams can check their environments to confirm compliance using the example below, that provides a method to verify whether default Shared Access Policies are still present.

Example script: Compliance check

.. code-block:: powershell

   $authRules = Get-AzNotificationHubAuthorizationRules -ResourceGroup $ResourceGroupName -Namespace $NamespaceName -NotificationHub $HubName
   $defaultPolicies = @("DefaultListenSharedAccessSignature", "DefaultFullSharedAccessSignature")

   # Validate the presence of the default access policies.
   $policyResult = @()
   foreach ($policy in $defaultPolicies) {
      $policyExists = $authRules | Where-Object { $_.Name -eq $policy }
      $policyResult += [PSCustomObject]@{
         Policy = $policy
         Exists = $policyExists -ne $null
      }
   }

   # Compliance check.
   $nonCompliantPolicies = $policyResult | Where-Object { $_.Exists -eq $true }

   if ($nonCompliantPolicies.Count -eq $defaultPolicies.Count) {
      Write-Information -MessageData "Default access policies are present. The default access policies are NOT compliant, and should be removed."
      $nonCompliantPolicies | ForEach-Object { Write-Host "Non-Compliant default access policy Found: $($_.Policy)" }
   }
   else {
      Write-Information -MessageData "No default access policies found. The deployment is compliant."
   }

Removing unwanted Shared Access Policies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
In case the default Shared Access Policies are present, DevOps teams must remove them to be compliant with  :doc:`security baseline <Security-Baseline>` control ``drcp-ntf-01``.

The following example demonstrates how to remove default Shared Access Policies from a Notification Hub.

.. code-block:: powershell

   $defaultPolicies = @("DefaultListenSharedAccessSignature", "DefaultFullSharedAccessSignature")
   $nonCompliantPolicies = $authRules | Where-Object { $_.Name -in $defaultPolicies }
   foreach ($policy in $nonCompliantPolicies) {
      try {
         Remove-AzNotificationHubAuthorizationRule -ResourceGroup $ResourceGroupName -Namespace $NamespaceName -NotificationHub $HubName -AuthorizationRule $policy.Name -Force
         Write-Information -MessageData "Access policy '$($policy.Name)' removed successfully."
      }
      catch {
         Write-DrcpError -Message "Failed to remove default access policy '$($policy.Name)'. Please see error details." -ErrorObject $_
      }
   }

Creating custom Shared Access Policies
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To enforce controlled access to Notification Hubs, DevOps teams must configure access by creating custom Shared Access Policies. This ensures that the configuration grants required permissions, preventing excessive access while maintaining necessary functionality.

A JSON definition file specifies the policy configuration, including its name and assigned permissions. The following example demonstrates how to create a custom Shared Access Policy.

Example JSON file: ``NHExampleListenPolicy.json``

.. code-block:: powershell

   {
      "Name": "NHExampleListen",
      "Rights": [
         "Listen"
      ]
   }

See `Microsoft documentation <https://learn.microsoft.com/en-us/azure/notification-hubs/create-notification-hub-template?tabs=PowerShell>`_ for more information about the creation of Notification Hubs JSON files.

Example script: Creating custom access policies

.. code-block:: powershell

   # Create a custom access policy.
   try {
      New-AzNotificationHubAuthorizationRule -ResourceGroup $ResourceGroupName -Namespace $NamespaceName -NotificationHub $HubName -InputFile 'NHExampleListenPolicy.json'
      Write-Information -MessageData "Custom access policy 'NHExampleListen' created successfully."
   }
   catch {
      Write-DrcpError -Message "Failed to create custom access policy 'NHExampleListen'. Please see error details." -ErrorObject $_
   }


Further references and best practices
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
| `Azure Notification Hubs Documentation <https://learn.microsoft.com/en-us/azure/notification-hubs>`__
| `Security Best Practices <https://learn.microsoft.com/en-us/azure/notification-hubs/notification-hubs-push-notification-security>`__
| `Monitoring and Diagnostics <https://learn.microsoft.com/en-us/azure/notification-hubs/monitor-notification-hubs>`__
