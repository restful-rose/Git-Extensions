# Add the current directory to the user's Path-variable if it is not already there
function AddCurrentDirToUserPath {
    $installDir = Resolve-Path . | Select-Object -ExpandProperty Path
    $envUserPath = [System.Environment]::GetEnvironmentVariable('path', 'user')
    $newPath = "$envUserPath;$installDir"
    if ($envUserPath -split ';' -notcontains $installDir)
    {
        [System.Environment]::SetEnvironmentVariable('path', $newPath, 'user')
        $env:Path = $newPath + ";" + [Environment]::GetEnvironmentVariable('path', 'machine')
    }
    else
    {
        Write-Error "$installDir already exists in `n$envUserPath"
    }
}

AddCurrentDirToUserPath

# Ensure the file is encoded with BOM
Get-Content -Path .\New-GitBranch.ps1 -Encoding UTF8 | Set-Content -Path .\New-GitBranch.ps1 -Encoding UTF8
