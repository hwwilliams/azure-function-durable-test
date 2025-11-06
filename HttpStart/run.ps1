using namespace System.Net

param($Request, $Starter, $TriggerMetadata)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Request: $($Request.Body | ConvertTo-Json -Depth 100 -Compress)"

$mainInput = @{
    UserGroupCount       = [Int] $Request.Body.UserGroupCount
    UserGroupMemberCount = [Int] $Request.Body.UserGroupMemberCount
}
$mainParameters = @{
    FunctionName = "OrcMain"
    Input        = $mainInput
}
$instanceId = Start-DurableOrchestration @mainParameters
Write-Log "Started orchestration with ID '$instanceId'"

$response = New-DurableOrchestrationCheckStatusResponse -Request $Request -InstanceId $instanceId
Push-OutputBinding -Name response -Value $response
