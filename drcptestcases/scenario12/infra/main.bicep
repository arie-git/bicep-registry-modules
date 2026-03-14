targetScope = 'subscription'

param whatIf string = ''
param deploymentId string = ''
param location string = 'swedencentral'
param applicationCode string = 'drcp'
param applicationInstanceCode string = '1012'
param environmentId string = 'ENV24643'
param environmentType string = 'dev'
param organizationCode string = 's2'
param applicationId string = 'AM-CCC'
param networkAddressSpace string = '10.10.0.0/27'
param engineersGroupObjectId string = '9c1f0c78-5ed0-4a97-aecd-4ec20336f626'
param tags object = {}
param engineersContactEmail string = ''
param systemCode string = ''
param systemInstanceCode string = ''
param departmentCode string = 'c3'
#disable-next-line no-unused-params
param namePrefix string = ''

var mytags = union(tags, {
  businessUnit: organizationCode
  purpose: '${applicationCode}${applicationInstanceCode}${systemCode}${systemInstanceCode}'
  environmentType: environmentType
  contactEmail: engineersContactEmail
  deploymentPipelineId: deploymentId
})

module ingestion 'br/amavm:ptn/data/ingestion:0.6.0' = {
  name: '${deployment().name}-data'
  scope: subscription()
  params: {
    applicationCode: applicationCode
    applicationInstanceCode: applicationInstanceCode
    applicationId: applicationId
    environmentId: environmentId
    environmentType: environmentType
    department: departmentCode
    location: location
    organizationCode: organizationCode
    networkAddressSpace: networkAddressSpace
    engineersGroupObjectId: engineersGroupObjectId
    tags: mytags
  }
}

module ntier 'br/amavm:ptn/ntier/sql:0.1.0' = {
  name: '${deployment().name}-ntier'
  scope: subscription()
  params: {
    location: location
    applicationId: applicationId
    environmentId: environmentId
    department: departmentCode
    organizationCode: organizationCode
    applicationCode: applicationCode
    applicationInstanceCode: applicationInstanceCode
    environmentType: environmentType
    networkAddressSpace: networkAddressSpace
    engineersGroupObjectId: engineersGroupObjectId
    tags: mytags
  }
}
