Release 23-3 02
===============
Release date: July 18, 2023


Breaking change
---------------

- The parameter **customerEnvironmentId** is no longer allowed when calling the mandatory-template.yml in customer pipelines under **extends:**.


What's new for users
--------------------
- DRCP Maintenance process for environments is in place:
   - It's mandatory to select a maintenance day and time while creating an environment through the DRCP portal.
   - Environments created before 18/July/2023 and don't have maintenance day and time set, will get enforced to Wednesday 00:00.
   - It's now possible to change the maintenance day and time using the "Change maintenance details" Quick action in the DRDC portal.
   - Every week on the maintenance day and time of the environment, ServiceNow creates an automated change and enforces a refresh of the environment.
- Added the security-baseline for Azure Kubernetes Service.
- Added the use-cases guidance for Azure Kubernetes Service including the DNS use-case.
- The mandotory-template.yml will log information to ServiceNow when creating or updating a change.