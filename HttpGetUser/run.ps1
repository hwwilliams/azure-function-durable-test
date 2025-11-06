using namespace System.Net

param($Request, $TriggerMetadata)

$users = @(
    @{
        Name     = "hunter"
        Username = "hwwilliams"
    }
)

$name = $Request.Query.Name
if (-not $name)
{
    $name = $Request.Body.Name
}

if ($name)
{
    Start-Sleep -Seconds 35
    $body = $users.where({ $PSItem.Name -ieq $name })
}

Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $body
    }
)
