param(
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [int]$DockerIdleSeconds = 3,   # how long docker must be quiet
    [int]$SleepSeconds = 2         # extra pause after idle
)

# --- Trick to minimize the risk of errors like API versions incompatibilities ---
# Ensure buildx builder exists
$builderName = "ccs3builder"

# Check if builder already exists
$existingBuilder = docker buildx ls | Select-String $builderName

if (-not $existingBuilder) {
    Write-Host "Creating buildx builder '$builderName'..."
    docker buildx create --name $builderName --driver docker --use
    docker buildx inspect --bootstrap
} else {
    Write-Host "Using existing buildx builder '$builderName'..."
    docker buildx use $builderName
    docker buildx inspect --bootstrap
}


$ErrorActionPreference = "Stop"
Set-Location "$PSScriptRoot\.."

$StartTime = Get-Date

function Fail($msg) {
    Write-Host $msg -ForegroundColor Red
    exit 1
}

function cdOrFail($path) {
    if (-not (Test-Path $path)) {
        Fail "Directory '$path' not found"
    }
    Set-Location $path
}

function Wait-DockerIdle {
    param(
        [int]$IdleSeconds,
        [int]$PauseSeconds
    )

    docker system events --until="${IdleSeconds}s" | Out-Null
    Start-Sleep -Seconds $PauseSeconds
}



Write-Host "Building with version: $Version"
Write-Host "Started at: $StartTime"
Write-Host ""



# --- Ccs3ClientAppBootstrapWindowsService ---
cdOrFail "ccs3-windows-apps/Ccs3ClientAppBootstrapWindowsService/Ccs3ClientAppBootstrapWindowsService"
docker buildx build --output=type=docker -t computerclubsystem/client-app-bootstrap-windows-service:dev -f Dockerfile .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ../../../

# --- Ccs3ClientAppWindowsService ---
cdOrFail "ccs3-windows-apps/Ccs3ClientAppWindowsService/Ccs3ClientAppWindowsService"
docker buildx build --output=type=docker -t computerclubsystem/client-app-windows-service:dev -f Dockerfile .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ../../../

# --- Ccs3ClientApp ---
cdOrFail "ccs3-windows-apps/Ccs3ClientApp/Ccs3ClientApp"
docker buildx build --output=type=docker -t computerclubsystem/client-app:dev -f Dockerfile .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ../../../

# --- ccs3-operator ---
cdOrFail "ccs3-operator"
npm run update-version -- $Version
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
docker buildx build --output=type=docker -t computerclubsystem/operator-web-app-static-files:dev -f devops/Dockerfile .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ..

# --- ccs3-qrcode-signin ---
cdOrFail "ccs3-qrcode-signin"
npm run update-version -- $Version
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
docker buildx build --output=type=docker -t computerclubsystem/qrcode-signin-web-app-static-files:dev -f devops/Dockerfile .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ..

# --- Update backend versions ---
cdOrFail "ccs3-backend"
npm run update-version -- $Version
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }

# --- static-files-service ---
cdOrFail "devops"
docker buildx build -t computerclubsystem/static-files-service:dev -f Dockerfile.static-files-service ./static-files-service
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds
Set-Location ..

# --- operator-connector ---
docker buildx build -t computerclubsystem/operator-connector:dev -f devops/Dockerfile.operator-connector .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds

# --- pc-connector ---
docker buildx build -t computerclubsystem/pc-connector:dev -f devops/Dockerfile.pc-connector .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds

# --- qrcode-signin ---
docker buildx build -t computerclubsystem/qrcode-signin:dev -f devops/Dockerfile.qrcode-signin .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds

# --- state-manager ---
docker buildx build -t computerclubsystem/state-manager:dev -f devops/Dockerfile.state-manager .
if ($LASTEXITCODE -ne 0) { Fail "Build failed" }
Wait-DockerIdle -IdleSeconds $DockerIdleSeconds -PauseSeconds $SleepSeconds

# --- Done ---
$EndTime = Get-Date

Write-Host ""
Write-Host "Started at: $StartTime"
Write-Host "Ended at:   $EndTime"
Write-Host "Build completed successfully." -ForegroundColor Green
