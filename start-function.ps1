param(
    [int]$Port = 7273,
    [string]$computername = "localhost"
)

$baseUrl = "http://$computername`:$Port"
$startUrl = "$baseUrl/api/start"

$body = @{
    UserGroupCount       = 1
    UserGroupMemberCount = 5
}

Write-Information "Starting orchestration at: $startUrl"
Invoke-RestMethod `
    -Uri $startUrl `
    -Method POST `
    -ContentType "application/json" `
    -Body ($body | ConvertTo-Json -Depth 100 -Compress) `
    -TimeoutSec 30

