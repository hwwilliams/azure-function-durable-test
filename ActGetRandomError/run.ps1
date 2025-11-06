param($Param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

$RandomNumber = Get-Random -Minimum 1 -Maximum 10
if ($RandomNumber -eq 3)
{
    throw "Encountered random error"
}
