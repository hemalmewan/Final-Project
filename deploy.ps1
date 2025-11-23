# deploy.ps1 - Quick deployment script for Windows

param(
    [string]$message = "Update application"
)

Write-Host "Committing changes..." -ForegroundColor Yellow
git add .
git commit -m $message

Write-Host "Pushing to GitHub..." -ForegroundColor Cyan
git push origin main

Write-Host "Done! Jenkins will automatically build and deploy." -ForegroundColor Green
Write-Host "Check Jenkins at http://localhost:8081" -ForegroundColor Blue