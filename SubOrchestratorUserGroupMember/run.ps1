param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

try {
    Write-Log "Running sub orchestrator for user group member '$($Context.Input.UserGroupMemberName)'" -OrchestrationContext $Context

    $retryPolicyParameters = @{
        BackoffCoefficient  = 2.0
        FirstRetryInterval  = (New-TimeSpan -Seconds 2)
        MaxNumberOfAttempts = 5
    }
    $retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

    $EncounterRandomErrorParameters = @{
        FunctionName = "ActivityEncounterRandomError"
        RetryOptions = $retryPolicy
    }
    Invoke-DurableActivity @EncounterRandomErrorParameters

    Write-Log "Message after error inside sub orchestrator" -OrchestrationContext $Context

    $processUserGroupMemberInput = @{
        UserGroupMemberName = $Context.Input.UserGroupMemberName
        UserGroupName       = $Context.Input.UserGroupName
    }
    $processUserGroupMemberParameters = @{
        FunctionName = "ActivityProcessUserGroupMember"
        Input        = $processUserGroupMemberInput
        RetryOptions = $retryPolicy
    }
    Invoke-DurableActivity @processUserGroupMemberParameters

    # return @{
    #     Status              = "Processed"
    #     UserGroupMemberName = $Context.Input.UserGroupMemberName
    #     UserGroupName       = $Context.Input.UserGroupName
    # }
} catch {
    Write-Log "Caught error during user group member $($Context.Input.UserGroupMemberName) - $($PSItem.Exception.Message)" -OrchestrationContext $Context
    throw $PSItem
}
