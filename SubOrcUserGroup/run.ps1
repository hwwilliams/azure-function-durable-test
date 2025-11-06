param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running sub orchestrator for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context

# $retryPolicyParameters = @{
#     BackoffCoefficient  = 2.0
#     FirstRetryInterval  = (New-TimeSpan -Seconds 3)
#     MaxNumberOfAttempts = 3
# }
# $retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

try
{
    $userGroupMembersInput = @{
        UserGroupMemberCount = [Int] $Context.Input.UserGroupMemberCount
        UserGroupName        = [String] $Context.Input.UserGroupName
    }
    $userGroupMembersParameters = @{
        FunctionName = "ActGetUserGroupMembers"
        Input        = $userGroupMembersInput
        # RetryOptions = $retryPolicy
    }
    [String[]] $userGroupMembers = Invoke-DurableActivity @userGroupMembersParameters
}
catch
{
    Write-Log "Failed to invoke activity 'ActGetUserGroupMembers' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}

try
{
    $userGroupMemberTasks = [System.Collections.Generic.List[Object]]::new()
    foreach ($userGroupMemberName in $userGroupMembers)
    {
        $userGroupMemberInput = @{
            UserGroupMemberName = [String] $UserGroupMemberName
            UserGroupName       = [String] $Context.Input.UserGroupName
        }
        $instanceId = "sub-orc-user-group-member-$UserGroupMemberName"
        $userGroupMemberParameters = @{
            FunctionName = "SubOrcUserGroupMember"
            Input        = $userGroupMemberInput
            InstanceId   = $instanceId
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator with ID '$instanceId'" -OrchestrationContext $Context
        $userGroupMemberTask = Invoke-DurableSubOrchestrator @userGroupMemberParameters
        $userGroupMemberTasks.Add($userGroupMemberTask)
    }

    Write-Log "Waiting for member sub orchestrators for user group '$($Context.Input.UserGroupName)'" -OrchestrationContext $Context
    Wait-DurableTask -Task $userGroupMemberTasks | Out-Null

    # $userGroupMemberResults = Wait-DurableTask -Task $userGroupMemberTasks
    # Write-Log "user group member sub orchestrator results: $($userGroupMemberResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    # return $userGroupMemberResults
}
catch
{
    Write-Log "Failed to invoke sub orchestrator 'SubOrcUserGroupMember' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
