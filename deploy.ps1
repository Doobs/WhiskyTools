# Deploy Blazor WASM app to gh-pages branch

$ErrorActionPreference = "Stop"

$repoDir = $PSScriptRoot
$publishDir = Join-Path $repoDir "bin\Release\net10.0\publish\wwwroot"
$worktreeDir = Join-Path $repoDir "../gh-pages"

# Publish if needed
if (!(Test-Path $publishDir)) {
    dotnet publish -c Release
}

# Ensure gh-pages worktree exists (run once manually if needed)
if (!(Test-Path $worktreeDir)) {
    git worktree add $worktreeDir gh-pages
}

# Clean gh-pages worktree
Set-Location $worktreeDir
Remove-Item * -Recurse -Force -ErrorAction Ignore

# Copy published files
Copy-Item "$publishDir\*" -Destination $worktreeDir -Recurse -Force

# Add .nojekyll
New-Item -Path ".nojekyll" -ItemType File -Force | Out-Null

# Replace service worker
$swPublished = Join-Path $publishDir "service-worker.published.js"
if (Test-Path $swPublished) {
    Copy-Item $swPublished -Destination "service-worker.js" -Force
}

# Commit and push
git add .
git commit -m "Deploy Blazor WASM app"
git push origin gh-pages --force

# Return to source repo
Set-Location $repoDir
Write-Host "Deployment complete!"

