param(
    [string]$ChangesetId,

    [string]$Author,

    # Must match COMPOSE_PROJECT_NAME in your .env (or docker-compose name field)
    [string]$ProjectName = ${env:COMPOSE_PROJECT_NAME},

    [string]$DbUser     = ${env:POSTGRES_USER},

    [string]$DbName     = ${env:POSTGRES_DB},

    [switch]$Execute,

    [switch]$PreviewOnly,

    [switch]$AllowCascade
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSNativeCommandUseErrorActionPreference = $false

# ── Fallback defaults (used when .env is not loaded in the shell) ────────────
if ([string]::IsNullOrWhiteSpace($ProjectName)) { $ProjectName = "new-project-db" }
if ([string]::IsNullOrWhiteSpace($DbUser))      { $DbUser      = "new_project_user" }
if ([string]::IsNullOrWhiteSpace($DbName))      { $DbName      = "new_project" }

# ── Helpers ──────────────────────────────────────────────────────────────────
function Invoke-PsqlScalar {
    param(
        [Parameter(Mandatory)][string]$Sql,
        [Parameter(Mandatory)][string]$ProjectName,
        [Parameter(Mandatory)][string]$DbUser,
        [Parameter(Mandatory)][string]$DbName
    )
    $result = docker compose -p $ProjectName exec -T postgres psql -U $DbUser -d $DbName -At -c $Sql
    if ($null -eq $result) {
        throw "No output returned from psql. Check database connection and parameters."
    }
    return $result.Trim()
}

function Escape-SqlLiteral {
    param([Parameter(Mandatory)][string]$Text)
    return $Text.Replace("'", "''")
}

function Confirm-Yes {
    param([Parameter(Mandatory)][string]$Prompt)
    $answer = (Read-Host $Prompt).Trim().ToLowerInvariant()
    return $answer -in @("y", "yes", "s", "si")
}

function Get-RollbackCountSqlLines {
    param(
        [Parameter(Mandatory)][int]$Count,
        [Parameter(Mandatory)][string]$ProjectName,
        [Parameter(Mandatory)][string]$RepoRoot
    )
    $tmpDir  = Join-Path $RepoRoot ".tmp"
    if (-not (Test-Path $tmpDir)) { New-Item -ItemType Directory -Path $tmpDir | Out-Null }

    $tmpFile     = Join-Path $tmpDir ("rollback-count-{0}.sql" -f [Guid]::NewGuid().ToString("N"))
    $relativePath = $tmpFile.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')

    try {
        $prev = $ErrorActionPreference
        $exitCode = 0
        $ErrorActionPreference = "Continue"
        try {
            docker compose -p $ProjectName --profile tooling run --rm -T liquibase `
                --show-banner=false --log-level=SEVERE `
                --output-file=$relativePath rollback-count-sql --count=$Count 2>$null | Out-Null
            $exitCode = $LASTEXITCODE
        } finally { $ErrorActionPreference = $prev }

        if ($exitCode -ne 0) { throw "Failed to generate rollback SQL (exit code $exitCode)." }
        if (-not (Test-Path $tmpFile)) { throw "Could not generate rollback SQL output file." }
        return @(Get-Content $tmpFile | ForEach-Object { $_.ToString() })
    } finally {
        Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
    }
}

function Extract-RollbackBlockForChangeset {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string[]]$SqlLines,
        [Parameter(Mandatory)][string]$ChangesetId,
        [Parameter(Mandatory)][string]$Author
    )
    $idRx     = [Regex]::Escape($ChangesetId)
    $authorRx = [Regex]::Escape($Author)
    $startPat = "^-- Rolling Back ChangeSet: .*::${idRx}::${authorRx}\s*$"
    $startIdx = -1

    for ($i = 0; $i -lt $SqlLines.Count; $i++) {
        if ($SqlLines[$i] -match $startPat) { $startIdx = $i; break }
    }
    if ($startIdx -lt 0) {
        throw "Could not find rollback block for changeset '$ChangesetId' / author '$Author'."
    }

    $endIdx = $SqlLines.Count
    for ($i = $startIdx + 1; $i -lt $SqlLines.Count; $i++) {
        if ($SqlLines[$i] -match "^-- Rolling Back ChangeSet:" -or
            $SqlLines[$i] -match "^-- Release Database Lock") {
            $endIdx = $i; break
        }
    }
    return ($SqlLines[$startIdx..($endIdx - 1)] -join "`n").Trim()
}

function Invoke-LiquibaseExecuteSqlText {
    param(
        [Parameter(Mandatory)][string]$SqlText,
        [Parameter(Mandatory)][string]$ProjectName,
        [Parameter(Mandatory)][string]$RepoRoot,
        [Parameter(Mandatory)][string]$FilePrefix
    )
    $tmpDir  = Join-Path $RepoRoot ".tmp"
    if (-not (Test-Path $tmpDir)) { New-Item -ItemType Directory -Path $tmpDir | Out-Null }

    $tmpFile      = Join-Path $tmpDir ("{0}-{1}.sql" -f $FilePrefix, [Guid]::NewGuid().ToString("N"))
    $relativePath = $tmpFile.Substring($RepoRoot.Length).TrimStart('\', '/').Replace('\', '/')
    Set-Content -Path $tmpFile -Value $SqlText -Encoding UTF8

    try {
        $prev = $ErrorActionPreference
        $exitCode = 0
        $ErrorActionPreference = "Continue"
        try {
            docker compose -p $ProjectName --profile tooling run --rm -T liquibase `
                --show-banner=false --log-level=SEVERE `
                execute-sql --sql-file=$relativePath 2>$null | Out-Null
            $exitCode = $LASTEXITCODE
        } finally { $ErrorActionPreference = $prev }

        if ($exitCode -ne 0) { throw "Liquibase execute-sql failed (exit code $exitCode)." }
    } finally {
        Remove-Item $tmpFile -Force -ErrorAction SilentlyContinue
    }
}

function Test-IsolatedRollbackSafety {
    param(
        [Parameter(Mandatory)][string]$RollbackSqlText,
        [Parameter(Mandatory)][string]$ProjectName,
        [Parameter(Mandatory)][string]$RepoRoot
    )
    $restricted  = $RollbackSqlText -replace "(?im)\bCASCADE\b", "RESTRICT"
    $precheckSql = "BEGIN;`n$restricted`nROLLBACK;"
    Invoke-LiquibaseExecuteSqlText -SqlText $precheckSql -ProjectName $ProjectName -RepoRoot $RepoRoot -FilePrefix "rollback-precheck"
}

# ── Main ─────────────────────────────────────────────────────────────────────
if ($Execute -and $PreviewOnly) { throw "Use either -Execute or -PreviewOnly, not both." }

$repoRoot = Split-Path -Parent $PSScriptRoot
Push-Location $repoRoot
try {
    if ([string]::IsNullOrWhiteSpace($ChangesetId)) {
        $ChangesetId = Read-Host "Enter changeset id (e.g. 001-enable-uuid-extension)"
    }
    if ([string]::IsNullOrWhiteSpace($ChangesetId)) { throw "Changeset id is required." }

    $idEsc  = Escape-SqlLiteral -Text $ChangesetId
    $where  = "id = '$idEsc'"
    if ($Author) {
        $authorEsc = Escape-SqlLiteral -Text $Author
        $where     = "$where AND author = '$authorEsc'"
    }

    $matchCount = [int](Invoke-PsqlScalar -Sql "SELECT COUNT(*) FROM public.databasechangelog WHERE $where;" `
                        -ProjectName $ProjectName -DbUser $DbUser -DbName $DbName)

    if ($matchCount -eq 0) {
        $authorText = if ($Author) { ", author '$Author'" } else { "" }
        throw "No deployed changeset found with id '$ChangesetId'$authorText."
    }

    if (-not $Author) {
        $authorCount = [int](Invoke-PsqlScalar -Sql "SELECT COUNT(DISTINCT author) FROM public.databasechangelog WHERE id = '$idEsc';" `
                             -ProjectName $ProjectName -DbUser $DbUser -DbName $DbName)
        if ($authorCount -gt 1) {
            $rows = docker compose -p $ProjectName exec -T postgres psql -U $DbUser -d $DbName `
                -c "SELECT id, author, filename, orderexecuted FROM public.databasechangelog WHERE id = '$idEsc' ORDER BY orderexecuted;"
            throw "Multiple authors found for id '$ChangesetId'. Re-run with -Author.`n$rows"
        }
    }

    $resolvedAuthor = $Author
    if (-not $resolvedAuthor) {
        $resolvedAuthor = Invoke-PsqlScalar `
            -Sql "SELECT author FROM public.databasechangelog WHERE id = '$idEsc' ORDER BY orderexecuted DESC LIMIT 1;" `
            -ProjectName $ProjectName -DbUser $DbUser -DbName $DbName
    }

    $targetOrder = [int](Invoke-PsqlScalar -Sql "SELECT MAX(orderexecuted) FROM public.databasechangelog WHERE $where;" `
                         -ProjectName $ProjectName -DbUser $DbUser -DbName $DbName)
    $maxOrder    = [int](Invoke-PsqlScalar -Sql "SELECT COALESCE(MAX(orderexecuted), 0) FROM public.databasechangelog;" `
                         -ProjectName $ProjectName -DbUser $DbUser -DbName $DbName)
    $count       = $maxOrder - $targetOrder + 1

    if ($count -le 0) { throw "Calculated rollback count is $count. Nothing to rollback." }

    Write-Host "Target changeset order : $targetOrder"
    Write-Host "Last executed order    : $maxOrder"
    Write-Host "Rollback count         : $count"

    if ($targetOrder -lt $maxOrder -and -not $AllowCascade) {
        Write-Host ""
        Write-Host "Detected non-latest changeset. Switching to isolated rollback mode."

        $allLines          = Get-RollbackCountSqlLines -Count $count -ProjectName $ProjectName -RepoRoot $repoRoot
        $isolatedSql       = Extract-RollbackBlockForChangeset -SqlLines $allLines -ChangesetId $ChangesetId -Author $resolvedAuthor

        Write-Host ""; Write-Host "Isolated rollback SQL preview:"; Write-Host $isolatedSql
        Write-Host ""; Write-Host "Running dependency safety check (RESTRICT mode)..."
        try {
            Test-IsolatedRollbackSafety -RollbackSqlText $isolatedSql -ProjectName $ProjectName -RepoRoot $repoRoot
            Write-Host "Safety check passed. No downstream dependency would be dropped."
        } catch {
            throw @"
Isolated rollback rejected: downstream dependencies detected.
Re-run with -AllowCascade to roll back everything from this point upward.
"@
        }

        $shouldExecute = $Execute
        if (-not $Execute -and -not $PreviewOnly) {
            Write-Host ""
            $shouldExecute = Confirm-Yes -Prompt "Execute isolated rollback now? (Y/N)"
        }

        if ($shouldExecute) {
            Write-Host ""; Write-Host "Executing isolated rollback for '$ChangesetId' ..."
            Invoke-LiquibaseExecuteSqlText -SqlText $isolatedSql -ProjectName $ProjectName -RepoRoot $repoRoot -FilePrefix "rollback-isolated"
            Write-Host ""; Write-Host "Isolated rollback executed. Later changesets were preserved."
            Write-Host "To re-apply: powershell -ExecutionPolicy Bypass -File .\scripts\reapply-after-rollback.ps1 -OnlyNext -AutoConfirm"
        } else {
            Write-Host ""; Write-Host "Preview only. No rollback executed."
        }

    } else {
        Write-Host ""; Write-Host "Preview SQL:"
        $previewLines = Get-RollbackCountSqlLines -Count $count -ProjectName $ProjectName -RepoRoot $repoRoot
        Write-Host ($previewLines -join "`n")

        $shouldExecute = $Execute
        if (-not $Execute -and -not $PreviewOnly) {
            Write-Host ""
            $shouldExecute = Confirm-Yes -Prompt "Execute rollback now? (Y/N)"
        }

        if ($shouldExecute) {
            Write-Host ""; Write-Host "Executing rollback-count --count=$count ..."
            docker compose -p $ProjectName --profile tooling run --rm -T liquibase rollback-count --count=$count
            Write-Host ""; Write-Host "Rollback executed."
            Write-Host "To re-apply: powershell -ExecutionPolicy Bypass -File .\scripts\reapply-after-rollback.ps1"
        } else {
            Write-Host ""; Write-Host "Preview only. No rollback executed."
        }
    }
} finally {
    Pop-Location
}
