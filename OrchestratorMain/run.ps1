param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

try {
    Write-Log "Running main orchestrator" -OrchestrationContext $Context

    $retryPolicyParameters = @{
        BackoffCoefficient  = 2.0
        FirstRetryInterval  = (New-TimeSpan -Seconds 2)
        MaxNumberOfAttempts = 5
    }
    $retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

    $userGroupsInput = @{
        UserGroupCount = 1
    }
    $userGroupsParameters = @{
        FunctionName = "ActivityGetUserGroups"
        Input        = $userGroupsInput
        RetryOptions = $retryPolicy
    }
    $userGroups = Invoke-DurableActivity @userGroupsParameters

    $userGroupTasks = foreach ($userGroupName in $userGroups) {
        $userGroupInput = @{
            UserGroupName = $userGroupName
        }
        $userGroupParameters = @{
            FunctionName = "SubOrchestratorUserGroup"
            Input        = $userGroupInput
            NoWait       = $true
        }
        Write-Log "Invoking sub orchestrator for user group '$userGroupName'" -OrchestrationContext $Context
        Invoke-DurableSubOrchestrator @userGroupParameters
    }

    Write-Log "Waiting for user group sub orchestrators" -OrchestrationContext $Context
    $userGroupResults = Wait-DurableTask -Task $userGroupTasks

    # Write-Log "user group sub orchestrator results: $($userGroupResults | ConvertTo-Json -Depth 100)" -OrchestrationContext $Context
    # return $userGroupResults
} catch {
    Write-Log "Caught error - $($PSItem.Exception.Message)" -OrchestrationContext $Context
    throw $PSItem
}
