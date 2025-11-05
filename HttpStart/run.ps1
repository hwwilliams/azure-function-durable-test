using namespace System.Net

param($Request, $Starter, $TriggerMetadata)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

$instanceId = Start-DurableOrchestration -FunctionName "OrcMain"
Write-Information "Started orchestration with ID = '$instanceId'"

$response = New-DurableOrchestrationCheckStatusResponse -Request $Request -InstanceId $instanceId
Push-OutputBinding -Name response -Value $response
