# Deploy Blazor WASM app to gh-pages branch

$ErrorActionPreference = "Stop"

# Variables
$publishDir = "bin\Release\net10.0\publish\wwwroot"
$mainBranch = "master"   # change if your default branch is called 'main'
$worktreeDir = "../gh-pages"

# Ensure publish output exists
if (!(Test-Path $publishDir)) {
    Write-Host "Publishing project..."
    dotnet publish -c Release
}

# Ensure gh-pages worktree exists
if (!(Test-Path $worktreeDir)) {
    Write-Host "Adding gh-pages worktree..."
    git worktree add $worktreeDir gh-pages
}

# Clean gh-pages worktree
Write-Host "Cleaning gh-pages worktree..."
Set-Location $worktreeDir
git rm -rf .
Remove-Item * -Recurse -Force -ErrorAction Ignore

# Copy published files
Write-Host "Copying published files..."
Copy-Item "$publishDir\*" -Destination . -Recurse -Force

# Ensure .nojekyll exists
Write-Host "Adding .nojekyll file..."
New-Item -Path ".nojekyll" -ItemType File -Force | Out-Null

# Replace service-worker.js with published version
$swPublished = Join-Path $publishDir "service-worker.published.js"
if (Test-Path $swPublished) {
    Write-Host "Using published service worker..."
    Copy-Item $swPublished -Destination "service-worker.js" -Force
}

# Commit and push
Write-Host "Committing..."
git add .
git commit -m "Deploy Blazor WASM app"
git push origin gh-pages --force

# Return to main branch
Set-Location ../$mainBranch
Write-Host "Deployment complete!"
