$ErrorActionPreference = "Stop"

$Version = if ($env:GOODVERIFY_VERSION) { $env:GOODVERIFY_VERSION } else { "latest" }
$InstallDir = if ($env:GOODVERIFY_INSTALL_DIR) {
    $env:GOODVERIFY_INSTALL_DIR
} else {
    Join-Path $env:USERPROFILE "AppData\Local\Microsoft\WindowsApps"
}
$BaseUrl = if ($env:GOODVERIFY_BASE_URL) {
    $env:GOODVERIFY_BASE_URL
} else {
    "https://github.com/goodwaygroup/goodverify/releases/download"
}

switch ([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture) {
    "X64" { $Arch = "amd64" }
    "Arm64" { $Arch = "arm64" }
    default { throw "Unsupported architecture: $([System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture)" }
}

$Binary = "goodverify-windows-$Arch.exe"

if ($Version -eq "latest") {
    $Url = "$BaseUrl/latest/download/$Binary"
} else {
    $Url = "$BaseUrl/v$Version/$Binary"
}

Write-Host "Downloading goodverify for windows/$Arch..."

New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
$TempFile = Join-Path ([System.IO.Path]::GetTempPath()) $Binary

try {
    Invoke-WebRequest -Uri $Url -OutFile $TempFile
    $Destination = Join-Path $InstallDir "goodverify.exe"
    Move-Item -Force $TempFile $Destination
    Write-Host "goodverify installed to $Destination"
    & $Destination --version
}
finally {
    if (Test-Path $TempFile) {
        Remove-Item -Force $TempFile
    }
}
