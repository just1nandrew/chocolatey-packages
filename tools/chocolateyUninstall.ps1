$ErrorActionPreference = 'Stop'

$packageName = $env:ChocolateyPackageName
$softwareName = 'pdfgear*'

[array]$key = Get-UninstallRegistryKey -SoftwareName $softwareName

if ($key.Count -eq 0) {
    Write-Warning "$packageName has already been uninstalled or not found in the registry."
    return
} elseif ($key.Count -gt 1) {
    Write-Warning "Multiple matches found for $softwareName. Manual intervention required."
    $key | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
    return
}

$uninstallString = $key[0].UninstallString
if (-Not (Test-Path $uninstallString)) {
    Write-Warning "Uninstall path not found: $uninstallString"
    return
}

$installerArgs = @{
    packageName   = $packageName
    file          = $uninstallString
    fileType      = 'EXE'
    silentArgs    = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
    validExitCodes= @(0, 3010, 1641)
}

try {
    Uninstall-ChocolateyPackage @installerArgs
} catch {
    Write-Error "An error occurred during uninstallation: $_"
    throw
}