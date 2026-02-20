param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

# Validate version argument
if (-not $Version) {
    Write-Host "You must provide a version number."
    Write-Host "Usage: push-all.ps1 1.2.3"
    exit 1
}

# Helper to remove images safely
function Remove-Image {
    param([string[]]$Names)

    foreach ($name in $Names) {
        docker rmi $name
    }
}

# Remove images
Remove-Image @(
    "computerclubsystem/operator-connector:dev",
    "computerclubsystem/operator-connector:$Version",

    "computerclubsystem/pc-connector:dev",
    "computerclubsystem/pc-connector:$Version",

    "computerclubsystem/state-manager:dev",
    "computerclubsystem/state-manager:$Version",

    "computerclubsystem/qrcode-signin:dev",
    "computerclubsystem/qrcode-signin:$Version",

    "computerclubsystem/static-files-service:dev",
    "computerclubsystem/static-files-service:$Version",

    "computerclubsystem/client-app:dev",
    "computerclubsystem/client-app-windows-service:dev",
    "computerclubsystem/client-app-bootstrap-windows-service:dev",

    "computerclubsystem/operator-web-app-static-files:dev",
    "computerclubsystem/qrcode-signin-web-app-static-files:dev"
)

# Prune system
docker system prune --force
docker image prune --all --force
