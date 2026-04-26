# Setup a new album with sparse checkout
# Run this on a new computer to avoid downloading all previous albums
# Usage: .\setup-album.ps1 -AlbumName "My New Album"

param(
    [Parameter(Mandatory=$true)]
    [string]$AlbumName,
    
    [Parameter(Mandatory=$false)]
    [string]$RepoUrl = "https://github.com/ZionIyes/gallery.git",
    
    [Parameter(Mandatory=$false)]
    [string]$TargetDir = "gallery"
)

Write-Host "Setting up sparse checkout for album: $AlbumName" -ForegroundColor Cyan
Write-Host "Repository: $RepoUrl" -ForegroundColor Gray

# Check if git is available
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Git is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Clone with sparse checkout (doesn't download files yet)
Write-Host "Cloning repository with sparse checkout..." -ForegroundColor Yellow
git clone --filter=blob:none --no-checkout $RepoUrl $TargetDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to clone repository" -ForegroundColor Red
    exit 1
}

# Enter the repo
Set-Location $TargetDir

# Initialize sparse checkout
Write-Host "Initializing sparse checkout..." -ForegroundColor Yellow
git sparse-checkout init --cone

# Set the album folder to checkout
$albumPath = "albums/$AlbumName"
Write-Host "Checking out only: $albumPath" -ForegroundColor Yellow
git sparse-checkout set $albumPath

# Checkout the files
git checkout

if ($LASTEXITCODE -eq 0) {
    Write-Host "SUCCESS! You now have only '$albumPath' on disk." -ForegroundColor Green
    Write-Host "Add your photos to: $(Get-Location)\$albumPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "When ready to commit:" -ForegroundColor Yellow
    Write-Host "  git add ." -ForegroundColor Gray
    Write-Host "  git commit -m 'Add $AlbumName photos'" -ForegroundColor Gray
    Write-Host "  git push" -ForegroundColor Gray
} else {
    Write-Host "ERROR: Failed to checkout files" -ForegroundColor Red
    exit 1
}
