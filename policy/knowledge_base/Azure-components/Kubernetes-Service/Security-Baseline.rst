Security baseline Kubernetes Service
====================================

Major change history
--------------------
.. list-table::
   :widths: 5 25 20 5
   :header-rows: 1

   * - Version.
     - Date
     - Name
     - Function/Reason
   * - 0.1
     - January 23, 2023
     - Bas van den Putten
     - Initial version.
   * - 0.2
     - July 14, 2023
     - Bas van den Putten
     - Added baseline controls.
   * - 0.3
     - August 25, 2023
     - Martijn van der Linden
     - Sanitize baseline.
   * - 1.0
     - June 19, 2024
     - Onno Hettema
     - Added identifiers to the baseline controls.

.. |AzureComponent| replace:: Kubernetes Service
.. include:: ../../_static/include/security-baseline-header1.txt
.. include:: ../../_static/include/security-baseline-header2.txt

.. list-table::
   :widths: 05 20 25 05 05 05 05 05 15 10
   :header-rows: 1

   * - ID.
     - Description
     - Rationale
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for monitoring
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-aks-01
     - Ensure TLS routing on the ingress controller.
     - The inbound connections needs to be verifiable and trusted. To ensure this the inbound connection needs to use a secure protocol.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Communication protocols are part of the Global Design and DHT process.
     - Biyearly approval process via DHT.
   * - drcp-aks-02
     - Ensure that network endpoints are private.
     - The Cluster and control plane shouldn't use publicly exposed end-points. AKS isn't exposed as a service to outside the APG network. Creating public exposure needs to happen via controlled routes.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforced via two Azure policies: to prevent that the individual nodes to have a public IP, To prevent that it's possible to create a cluster in any mode other then private.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-03
     - Ensure that authorization and authentication use Microsoft Entra ID.
     - Microsoft Entra ID and the privileges are an easy way to create a secure way to authenticate towards the applications. Using local identity stores avoids the IAM process.
     - L
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce via an Azure policy that ensures clusters use AzureAD authentication.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-04
     - Ensure that roles, which can manage the AKS Cluster, are containing users or groups within the TAP-usages.
     - Group membership follow the IAM Process including for membership. Adding individual user assignments break this process and are therefor forbidden for TAP.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce via a policy that limits the ability to add individual users to privileged roles.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-05
     - Don't permit containers to run with the hostPID flag set to true.
     - A container running in the host's PID namespace can inspect processes running outside the container. If the container also has access to "ptrace" capabilities which allows to escalate privileges outside of the container.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce via a policy that limits the ability to use HostPID.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-06
     - Deny privileged container admission to AKS.
     - Privileged containers have access to all Linux Kernel capabilities and devices. A container running with full privileges can do almost everything that the host can do. This flag exists to allow special use-cases, like manipulating the network stack and accessing devices.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy that denies creation of Privileged containers.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-07
     - Don't permit containers to run with the hostNetwork flag set to true.
     - A container running in the host's network namespace could access the local loopback device, and could access network traffic to and from other pods.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a deny policy that denies creation of containers with hostNetwork flag set to true.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-08
     - Don't allow SYS_ADMIN capabilities.
     - This is the new "root" since it confers a wide range of powers, and its broad scope means that this is the capability that privileged programs require.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy that denies containers with the SYS_ADMIN capability
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-09
     - Disable the admission of containers with the NET_RAW capability (Manual)
     - NET_RAW is a default permissive setting in Kubernetes allowing ICMP traffic between containers and grants an application the ability to craft raw packets. In the hands of an attacker NET_RAW can enable a wide variety of networking exploits from within the cluster.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy that denies containers with the NET_RAW capability.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-10
     - Disable the admission of containers with allowPrivilegeEscalation
     - Pods should run as a defined user or group and not as root. Only assign the required user or group permissions, and don't use the security context to assume permissions. The runAsUser, privilege escalation, and other Linux capabilities settings is for Linux nodes and pods.
     - M
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy that denies containers without a security context with the flag allowPrivilegeEscalation not set to false.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-11
     - Enable Azure Policy Extension on the cluster.
     - Azure Policy extends Gatekeeper v3, an admission controller webhook for Open Policy Agent (OPA), to apply at-scale enforcements and safeguards on your clusters in a centralized, consistent manner. Azure Policy makes it possible to manage and report on the compliance state of your Kubernetes clusters from one place.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce a policy that monitors that the OPA gateway is active.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-12
     - Ensure that clusters are running a supported version.
     - AKS versions retire on a regular basis. Application systems need to stay at least within the supported versions within DRCP.

       **DRCP can force retirement of known vulnerable versions**

       `Supported Kubernetes versions in Azure Kubernetes Service <https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions?tabs=azure-cli>`__.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Enforce via LCM processes within APG. Identification via Azure Policy.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-13
     - Ensure that node-pools are appropriately updated
     - AKS uses node-pools. These are running on images that Microsoft maintains and controls. DevOps teams need to update the images periodically.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - every three months report on the node-image via screenshot.
     - Manual.
   * - drcp-aks-14
     - Ensure that all containers have a security context set
     - A security context defines privilege and access control settings for a Pod or Container. By enforcing the settings, developers need to reduce the amount of privileges a container can escalate to.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Ensure that a container has a security container.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-15
     - Ensure that the default namespace is empty.
     - Kubernetes provides a default namespace. Resources in a Kubernetes cluster should placed in pre-planned namespaces, to allow for security controls to take effect and to make it easier to manage resources.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Ensure that no containers run in the Default namespace.
     - Manual.
   * - drcp-aks-16
     - Disable Command Invoke on Azure Kubernetes Service clusters
     - You can use command invoke to access private clusters without having to configure a VPN or Express Route. Which makes another endpoint that needs to inaccessible.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Ensure that: The Command Invoke isn't enabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-17
     - Ensure nodes are in a dedicated subnet
     - When the nodes are in a dedicated subnet, away from the ingress controller and other items. Access to the containers doesn't implicitly give network access to nodes.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Communication protocols are part of the Global Design and DHT process.
     - Biyearly approval process via DHT.
   * - drcp-aks-18
     - Use the Microsoft Defender for Cloud built-in threat detection capability and enable Microsoft Defender for your Azure Kubernetes Service.
     - Defender for Cloud has maintained list of exploit identification for Azure Kubernetes Service.
     - H
     - C = 1
     - PO DRCP
     - Team Azure Ignite
     - DevOps team
     - Ensure that: Defender for Kubernetes Service isn't disabled.
     - Microsoft Defender for Cloud. Compliant policy.
   * - drcp-aks-19
     - Enable Diagnostic Settings for AKS.
     - Exporting logs and metrics to a dedicated, persistent and central log storage ensures availability of audit data following a cluster security event. Store the following logs: - "kube-audit" - "``kube-audit-admin``" - "kube-apiserver" - "kube-controller-manager" - "kube-scheduler"
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Screenshot
     - Manual
   * - drcp-aks-20
     - Ensure secrets are periodically updated in the cluster.
     - Azure Kubernetes Service uses secrets to maintain the services and offers automatic rolling.
     - H
     - C = 1
     - PO DevOps team
     - Team Azure Ignite
     - DevOps team
     - Screenshot of two commands
     - Manual



**Manual Evidences**

Microsoft allows for in-dept control, for some checks and balances there are no automated control to verify the state.
For these the DevOps Team is responsible to gather and maintain the evidences in the context of their environments:

Control drcp-aks-13: Updating node images

.. code-block:: powershell

  az aks nodepool show --resource-group <<myRG>> --cluster-name <<myCluster>> --name <<nodepool name>> --query nodeImageVersion

Control drcp-aks-19: Secret rolling

.. code-block:: powershell

  powershellcurl https://{apiserver-fqdn} -k -v 2>&1|grep expire
  az vmss run-command invoke --resource-group "MC_rg_myAKSCluster_region" --name "vmss-name " --command-id RunShellScript --instance-id 1 --scripts "openssl x509 -in /etc/kubernetes/certs/apiserver.crt -noout -enddate" --query "value[0].message"

=======
C = 3
=======
This baseline follows the Confidentiality, Integrity, and availability needs of the Application system.
When your application is Confidentiality (C) = 3, more needs come into play.

.. list-table::
   :widths: 05 20 30 05 05 05 10 15 10
   :header-rows: 1

   * - ID.
     - Reason
     - Description
     - Risk (H/M/L)
     - Applicable CIA rating
     - Owner
     - Responsible for implementation
     - Control framework
     - Proof
   * - drcp-aks-21
     - Install an overlay service to encrypt the data in-transit.
     - AKS containers can communicate inside the cluster and data between nodes will be send over http/80. Traffic encryption helps to keep the cluster secure. Containers need to communicate inside the cluster via pre-determined paths. Use the AKS mesh to control the network communication.
     - H
     - C = 3
     - PO DevOps team
     - DevOps team
     - Azure Policy
     - Microsoft Defender for Cloud. Compliant policy.

.. include:: ../../_static/include/security-baseline-footer.txt
