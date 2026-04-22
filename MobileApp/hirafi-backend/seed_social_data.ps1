$ErrorActionPreference = "Stop"

# Step 1: Login as user
$loginPayload = '{"email":"omar@hirafi.com","password":"password123"}'
$loginResult = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body $loginPayload
$token = $loginResult.data.accessToken
if (-not $token) { $token = $loginResult.data.access_token }
$headers = @{ Authorization = "Bearer $token" }
Write-Host "Logged in as omar@hirafi.com" -ForegroundColor Green

# Step 2: Get all workers to find the artisan
$workersResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/workers?size=50" -Method Get
$artisan = $workersResponse.data.content | Where-Object { $_.email -eq "karim@hirafi.com" } | Select-Object -First 1

if ($artisan) {
    $artisanId = $artisan.id
    Write-Host "Found artisan ID: $artisanId" -ForegroundColor Cyan

    $reviews = @(
        @{ rating = 5; comment = "Excellent travail ! Très ponctuel et professionnel. Je recommande vivement." },
        @{ rating = 5; comment = "Un travail soigné et propre. Merci beaucoup pour votre aide." },
        @{ rating = 4; comment = "Très bon ouvrier, compétent et sympa. Un peu en retard mais le résultat est là." },
        @{ rating = 5; comment = "C'est le meilleur artisan de la ville ! Allez-y les yeux fermés." }
    )

    foreach ($rev in $reviews) {
        try {
            Invoke-RestMethod -Uri "http://localhost:8080/api/reviews/worker/$artisanId" -Method Post -Headers $headers -ContentType "application/json" -Body (ConvertTo-Json $rev) | Out-Null
            Write-Host "Added review: $($rev.comment)" -ForegroundColor Yellow
        } catch {
            Write-Host "Note: Review might already exist for this user on this worker." -ForegroundColor Gray
        }
    }

    # Add some reactions to artisan's posts
    $postsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/workers/$artisanId/posts" -Method Get
    foreach ($post in $postsResponse.data.content) {
        $postId = $post.id
        # Add a Like
        Invoke-RestMethod -Uri "http://localhost:8080/api/users/posts/$postId/like?type=HEART" -Method Post -Headers $headers | Out-Null
        Write-Host "Added HEART reaction to post $postId" -ForegroundColor Magenta
        
        # Add a comment
        $commentPayload = @{ content = "Super boulot ! Bravo. J'adore le résultat." }
        Invoke-RestMethod -Uri "http://localhost:8080/api/users/posts/$postId/comment" -Method Post -Headers $headers -ContentType "application/json" -Body (ConvertTo-Json $commentPayload) | Out-Null
        Write-Host "Added comment to post $postId" -ForegroundColor Blue
    }
} else {
    Write-Host "Artisan account not found. Please run create_accounts.ps1 first." -ForegroundColor Red
}

Write-Host "Seeding complete!" -ForegroundColor White
