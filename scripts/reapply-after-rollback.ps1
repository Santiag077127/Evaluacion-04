param(
    # Must match COMPOSE_PROJECT_NAME in your .env
    [string]$ProjectName = ${env:COMPOSE_PROJECT_NAME},
    [switch]$OnlyNext,
    [switch]$AllPending,
    [switch]$AutoConfirm
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectName)) { $ProjectName = "new-project-db" }

if ($OnlyNext -and $AllPending) { throw "Use either -OnlyNext or -AllPending, not both." }

function Confirm-Yes {
    param([Parameter(Mandatory)][string]$Prompt)
    $answer = (Read-Host $Prompt).Trim().ToLowerInvariant()
    return $answer -in @("y", "yes", "s", "si")
}

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    $mode = "all"

    if ($OnlyNext) {
        $mode = "next"
    } elseif ($AllPending) {
        $mode = "all"
    } else {
        Write-Host "Choose re-apply mode:"
        Write-Host "  1) Re-apply only next pending changeset"
        Write-Host "  2) Re-apply all pending changesets"
        $choice = (Read-Host "Option [1/2]").Trim()
        if ($choice -eq "1") { $mode = "next" }
    }

    Write-Host ""; Write-Host "Pending changes before:"
    docker compose -p $ProjectName --profile tooling run --rm liquibase status

    $runApply = $AutoConfirm
    if (-not $AutoConfirm) {
        Write-Host ""
        $runApply = Confirm-Yes -Prompt "Apply now? (Y/N)"
    }

    if (-not $runApply) { Write-Host "Canceled. No changes were applied."; return }

    Write-Host ""
    if ($mode -eq "next") {
        Write-Host "Applying next pending changeset..."
        docker compose -p $ProjectName --profile tooling run --rm liquibase update-count --count=1
    } else {
        Write-Host "Applying all pending changesets..."
        docker compose -p $ProjectName --profile tooling run --rm liquibase update
    }

    Write-Host ""; Write-Host "Pending changes after:"
    docker compose -p $ProjectName --profile tooling run --rm liquibase status
} finally {
    Pop-Location
}
