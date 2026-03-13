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
* improve description to parameters where required, their usage and default value should be clear
* add 'evidenceOfNonCompliance' output parameter
* add two variables 'versionInfo' and 'moduleVersion'
* replace in-file definitions of shared bicep types with imports from '/bicep-shared/types.bicep'
  * **Important:** AMAVM shared types (`diagnosticSettingType`, `privateEndpointType`, `roleAssignmentType`) already include the array suffix (`[]` or `[]?`) in their type definitions. This differs from upstream AVM, where types are singular objects and modules append `[]?` themselves. When using AMAVM shared types, do **not** add `[]?` -- use the type name directly (e.g. `param diagnosticSettings diagnosticSettingType`, not `diagnosticSettingType[]?`, which would create an array-of-arrays).
* in resource avmTelemetry replace '46d3xbcp' with '${telemetryId}$' in name field. Also make sure the name field is truncated to 64 chars.
* modify role definitions
  * add `import { builtInRoleNames as minimalBuiltInRoleNames, telemetryId } from '../../../../bicep-shared/environments.bicep'`
  * rename preexisting 'builtInRoleNames' to 'specificBuiltInRoleNames'
  * remove common roles from 'specificBuiltInRoleNames'
  * add `var builtInRoleNames = union(specificBuiltInRoleNames, minimalBuiltInRoleNames)`
* add `var finalTags = union(tags ?? {}, { telemetryAVM: telemetryId })` and replace the use of 'tags' with 'finalTags'
* remove `{ categoryGroup: 'allLogs' }` from diagnostic settings and replace it with a list of categories supported by the module

### Module's documentation

A documentation must be created as part of creating a module, and is a part of PR review process. When a new module is added, its documentation should also be added to the Table of Contents.

#### Tooling

##### Create README.md

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
  * `waf-aligned`

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

Example of using the script directly:

```powershell
Import-Module .\utils\setModuleReadMe.ps1 -Force
Set-ModuleReadMe -TemplateFilePath 'bicep/res/databricks/access-connector/main.bicep'
```

Alternatively, use `buildBicepFiles.ps1` with the `-buildReadme` flag to generate READMEs for one or more modules in a single command (this also runs `az bicep restore` and `az bicep build`):

```powershell
# Generate README for all modules under a path
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/storage' -buildReadme 'True'

# Generate README for a single module
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/sql' -moduleName 'database' -buildReadme 'True'
```

The script is sourced from the upstream AVM repository, and the date of synchronizing its content with the upstream is captured in a comment on line 3 of the script.

From time to time, the team shall analyze upstream changes and bring them into the script.

##### Convert README.md to HTML

For every new module, use the HTML generator tool to convert the README.md to an HTML page and add this page to the Table of Contents for the documentation website.

The HTML pages are in 'utils\html-assets\readmePublisher\docs', and the ToC is in 'utils\html-assets\readmePublisher\menu\toc.json'

```powershell
cd utils/readmePublisher
python convertreadmetohtml.py --generate-toc --sources-subpath "res/web"
```

In the ToC, every module has a 'category' field. By default for every new module it will have 'Other'. Change the category as needed.

Note that generated HTML pages won't be committed to the repo.

### Building

Building a module validates that the Bicep code compiles and that the README documentation is up to date with the source code.

During the build the following happens:

* `az bicep restore` restores module dependencies
* `az bicep build` compiles the module and checks for errors
* (optionally) README.md is generated from `main.bicep` and compared against the committed version

Building the modules happens on following occasions:

* (CI) automatically on every push to non-main branches via `pipelines/buildBicepFiles.yaml`
* (CD) automatically before the Publishing step, blocking the publishing in case of failure
* manually, when run by a developer from the command line

#### Build Tooling

`utils/buildBicepFiles.ps1` will build Bicep modules, and it can also build the documentation.

Parameters:

* `modulesRootPath` -- filesystem path to AMAVM bicep modules. Default: `"./bicep/"`.
* `modulesSubpath` -- filters modules to a sub-directory under the modulesRootPath. Default: empty (all modules).
* `moduleName` -- filters to a single module. Default: empty.
* `buildReadme` -- when `'True'` it generates README.md from the sources before building. Default: `'False'`.

Examples:

```powershell
# Build all modules
./utils/buildBicepFiles.ps1

# Build modules under a specific path
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/sql'

# Build a single module
./utils/buildBicepFiles.ps1 -modulesSubpath 'res/sql' -moduleName 'database'

# Build with README generation
./utils/buildBicepFiles.ps1 -modulesSubpath 'res' -buildReadme 'True'
```

#### Build Pipeline (CI)

ADO pipeline `pipelines/buildBicepFiles.yaml` is triggered on every push to non-main branches. It performs the following steps:

1. **Set BCR configuration** -- configures the linter to point to the correct ACR via `utils/setBCRinLinter.ps1`
2. **Build modules** -- runs `utils/buildBicepFiles.ps1` to compile all Bicep modules
3. **Compare README files** -- runs `utils/compareReadMe.ps1` to verify that committed README files match the auto-generated output. If they differ, the build fails -- this ensures developers regenerate the README after code changes
4. **Generate HTML** -- converts README.md files to HTML via `utils/readmePublisher/convertreadmetohtml.py` and publishes them as a build artifact

The pipeline does not build the MD documentation; it expects that the developer already ran the README generation during development.

### Publishing

Publishing the modules is a multi-step process that involves building, documentation generation, module publishing to the Azure Container Registry (ACR), and documentation hosting.

The end-to-end publishing workflow:

1. **Build modules** -- compile and validate all Bicep modules (see [Building](#building))
2. **Merge Table of Contents** -- merge the local ToC with the previously published ToC from the documentation website, so that older module versions are preserved
3. **Generate HTML documentation** -- convert README.md files to HTML pages and update the ToC
4. **Publish modules to ACR** -- push compiled modules to the Azure Container Registry as `br:<acrName>.azurecr.io/<module>:<version>.0`
5. **Publish documentation** -- upload HTML files to an Azure Storage static website

#### Dependency Handling

The publish script handles module dependencies automatically. If a module has a `dependencies.json` file, all listed dependencies are published first (in order). Circular dependencies are detected and skipped with an error message.

#### Publishing Tooling

##### `utils/publishToBCR.ps1`

Publishes Bicep modules to the Azure Container Registry.

Parameters:

* `acrName` -- the name of the ACR to publish to. Default: reads from `AMAVM_ACR_NAME` environment variable. Required.
* `modulesRootPath` -- filesystem path to AMAVM bicep modules. Default: `"./bicep/"`.
* `modulesSubpath` -- filters modules to a sub-directory under the modulesRootPath. Default: empty (all modules).
* `moduleName` -- filters to a single module. Default: empty.
* `documentationUri` -- base URI for the documentation website. Default: reads from `AMAVM_DOCUMENTATION_URI` environment variable, or falls back to the ADO repo path.

The script performs `az bicep restore` and `az bicep publish` for each module. The published version is `<major>.<minor>.0`, derived from the module's `version.json`. The documentation URI is constructed as `<documentationUri>/<module-web-path>/<version-page>.html`.

Examples:

```powershell
# Publish a specific module
./utils/publishToBCR.ps1 -acrName 's2amavmdevsecacr' -moduleName 'res/storage/storage-account'

# Publish all modules under a specific path
./utils/publishToBCR.ps1 -acrName 's2amavmdevsecacr' -modulesSubpath 'res/storage/'

# Using environment variable for ACR name
$env:AMAVM_ACR_NAME = 's2amavmdevsecacr'
./utils/publishToBCR.ps1 -modulesSubpath 'res/'
```

Alternatively, a single module can be published directly with Azure CLI:

```bash
az bicep publish \
  --file bicep/res/network/route-table/main.bicep \
  --target br:s2amavmdevsecacr.azurecr.io/res/network/route-table:0.2.0 \
  --documentation-uri 'https://<staName>.z1.web.core.windows.net/docs/res-network-route-table/0-2-0.html'
```

##### `utils/mergeDocumentationTocs.ps1`

Merges the local Table of Contents with a previously published ToC, preserving version history for older module releases.

Parameters:

* `sourcesTocPath` -- path to the local ToC file. Default: `"utils/html-assets/readmePublisher/menu/toc.json"`.
* `additionalTocPath` -- path or URL to the ToC to merge in (e.g. the currently published website's ToC). Default: reads from `AMAVM_DOCUMENTATION_STORAGE_URL` environment variable.
* `resultsPath` -- output path for the merged ToC. Default: `"newtoc.json"`.

Example:

```powershell
./utils/mergeDocumentationTocs.ps1 \
  -sourcesTocPath 'utils/html-assets/readmePublisher/menu/toc.json' \
  -additionalTocPath 'https://<staName>.z1.web.core.windows.net/menu/toc.json' \
  -resultsPath 'utils/html-assets/readmePublisher/menu/toc.json'
```

#### Publish Pipeline (CD)

ADO pipeline `pipelines/publishToBCR.yaml` is triggered manually and requires the following parameters: environment type (dev/tst/acc/prd), location, and ServiceNow environment ID. The ACR and storage account names are derived from these parameters using the naming convention `s2amavm<env><locationShort>acr` and `s2amavm<env><locationShort>sta`.

The pipeline runs two jobs per module path (res/, ptn/, utl/):

**Job 1: Build and Test**

1. Prepare Azure CLI and install Bicep
2. Set BCR configuration via `utils/setBCRinLinter.ps1`
3. Build all modules via `utils/buildBicepFiles.ps1`
4. Merge ToC from the live website via `utils/mergeDocumentationTocs.ps1`
5. Generate HTML documentation via `utils/readmePublisher/convertreadmetohtml.py --generate-toc`
6. Publish HTML as a pipeline artifact

**Job 2: Publish** (depends on Job 1)

1. Prepare Azure CLI and install Bicep
2. Set BCR configuration
3. Publish modules to ACR via `utils/publishToBCR.ps1`
4. Download HTML artifact from Job 1
5. Upload HTML to Azure Storage static website via `az storage blob upload-batch`
