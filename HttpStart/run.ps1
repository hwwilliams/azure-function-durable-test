using namespace System.Net

param($Request, $Starter, $TriggerMetadata)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

$instanceId = Start-DurableOrchestration -FunctionName "OrcMain"
Write-Information "Started orchestration with ID = '$instanceId'"

$response = New-DurableResponse -StatusCode 202 -Location "/api/status/$instanceId"
Push-OutputBinding -Name response -Value $response
