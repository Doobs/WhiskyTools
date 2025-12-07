# Deploy Blazor WASM app to gh-pages branch

$ErrorActionPreference = "Stop"

# Paths
$repoDir     = $PSScriptRoot
$publishRoot = Join-Path $repoDir "bin\Release\net9.0\publish"
$publishDir  = Join-Path $publishRoot "wwwroot"
$worktreeDir = Join-Path $repoDir "../gh-pages"

# Publish if needed
if (!(Test-Path $publishDir)) {
    Write-Host "Publishing project..."
    dotnet publish -c Release
}

# Ensure gh-pages worktree exists (run once manually if needed)
if (!(Test-Path $worktreeDir)) {
    Write-Host "Adding gh-pages worktree..."
    git worktree add $worktreeDir gh-pages
}

# Clean gh-pages worktree but keep .git pointer
Write-Host "Cleaning gh-pages worktree..."
Set-Location $worktreeDir
Get-ChildItem -Force | Where-Object { $_.Name -ne ".git" } | Remove-Item -Recurse -Force -ErrorAction Ignore

# Copy published files into worktree
Write-Host "Copying published files..."
Copy-Item "$publishDir\*" -Destination $worktreeDir -Recurse -Force

##shouldn't need all these fixes for Net9

# # Copy dotnet.js from publish root into _framework
# Write-Host "Copying dotnet.js..."
# $dotnetJs = Join-Path $publishRoot "dotnet.js"
# if (Test-Path $dotnetJs) {
#     Copy-Item $dotnetJs -Destination (Join-Path $worktreeDir "_framework/dotnet.js") -Force
# }

# $dotnetBoot = Join-Path $worktreeDir "_framework/dotnet.boot.js"
# if (!(Test-Path $dotnetBoot)) {
#     Set-Content $dotnetBoot '// Temporary shim for .NET 10.0.100 bug'
# }

# $frameworkDir = Join-Path $publishDir "_framework"
# $nativeWasm = Get-ChildItem $frameworkDir -Filter "dotnet.native.*.wasm" | Select-Object -First 1

# if ($nativeWasm) {
#     Copy-Item $nativeWasm.FullName (Join-Path $frameworkDir "dotnet.wasm") -Force
# }



# Ensure .nojekyll exists
Write-Host "Adding .nojekyll file..."
New-Item -Path (Join-Path $worktreeDir ".nojekyll") -ItemType File -Force | Out-Null

# Replace service-worker.js with published version if present
# $swPublished = Join-Path $publishDir "service-worker.published.js"
# if (Test-Path $swPublished) {
#     Write-Host "Using published service worker..."
#     Copy-Item $swPublished -Destination (Join-Path $worktreeDir "service-worker.js") -Force
# }

(Get-Content "$worktreeDir/index.html") -replace '<base href="/" />', '<base href="/WhiskyTools/" />' |
    Set-Content "$worktreeDir/index.html"


# Commit and push
Write-Host "Add... but commit manually and update index.html base href first"
git add .
git commit -m "Deploy Blazor WASM app"
git push origin gh-pages --force

# Return to source repo
Set-Location $repoDir
Write-Host "Deployment complete!"
