param($param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Checking for errors"

$RandomNumber = Get-Random -Minimum 1 -Maximum 5
if ($RandomNumber -eq 3) {
    throw "Encountered random error"
} else {
    Write-Log "No error"
}

Write-Log "Message after error inside activity"