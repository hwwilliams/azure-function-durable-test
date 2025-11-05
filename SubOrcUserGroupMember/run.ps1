param($Context)

$ErrorActionPreference = 'Stop'
$warningPreference = 'Continue'
$InformationPreference = 'Continue'

Write-Log "Running sub orchestrator for user group member '$($Context.Input.UserGroupMemberName)'" -OrchestrationContext $Context

$retryPolicyParameters = @{
    BackoffCoefficient  = 2.0
    FirstRetryInterval  = (New-TimeSpan -Seconds 2)
    MaxNumberOfAttempts = 5
}
$retryPolicy = New-DurableRetryPolicy @retryPolicyParameters

# try {
#     $EncounterRandomErrorParameters = @{
#         FunctionName = "ActGetRandomError"
#         RetryOptions = $retryPolicy
#     }
#     Invoke-DurableActivity @EncounterRandomErrorParameters
# } catch {
#     Write-Log "Failed to invoke activity 'ActGetRandomError' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
#     throw $PSItem
# }

try {
    $processUserGroupMemberInput = @{
        UserGroupMemberName = $Context.Input.UserGroupMemberName
        UserGroupName       = $Context.Input.UserGroupName
    }
    $processUserGroupMemberParameters = @{
        FunctionName = "ActProcessUserGroupMember"
        Input        = $processUserGroupMemberInput
        RetryOptions = $retryPolicy
    }
    Invoke-DurableActivity @processUserGroupMemberParameters

    return @{
        Status              = "Processed"
        UserGroupMemberName = $Context.Input.UserGroupMemberName
        UserGroupName       = $Context.Input.UserGroupName
    }
} catch {
    Write-Log "Failed to invoke activity 'ActProcessUserGroupMember' due to error '$($PSItem.Exception.Message)'" -OrchestrationContext $Context
    throw $PSItem
}
