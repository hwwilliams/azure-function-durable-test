param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running sub orchestrator for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context

$retryPolicyParameters = @{
    BackoffCoefficient  = 2.0
    FirstRetryInterval  = (New-TimeSpan -Seconds 2)
    MaxNumberOfAttempts = 5
}
$retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

try {
    $userGroupMembersInput = @{
        UserGroupMemberCount = 1
        UserGroupName        = $Context.Input.UserGroupName
    }
    $userGroupMembersParameters = @{
        FunctionName = "ActGetUserGroupMembers"
        Input        = $userGroupMembersInput
        RetryOptions = $retryPolicy
    }
    $userGroupMembers = Invoke-DurableActivity @userGroupMembersParameters
} catch {
    Write-Log "Failed to invoke activity 'ActGetUserGroupMembers' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}

try {
    $userGroupMemberTasks = foreach ($userGroupMemberName in $userGroupMembers) {
        $userGroupMemberInput = @{
            UserGroupMemberName = $userGroupMemberName
            UserGroupName       = $Context.Input.UserGroupName
        }
        $userGroupMemberParameters = @{
            FunctionName = "SubOrcUserGroupMember"
            Input        = $userGroupMemberInput
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator for member '$userGroupMemberName' in user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
        Invoke-DurableSubOrchestrator @userGroupMemberParameters
    }

    Write-Log "Waiting for member sub orchestrators for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
    $userGroupMemberResults = Wait-DurableTask -Task $userGroupMemberTasks

    Write-Log "user group member sub orchestrator results: $($userGroupMemberResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    return $userGroupMemberResults
} catch {
    Write-Log "Failed to invoke sub orchestrator 'SubOrcUserGroupMember' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
