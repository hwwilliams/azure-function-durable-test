param($Param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Getting members for user group '$($param.UserGroupName)'"

$userGroupMembers = for ($i = 1; $i -le $Param.UserGroupMemberCount; $i++) {
    "User$i"
}

Write-Log "Found $($userGroupMembers.Count) members in user group '$($param.UserGroupName)'"
return $userGroupMembers
