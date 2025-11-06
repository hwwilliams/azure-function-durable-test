param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running main orchestrator" -OrchestrationContext $Context

$retryPolicyParameters = @{
    BackoffCoefficient  = 2.0
    FirstRetryInterval  = (New-TimeSpan -Seconds 3)
    MaxNumberOfAttempts = 3
}
$retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

try
{
    $userGroupsInput = @{
        UserGroupCount = $Context.Input.UserGroupCount
    }
    $userGroupsParameters = @{
        FunctionName = "ActGetUserGroups"
        Input        = $userGroupsInput
        RetryOptions = $retryPolicy
    }
    $userGroups = Invoke-DurableActivity @userGroupsParameters
}
catch
{
    Write-Log "Failed to invoke activity 'ActGetUserGroups' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}

try
{
    $userGroupTasks = [System.Collections.Generic.List[Object]]::new()
    foreach ($userGroupName in $userGroups)
    {
        $userGroupInput = @{
            UserGroupMemberCount = $Context.Input.UserGroupMemberCount
            UserGroupName        = $userGroupName
        }
        $instanceId = "sub-orc-user-group-$userGroupName"
        $userGroupParameters = @{
            FunctionName = "SubOrcUserGroup"
            Input        = $userGroupInput
            InstanceId   = $instanceId
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator with ID '$instanceId'" -OrchestrationContext $Context
        $userGroupTask = Invoke-DurableSubOrchestrator @userGroupParameters
        $userGroupTasks.Add($userGroupTask)
    }

    Write-Log "Waiting for user group sub orchestrators" -OrchestrationContext $Context
    Wait-DurableTask -Task $userGroupTasks | Out-Null

    # $userGroupResults = Wait-DurableTask -Task $userGroupTasks
    # Write-Log "user group sub orchestrator results: $($userGroupResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    # return $userGroupResults
}
catch
{
    Write-Log "Failed to invoke sub orchestrator 'SubOrcUserGroup' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
