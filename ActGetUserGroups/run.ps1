param($Param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Getting user groups"

$userGroups = for ($i = 1; $i -le $param.UserGroupCount; $i++)
{
    "UserGroup$i"
}

Write-Log "Found $($userGroups.Count) user groups"
return $userGroups
