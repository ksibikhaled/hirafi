$ErrorActionPreference = "Stop"

# Step 1: Login as admin
$adminPayload = '{"email":"admin@hirafi.com","password":"admin1234"}'
$adminResult = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body $adminPayload
$adminToken = $adminResult.data.accessToken
if (-not $adminToken) { $adminToken = $adminResult.data.access_token }
Write-Host "Admin login OK" -ForegroundColor Green

$headers = @{ Authorization = "Bearer $adminToken" }

# Step 2: Get all workers
$allWorkers = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/workers?page=0&size=50" -Method Get -Headers $headers
Write-Host "All workers:" -ForegroundColor Cyan
$allWorkers.data.content | ForEach-Object {
    Write-Host ("  ID=" + $_.id + " | " + $_.firstName + " " + $_.lastName + " | Approved=" + $_.approved)
}

# Step 3: Approve all pending workers
$pendingWorkers = Invoke-RestMethod -Uri "http://localhost:8080/api/admin/workers/pending?page=0&size=50" -Method Get -Headers $headers
Write-Host ("Pending workers: " + $pendingWorkers.data.totalElements) -ForegroundColor Yellow
$pendingWorkers.data.content | ForEach-Object {
    $wId = $_.id
    Write-Host ("  Approving ID=" + $wId)
    Invoke-RestMethod -Uri ("http://localhost:8080/api/admin/workers/" + $wId + "/approve") -Method Put -Headers $headers | Out-Null
    Write-Host "  Approved!" -ForegroundColor Green
}

# Step 4: Verify all logins
Write-Host "Verifying logins..." -ForegroundColor White

$r = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body '{"email":"user@hirafi.com","password":"user1234"}'
Write-Host ("USER login OK - Role: " + $r.data.role) -ForegroundColor Green

$r2 = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body '{"email":"artisan@hirafi.com","password":"artisan1234"}'
Write-Host ("ARTISAN login OK - Role: " + $r2.data.role) -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ADMIN    : admin@hirafi.com    / admin123" -ForegroundColor Yellow
Write-Host "  USER     : user@hirafi.com     / user1234" -ForegroundColor Green
Write-Host "  ARTISAN  : artisan@hirafi.com  / artisan1234" -ForegroundColor Magenta
Write-Host "========================================" -ForegroundColor Cyan
