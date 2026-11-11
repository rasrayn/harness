[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [switch]$WithCodeGraph
)

$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '.')).Path
$resolvedTarget = Resolve-Path -LiteralPath $ProjectPath -ErrorAction SilentlyContinue
$targetRoot = if ($resolvedTarget) {
    $resolvedTarget.Path
} else {
    [System.IO.Path]::GetFullPath($ProjectPath)
}

if ($sourceRoot.TrimEnd('\') -ieq $targetRoot.TrimEnd('\')) {
    throw 'El proyecto destino no puede ser el repositorio fuente del arnés.'
}

$opencodeConfigPath = Join-Path $targetRoot '.opencode\opencode.jsonc'
$jsonConfigPath = Join-Path $targetRoot '.opencode\opencode.json'
if ((Test-Path -LiteralPath $jsonConfigPath -PathType Leaf) -and
    -not (Test-Path -LiteralPath $opencodeConfigPath)) {
    $opencodeConfigPath = $jsonConfigPath
}

if ($WithCodeGraph) {
    $nodePath = (Get-Command node.exe -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $codegraphPath = (Get-Command codegraph -CommandType Application -ErrorAction Stop | Select-Object -First 1).Source
    $helperPath = Join-Path $sourceRoot 'tools\codegraph\configure.cjs'
    $otherConfigs = @(
        (Join-Path $targetRoot 'opencode.jsonc')
        (Join-Path $targetRoot 'opencode.json')
        $jsonConfigPath
    ) | Where-Object { $_ -ne $opencodeConfigPath }
    & $nodePath $helperPath $opencodeConfigPath @otherConfigs --check
    if ($LASTEXITCODE -ne 0) {
        throw 'Falló la comprobación de CodeGraph. Comprueba el diagnóstico y ejecuta npm ci --prefix tools/codegraph si falta jsonc-parser.'
    }
}

function Copy-HarnessFile {
    param(
        [Parameter(Mandatory)] [string]$RelativePath
    )

    $source = Join-Path $sourceRoot $RelativePath
    $target = Join-Path $targetRoot $RelativePath

    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "No existe el archivo fuente: $RelativePath"
    }

    if ((Test-Path -LiteralPath $target) -and -not $Force) {
        Write-Warning "Se conserva el archivo existente: $RelativePath"
        return
    }

    $parent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Copy-Item -LiteralPath $source -Destination $target -Force
}

function Copy-HarnessDirectory {
    param(
        [Parameter(Mandatory)] [string]$RelativePath
    )

    $source = Join-Path $sourceRoot $RelativePath
    $target = Join-Path $targetRoot $RelativePath

    if (-not (Test-Path -LiteralPath $source -PathType Container)) {
        throw "No existe la carpeta fuente: $RelativePath"
    }

    New-Item -ItemType Directory -Force -Path $target | Out-Null
    Get-ChildItem -LiteralPath $source -Recurse -File | ForEach-Object {
        $relativeFile = $_.FullName.Substring($source.Length).TrimStart('\')
        $destination = Join-Path $target $relativeFile

        if ((Test-Path -LiteralPath $destination) -and -not $Force) {
            Write-Warning "Se conserva el archivo existente: $RelativePath/$relativeFile"
            return
        }

        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $destination) | Out-Null
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Force
    }
}

Copy-HarnessFile 'HARNESS.md'
Copy-HarnessFile '.harness\AGENTS.md'
Copy-HarnessFile '.harness\CONSTITUTION.md'
Copy-HarnessFile '.harness\slice-template.md'
Copy-HarnessFile '.harness\verify-slice.ps1'
Copy-HarnessDirectory '.opencode\agents'
Copy-HarnessDirectory '.opencode\skills'
Copy-HarnessDirectory '.harness\skills'

$memoryPath = Join-Path $targetRoot '.harness\MEMORY.md'
if (Test-Path -LiteralPath $memoryPath) {
    Write-Warning 'Se conserva el archivo existente: .harness/MEMORY.md'
} else {
    @'
# Memoria del proyecto

Memoria operativa del proyecto entre sesiones. Mantenerla breve, relevante y
actualizada, aproximadamente en 50 líneas o menos.

Engram MCP es la memoria persistente a largo plazo. Esta memoria resume el
estado operativo actual; las decisiones y aprendizajes duraderos se registran
también en Engram.

## Estado actual

- Arnés instalado.
- Software pendiente de definir.

## Decisiones y motivos

- (vacío por ahora)

## Aprendizajes y errores a evitar

- (vacío por ahora)

## Próximos pasos

- Definir el SDD del software.
'@ | Set-Content -LiteralPath $memoryPath -Encoding utf8
}

$slicePath = Join-Path $targetRoot '.harness_tmp\current_slice_spec.md'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $slicePath) | Out-Null
if (Test-Path -LiteralPath $slicePath) {
    Write-Warning 'Se conserva el archivo existente: .harness_tmp/current_slice_spec.md'
} else {
    Copy-Item -LiteralPath (Join-Path $targetRoot '.harness\slice-template.md') -Destination $slicePath
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $opencodeConfigPath) | Out-Null
if (Test-Path -LiteralPath $opencodeConfigPath) {
    Write-Warning "Se conserva la configuración existente: $opencodeConfigPath"
} else {
    @'
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "orchestrator",
  "instructions": [".harness/AGENTS.md"],
  "skills": ["./.harness/skills"],
  "agents": {
    "orchestrator": {
      "description": "Coordina el ciclo de slices y delega cada responsabilidad.",
      "mode": "primary",
      "permissions": [
        { "action": "*", "resource": "*", "effect": "deny" },
        { "action": "read", "resource": "*", "effect": "allow" },
        { "action": "glob", "resource": "*", "effect": "allow" },
        { "action": "grep", "resource": "*", "effect": "allow" },
        { "action": "edit", "resource": "*", "effect": "allow" },
        { "action": "shell", "resource": "*", "effect": "ask" },
        { "action": "question", "resource": "*", "effect": "allow" },
        { "action": "skill", "resource": "*", "effect": "allow" },
        { "action": "engram_*", "resource": "*", "effect": "allow" },
        { "action": "subagent", "resource": "explorer", "effect": "allow" },
        { "action": "subagent", "resource": "designer", "effect": "allow" },
        { "action": "subagent", "resource": "implementer", "effect": "allow" },
        { "action": "subagent", "resource": "verifier", "effect": "allow" }
      ]
    }
  }
}
'@ | Set-Content -LiteralPath $opencodeConfigPath -Encoding utf8
}

if ($WithCodeGraph) {
    & $nodePath $helperPath $opencodeConfigPath @otherConfigs
    if ($LASTEXITCODE -ne 0) {
        throw 'Falló la configuración del servidor CodeGraph.'
    }
}

$gitignorePath = Join-Path $targetRoot '.gitignore'
$requiredIgnores = @('.engram/', '.harness_tmp/')
if ($WithCodeGraph) {
    $requiredIgnores += '.codegraph/'
}
$existingIgnores = @()
if (Test-Path -LiteralPath $gitignorePath) {
    $existingIgnores = @(Get-Content -LiteralPath $gitignorePath)
}
$missingIgnores = @($requiredIgnores | Where-Object { $existingIgnores -notcontains $_ })
if ($missingIgnores.Count -gt 0) {
    Add-Content -LiteralPath $gitignorePath -Value $missingIgnores
}

if ($WithCodeGraph) {
    Push-Location -LiteralPath $targetRoot
    try {
        $statusJson = & $codegraphPath status --json
        $statusExit = $LASTEXITCODE
        $status = if ($statusJson) { ($statusJson -join "`n") | ConvertFrom-Json }
        if ($status.rebuildInProgress -or $status.index.rebuildInProgress) {
            throw 'CodeGraph está reconstruyendo el índice. Espera a que termine y repite la instalación.'
        }

        if ($status.initialized -eq $false -or
            -not (Test-Path -LiteralPath '.codegraph' -PathType Container)) {
            & $codegraphPath init --yes
            if ($LASTEXITCODE -ne 0) {
                throw 'Falló codegraph init. Repite la instalación para comprobar y recuperar el índice.'
            }
        } elseif ($statusExit -ne 0 -or $status.index.state -in @('indexing', 'partial', 'failed')) {
            & $codegraphPath index --force
            if ($LASTEXITCODE -ne 0) {
                throw 'Falló la reconstrucción de CodeGraph. Consulta el diagnóstico antes de reintentar.'
            }
        }

        $statusJson = & $codegraphPath status --json
        if ($LASTEXITCODE -ne 0) {
            throw 'CodeGraph no pudo comprobar el índice.'
        }
        $status = ($statusJson -join "`n") | ConvertFrom-Json
        if (-not $status.initialized -or $status.index.state -in @('indexing', 'partial', 'failed')) {
            throw 'El índice de CodeGraph sigue incompleto.'
        }
    } finally {
        Pop-Location
    }
}

Write-Output "Harness instalado en: $targetRoot"
Write-Output 'No se copiaron README.md, SDD.md, .engram/ ni la memoria del proyecto fuente.'
Write-Output 'Configura Engram globalmente con: engram setup opencode'
