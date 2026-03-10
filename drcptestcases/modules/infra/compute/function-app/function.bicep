
param functionAppName string

@description('''List of Azure function (Actual object where our code resides).
Example:
{
  language: "CSharp"
  name: "Function1"
  enabled: true
  files: {
    "run.csx": loadTextContent('./function1.csx')
  }
  config: {
    "bindings": [
      {
        "authLevel": "anonymous",
        "type": "httpTrigger",
        "direction": "in",
        "name": "req"
      },
      {
        "type": "http",
        "direction": "out",
        "name": "$return"
      }
    ],
    "disabled": false
  }
}
''')
param functions array

// get reference to function app
resource functionApp 'Microsoft.Web/sites@2022-03-01' existing = {
  name: functionAppName
}

@description('The resources actual is function where code exits')
@batchSize(1)
resource azureFunction 'Microsoft.Web/sites/functions@2021-02-01' = [for function in functions: {
  parent: functionApp
  name: function.name
  properties: {
    language: function.language
    config: function.config
    isDisabled: function.enabled
    files: function.files
  }
}]

@description('Array of functions having name, language, isDisabled and id of functions.')
output functions array = [for (function, index) in functions: {
  name: function.name
  language: function.language
  isDisabled: function.enabled
  id: azureFunction[index].id //'${functionApp.id}/functions/${function.name}'
  files: function.files
}]
