param (
    [switch]$Force,
    [switch]$DryRun,
    [Parameter(Mandatory=$false)]
    [int]$CutoffDays = 180
)

# Define cutoff date
$cutoff = (Get-Date) - (New-TimeSpan -Days $CutoffDays)

# Prune local cache of origin to sync with remote server
git remote prune origin

$remoteBranches = git branch -r --format="%(refname:short)" | ForEach-Object { ($_ -replace '^origin/') }

if ($DryRun)
{
    Write-Host "Branches to be deleted:"
}
git for-each-ref --sort=committerdate --format="%(refname:short) %(committerdate:short)" refs/heads/ |
ForEach-Object {
    $parts  = $_ -split '\s+'
    $branch = $parts[0]
    $date   = Get-Date $parts[1]
	
    if ($date -lt $cutoff) {
        $existsRemotely = $remoteBranches -contains $branch
        if (-not $existsRemotely) {
            if ($DryRun) {
                Write-Host "$branch"
            }
            else {
                Write-Host "Branch: $branch"
                Write-Host "Last updated: $($date.ToString('yyy-MM-dd'))"
                $ans = "y"
                if (-not $Force) {
                    $ans = Read-Host "Do you want to delete (y/n)?"
                }
                if ($ans -match "y") {
                    $returnCode = 1
                    if ($Force) {
                        git branch -D -- $branch > $null
                        $returnCode = $LASTEXITCODE
                    } else {
                        git branch -d -- $branch > $null
                        $returnCode = $LASTEXITCODE

                        if ($returnCode -ne 0) {
                            git branch -D -- $branch > $null
                            $returnCode = $LASTEXITCODE
                        }
                    }
                    if ($returnCode -eq 0) {
                        Write-Host "Removed branch $branch successfully"
                    }
                    else {
                        Write-Error "Failed to remove branch $branch"
                    }
                }
            }
        }
    }
}
