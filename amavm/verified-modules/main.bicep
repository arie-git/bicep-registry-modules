# Introduction

This repository will host APG specific Azure IaC modules to provision infrastructure in Azure. The goal is to provide DRCP compliant reusable infrasture modules which can be easily consumed.

## Repository Structure

This repository's folders are broadly categorized into following categories:

* bicep/ - This folder contains infrastructure related components
  * res/ - This folder contains IaC modules for various types of infrastructure resources (e.g. storage accounts, key vault, databricks etc).
    * (namespace)/(resource_type)/ - This folder contains IaC module for a resource type
      * main.bicep - this file contains module's bicep code
      * README.md - this file contains module's documentation for end user consumption, including usage examples
      * version.json - this file contains major.minor version configuration for the module
      * upstream.json - this file contains major.minor version of the upstream repo module that was last used for changes sync
      * tests/ - This contains unit tests, end to end (e2e) tests, and other tests applicable on the module level as per design specs
      * (sub_type) - (optional) this folder contains a subtype of the resource
        * main.bicep - this file contains the subtype's implementation in bicep
        * version.json - (optional) if present, this file defines that the subtype resource must be published as an independent module, and contains major.minor version of the module
        * (modules) - (optional) this folder contains child or extension resources used by a subtype
  * ptn/ - Pattern is a combination of a number of resource modules which in combination creates a deployable pattern.
* bicep-shared/ - This folder contains shared include files which can be used across multiple bicep modules
* pipelines/ - This (will) contains generic pipeline to deploy any pattern or resource.
  * nightly_build/ - This (will) contains nightly build pipeline to deploy a module. The purpose is to test that the module can successfully deploy.
  * publish/ - This (will) contains pipelines to publish the module
* samples/ - This provides code of sample application deployments showcasing how to consume the IaC modules together.
* utils/ - This contains various utility scripts used in the SDLC process (e.g. building, testing, publishing, etc.)

## SDLC Process

### Coding a module

in progress ...

The file 'version.json' should contain AMAVM version, not the upstream version.
The file 'upstream.json' should contain the upstream module version that AMAVM module is based on.

In main.bicep:

* metadata field 'owner' - set to 'AMCCC'
* add two metadata field 'compliance' and 'complianceVersion'
* add 'evidenceOfNonCompliance' output parameter
* replace in-file definitions of shared bicep types with imports from '/bicep-shared/types.bicep'
* in resource avmTelemetry replace '46d3xbcp' with 'amavm1' in name field. Also make sure the name field is truncated to 64 chars.
* modify role definitions
  * add `import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'`
  * rename preexisting 'builtInRoleNames' to 'specificBuiltInRoleNames'
  * remove common roles from 'specificBuiltInRoleNames'
  * add `var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)`
* add `var finalTags = union(tags ?? {}, { telemetryAVM: telemetryId })` and replace the use of 'tags' with 'finalTags'
* remove `{ categoryGroup: 'allLogs' }` from diagnostic settings and replace it with a list of categories supported by the module

### Module's documentation

A documentation must be created as part of creating a module, and is a part of PR review process.

It shall be captured in `README.md` file located in the modules folder (under 'bicep/(namespace)/(resource_type)') and must describe the module's parameters, outputs, and examples of its usage.

#### Tooling

This repository uses automation to generate this documentation. The script to generate the md-file is `utils/setModuleReadMe.ps1`, and it requires the following:

* module's `main.bicep` must contain the following metadata:
  * 'name'
  * 'description'
  * 'compliance'
  * 'complianceVersion'
* module's `main.bicep` contains 'Required'/'Optional'/'Conditional'/'Generated' words at the beginning of each module's parameter's @decription() decorator.
* `tests/e2e` subfolder exists under the module that contains the following folders with compilable examples of using the module:
  * `defaults`
  * `max`
  * `waf*aligned`

The script will:

* analyze the bicep source code, by converting it into a JSON model and looking at input parameters, deployed resources/modules, and outputs
* analyze 'tests' subfolder for implemented test cases
* use the analysis to generate the following sections:
  * Intro
  * 'Navigation'
  * 'Compliance' (using 'compliance' and 'complianceVersion' metadata)
  * 'Resource types' (analyzing all resource*level APIs that are used in the module)
  * 'Usage examples' (using the code from implemented test cases)
  * 'Parameters' (if user*defined types are used, those are analyzed into a final primitive type)
  * 'Outputs'
  * 'Cross*referenced modules'
  * 'Data collection' (using hard*coded statement about the telemetry and data collected)

Example of using the script:

```powershell
Import-Module .\utils\setModuleReadMe.ps1 -Force

Set-ModuleReadMe -TemplateFilePath 'C:\Users\aa03502\Sources\drcpado\verified-modules\bicep\res\databricks\access-connector\main.bicep'
```

The script is sources from the upstream AVM repository, and the date of synchronizing its content with the upstream is captured in a comment on line 3 of the script.

From time to time, the team shall analyze upstream changes and bring them into the script.

### Building

There are two flavours of building the module: quick and full.

During the quick building of a module the following happens:

* code checking
* generating README.md and checking if there are to diffs compared to the one in the repo
* running static analysis unit-tests (not involving test deployments)

During the full build, additionally the following happens:

* running deployment unit-tests
* running security vulnerabilities tests

Building the modules happens on following occasions:

* (CI) automatically run as part of every push to the repository, non-blocking
* automatically during the PR process, blocking the PR in case of failure
* (CD) automatically before the Publishing step, blocking the publishing in case of failure
* manually, when run by a developer from the command line or by triggering a pipeline

### Tooling

`.\utils\buildBicepFiles.ps1` will build Bicep modules, including the documentation.

Parameters:

* modulesRootPath. Filesystem path to AMAVM bicep modules. Default: "./bicep/"
* modulesSubpath. Filters which modules to publish to a sub-directory under the modulesRootPath. Default: empty
* moduleName. Filters which single module to publish. Default: empty.

### Publishing

Publishing the modules involves:

* building the module (see [Building](#building))
* publishing the module to the Azure Container Registry, names as (path_to)/(modulename):x.y.z
* publishing module's documentation as a static HTML, located under (modulename)/x.y.z folder representing module's semantic version
* publishing updates to the Change Log

#### Tooling

`.\utils\publishToBCR.ps1` will publish Bicep modules

Parameters:

* modulesRootPath. Filesystem path to AMAVM bicep modules. Default: "./bicep/"
* modulesSubpath. Filters which modules to publish to a sub-directory under the modulesRootPath. Default: empty
* moduleName. Filters which single module to publish. Default: empty.
* acrName. The name of Azure Container Registry to publish. Default: "s2amavmdevsecacr"
* repoUri. Uri of the documentation root.

Examples:

`.\utils\publishToBCR.ps1 -moduleName "res/storage/storage-account"` will publish a specific module

`.\utils\publishToBCR.ps1 -modulesSubpath "res/storage/"` will publish modules under a specific path

Alternatively, a module can be published with Azure CLI command. Examples:

`az bicep publish --file bicep/res/network/route-table/main.bicep --target br:s2amavmdevsecacr.azurecr.io/res/network/route-table:0.2.0 --documentation-uri 'https://dev.azure.com/connectdrcpapg1/S02-App-AMAVM/_git/verified-modules?path=/bicep/res/network/route-table/README.md'`

`Publish-ModuleFromPathToPBR -TemplateFilePath 'bicep\res\network\route-table\main.bicep' -PublicRegistryServer $(ConvertTo-SecureString "s2cccdevweacr.azurecr.io" -AsPlainText -Force)`
