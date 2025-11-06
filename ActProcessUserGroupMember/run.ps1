param($Param)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

$start = (Get-Date).ToString()
Write-Log "Processing member '$($param.UserGroupMemberName)' from user group '$($param.UserGroupName)': started=$($start)"

# Start-Sleep -Seconds (Get-Random -Minimum 1 -Maximum 3)

# $usersDirectory = Resolve-Path -Path './_users'
# if (-not (Test-Path $usersDirectory)) { New-Item -Path $usersDirectory -ItemType Directory -Force | Out-Null }
# $userFile = Join-Path -Path $usersDirectory -ChildPath "$($param.UserGroupName)-$($param.UserGroupMemberName)"
# New-Item -Path $userFile -ItemType File -Force | Out-Null

$end = (Get-Date).ToString()
Write-Log "Finished processing member '$($param.UserGroupMemberName)' from user group '$($param.UserGroupName)': started=$($start), ended=$($end)"
