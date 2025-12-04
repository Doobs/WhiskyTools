# Deploy Blazor WASM app to gh-pages branch

# Stop on errors
$ErrorActionPreference = "Stop"

# Variables
$publishDir = "bin\Release\net10.0\publish\wwwroot"
$mainBranch = "main"   # change if your default branch is called 'master'

# Ensure publish output exists
if (!(Test-Path $publishDir)) {
    Write-Host "Publishing project..."
    dotnet publish -c Release
}

Write-Host "Switching to gh-pages branch..."
git checkout --orphan gh-pages

Write-Host "Clearing branch contents..."
git rm -rf .

Write-Host "Copying published files..."
Copy-Item "$publishDir\*" -Destination . -Recurse

Write-Host "Adding files..."
git add .

Write-Host "Committing..."
git commit -m "Deploy Blazor WASM app"

Write-Host "Pushing to origin/gh-pages..."
git push origin gh-pages --force

Write-Host "Switching back to $mainBranch..."
git checkout $mainBranch

Write-Host "Deployment complete!"
