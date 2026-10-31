[CmdletBinding()]
param(
    [Parameter()]
    [string]$ProjectPath = (Get-Location).Path,

    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

$sourceRoot = (Resolve-Path (Join-Path $PSScriptRoot '.')).Path
$resolvedTarget = Resolve-Path -LiteralPath $ProjectPath -ErrorAction SilentlyContinue
$targetRoot = if ($resolvedTarget) {
    $resolvedTarget.Path
} else {
    [System.IO.Path]::GetFullPath($ProjectPath)
}

if (-not $targetRoot) {
    New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null
}

if ($sourceRoot.TrimEnd('\') -ieq $targetRoot.TrimEnd('\')) {
    throw 'El proyecto destino no puede ser el repositorio fuente del arnés.'
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
Copy-HarnessDirectory '.opencode\agents'
Copy-HarnessDirectory '.harness\skills'

$memoryPath = Join-Path $targetRoot '.harness\MEMORY.md'
if ((Test-Path -LiteralPath $memoryPath) -and -not $Force) {
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
if ((Test-Path -LiteralPath $slicePath) -and -not $Force) {
    Write-Warning 'Se conserva el archivo existente: .harness_tmp/current_slice_spec.md'
} else {
    @'
# Slice: [ID] — [Nombre]

## 1. Objetivo observable

Al terminar este slice, el usuario podrá: [resultado verificable y centrado en el comportamiento].

## 2. Alcance

Incluye:
- [comportamiento incluido]

No incluye:
- [comportamiento explícitamente excluido]

## 3. Restricciones aplicables

- Constitución: [reglas globales relevantes]
- SDD: [decisiones y comandos relevantes]
- Calidad: [restricciones específicas del slice]

## 4. Archivos

Crear:
- `[ruta]` — [responsabilidad]

Modificar:
- `[ruta]` — [cambio previsto y justificación]

Tests reales:
- `[ruta]` — [lógica específica que verifica]

## 5. Contrato

- Entrada: [tipo, formato o parámetros]
- Salida: [tipo, formato o resultado exitoso]
- Errores: [casos relevantes]
- Interfaces públicas: [firmas, API o tipos; indicar "ninguna" si aplica]

## 6. Tareas

- [ ] [infraestructura o tests]
- [ ] [implementación de lógica]
- [ ] Ejecutar lint y formato

## 7. Verificación

- Pre-check: `[comando o "no definido"]`
- RED: `[comando del test nuevo]`
- GREEN: `[comando del test nuevo]`
- Lint/formato: `[comando o "no definido"]`

## 8. Aceptación manual

- [ ] [paso observable]
- [ ] [resultado esperado exacto]

## 9. Bloqueos y dudas

- [Ninguno / duda que requiere escalado]

## Estado del Slice

- Diseño: pendiente
- RED: pendiente
- Implementación: pendiente
- GREEN: pendiente
- Aceptación: pendiente
'@ | Set-Content -LiteralPath $slicePath -Encoding utf8
}

$opencodeConfigPath = Join-Path $targetRoot '.opencode\opencode.jsonc'
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $opencodeConfigPath) | Out-Null
if ((Test-Path -LiteralPath $opencodeConfigPath) -and -not $Force) {
    Write-Warning 'Se conserva la configuración existente: .opencode/opencode.jsonc'
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

$gitignorePath = Join-Path $targetRoot '.gitignore'
$requiredIgnores = @('.engram/', '.harness_tmp/')
$existingIgnores = @()
if (Test-Path -LiteralPath $gitignorePath) {
    $existingIgnores = @(Get-Content -LiteralPath $gitignorePath)
}
$missingIgnores = @($requiredIgnores | Where-Object { $existingIgnores -notcontains $_ })
if ($missingIgnores.Count -gt 0) {
    Add-Content -LiteralPath $gitignorePath -Value $missingIgnores
}

Write-Output "Harness instalado en: $targetRoot"
Write-Output 'No se copiaron README.md, SDD.md, .engram/ ni la memoria del proyecto fuente.'
Write-Output 'Configura Engram globalmente con: engram setup opencode'
