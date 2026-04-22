$baseUrl = "http://localhost:8080/api"

Write-Host "--- TEST 1: Login Client (Omar) ---" -ForegroundColor Cyan
$loginPayload = @{
    email = "omar@hirafi.com"
    password = "password123"
} | ConvertTo-Json

$loginRes = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $loginPayload
$token = $loginRes.data.accessToken
Write-Host "Login OK. Role: $($loginRes.data.role)" -ForegroundColor Green

$headers = @{ Authorization = "Bearer $token" }

Write-Host "`n--- TEST 2: Récupérer le Fil d'actualité ---" -ForegroundColor Cyan
$feed = Invoke-RestMethod -Uri "$baseUrl/users/feed" -Method Get -Headers $headers
Write-Host "Nombre de posts trouvés: $($feed.data.content.Count)" -ForegroundColor Green

Write-Host "`n--- TEST 3: Ajouter un Avis sur Karim (ID=1) ---" -ForegroundColor Cyan
$reviewPayload = @{
    rating = 5
    comment = "Excellent plombier, très ponctuel et professionnel ! TEST LIVE"
} | ConvertTo-Json

$reviewRes = Invoke-RestMethod -Uri "$baseUrl/reviews/worker/1" -Method Post -ContentType "application/json" -Body $reviewPayload -Headers $headers
Write-Host "Avis ajouté avec succès: $($reviewRes.message)" -ForegroundColor Green

Write-Host "`n--- TEST 4: Login Admin ---" -ForegroundColor Cyan
$adminPayload = @{
    email = "admin@hirafi.com"
    password = "admin1234"
} | ConvertTo-Json
$adminRes = Invoke-RestMethod -Uri "$baseUrl/auth/login" -Method Post -ContentType "application/json" -Body $adminPayload
$adminToken = $adminRes.data.accessToken
$adminHeaders = @{ Authorization = "Bearer $adminToken" }

Write-Host "`n--- TEST 5: Certifier Karim (Vérification Badge) ---" -ForegroundColor Cyan
$verifyRes = Invoke-RestMethod -Uri "$baseUrl/admin/workers/1/verify?status=true" -Method Put -Headers $adminHeaders
Write-Host "Statut de Karim après certification: Verified=$($verifyRes.data.verified)" -ForegroundColor Green

Write-Host "`n--- TESTS TERMINÉS AVEC SUCCÈS ---" -ForegroundColor Magenta
