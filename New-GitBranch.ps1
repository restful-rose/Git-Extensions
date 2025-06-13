param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("feature", "bugfix", "refactor", "test", "build", "style", "docs", "perf", "security", "release", "u-design")]
    [string]$Category,

    [Parameter(Mandatory=$true)]
    [ValidatePattern('[0-9]+')]
    [string]$TicketId,

    [Parameter(Mandatory=$true)]
    [string]$Description
)

# Traverses the current path backwards, looking for a .git directory.
# This is more efficient than running 'git rev-parse --show-toplevel 2>$null'
# even though that would also work for determining this.
function Is-GitRepo 
{
    $currentDir = Get-Location
    #$currentDir = Get-Item -Path $(Get-Location).Path

    while ($currentDir -ne "") 
    {
        if (Test-Path -Path (Join-Path -Path $currentDir -ChildPath ".git")) 
        {
            return $true
        }
        # Move up one directory
        #$currentDir = $currentDir.Parent
        $currentDir = Split-Path -Path $currentDir
        #Write-Host $currentDir
    }

    return $false
}

if (-not (Is-GitRepo)) {
    Write-Error "Cannot create new branch in non-git directory:`n$($pwd)"
    exit 1
}

# Sanitize description
$sanitizedDescription = $Description -replace '[^\w\-]', '-' -replace '-{2,}', '-'

# Create ticket id
$TicketId = "SKU-" + $TicketId

# Create branch name
$branchName = "$Category/$TicketId" + "_" + $sanitizedDescription

# Create the branch
git checkout -b $branchName

# Make PowerShell aware of UTF-8 if it is using version below 7.0
$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding
Write-Host "✅ Created and switched to branch '$branchName'"
