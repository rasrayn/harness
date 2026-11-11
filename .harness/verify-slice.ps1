[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Baseline', 'Red', 'Green', 'Failure')]
    [string]$Phase,

    [switch]$Checkpoint,
    [string]$FailedCommand,
    [int]$ExitCode,
    [string]$Diagnostic
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$state = Join-Path $root '.harness_tmp'
$spec = Join-Path $state 'current_slice_spec.md'
$redPath = Join-Path $state 'red.json'

function Get-WorkspaceHashes {
    $paths = git -C $root -c core.quotePath=false ls-files --cached --others --exclude-standard
    if ($LASTEXITCODE -ne 0) { throw 'No se pudieron enumerar los archivos del proyecto.' }
    $hashes = @{}
    foreach ($path in $paths) {
        $file = Join-Path $root $path
        if (Test-Path -LiteralPath $file -PathType Leaf) {
            $hashes[$path] = (Get-FileHash -LiteralPath $file).Hash
        }
    }
    return $hashes
}

function Get-Section([string]$Text, [string]$Name) {
    $pattern = '(?ms)^## ' + [regex]::Escape($Name) + '\s*\r?\n(.*?)(?=^## |\z)'
    $section = [regex]::Match($Text, $pattern)
    if (-not $section.Success) { throw "Falta la sección $Name en el contrato." }
    return $section.Groups[1].Value
}

function Assert-RelativePath([string]$Path) {
    if ($Path -match '(^/|[:\\*?\[\]]|(?:^|/)\.{1,2}(?:/|$)|^\.git(?:/|$)|^\.harness_tmp(?:/|$))') {
        throw "Ruta inválida en el contrato: $Path"
    }
}

function Save-State([string]$Name, $Data) {
    $destination = Join-Path $state $Name
    $Data | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $destination -Encoding utf8
}

if ($Phase -eq 'Failure') {
    if (-not $FailedCommand -or -not $Diagnostic -or $ExitCode -eq 0) {
        throw 'Registra el comando, el código de salida y el diagnóstico del fallo de implementación.'
    }
    if (-not (Test-Path -LiteralPath $redPath)) {
        throw 'Registra RED antes de contabilizar fallos de implementación.'
    }
    $failurePath = Join-Path $state 'attempts.json'
    $attempts = @()
    if (Test-Path -LiteralPath $failurePath) {
        $attempts = @((Get-Content -LiteralPath $failurePath -Raw | ConvertFrom-Json).attempts)
    }
    if ($attempts.Count -ge 3) { throw 'El slice está bloqueado tras tres intentos.' }
    $attempts += @{ command = $FailedCommand; exitCode = $ExitCode; diagnostic = $Diagnostic }
    $blocked = $attempts.Count -ge 3
    Save-State 'attempts.json' @{ attempts = $attempts; blocked = $blocked }
    if ($blocked) {
        $diff = Join-Path $state 'blocked.diff'
        git -C $root diff --binary "--output=$diff" HEAD
        if ($LASTEXITCODE -ne 0) {
            Write-Warning 'No se pudo exportar el diff. Los archivos siguen en el proyecto.'
        }
        Write-Output 'Slice bloqueado tras tres intentos. Conserva los archivos y actualiza MEMORY.md.'
    } else {
        Write-Output "Intento $($attempts.Count) de 3 registrado."
    }
    return
}

$current = Get-WorkspaceHashes
if ($Phase -eq 'Baseline') {
    if (Test-Path -LiteralPath $redPath) {
        throw 'Ya hay una referencia RED activa. Retoma el slice o archiva su evidencia antes de iniciar otro.'
    }
    $changes = @(git -C $root status --porcelain)
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo comprobar el estado inicial de Git.' }
    New-Item -ItemType Directory -Path $state -Force | Out-Null
    Save-State 'baseline.json' @{ files = $current; changes = $changes }
    Write-Output 'Estado base registrado.'
    return
}

if ($Phase -eq 'Red') {
    if (Test-Path -LiteralPath $redPath) {
        throw 'La referencia RED ya está registrada. Consérvala durante los reintentos.'
    }
    if (-not (Test-Path -LiteralPath (Join-Path $state 'baseline.json'))) {
        throw 'Registra el estado base antes de RED.'
    }
    $contract = Get-Content -LiteralPath $spec -Raw -Encoding UTF8
    $allowed = @{}
    $protected = @{}
    $routes = Get-Section $contract 'Rutas autorizadas'
    foreach ($line in ($routes -split '\r?\n')) {
        if ($line -match '^\s*\|\s*`([^`]+)`\s*\|\s*(crear|modificar|eliminar)\s*\|\s*$') {
            $path = $Matches[1]
            $operation = $Matches[2].ToLowerInvariant()
            Assert-RelativePath $path
            if ($allowed.ContainsKey($path)) { throw "Ruta autorizada repetida: $path" }
            $allowed[$path] = $operation
        } elseif ($line.Trim() -and $line -notmatch '^\s*\|\s*(Ruta relativa\s*\|\s*Operación|[-:]+\s*\|\s*[-:]+)\s*\|\s*$') {
            throw "Fila inválida en Rutas autorizadas: $line"
        }
    }
    $tests = Get-Section $contract 'Tests protegidos'
    foreach ($line in ($tests -split '\r?\n')) {
        if (-not $line.Trim()) { continue }
        if ($line -notmatch '^\s*-\s+`([^`]+)`\s*$') { throw "Test protegido inválido: $line" }
        $path = $Matches[1]
        Assert-RelativePath $path
        if (-not $current.ContainsKey($path)) { throw "Falta el test protegido: $path" }
        $protected[$path] = $current[$path]
    }
    if ($protected.Count -eq 0) { throw 'El contrato debe identificar los tests de RED.' }
    if ($Checkpoint) {
        $baseline = Get-Content -LiteralPath (Join-Path $state 'baseline.json') -Raw | ConvertFrom-Json
        if (@($baseline.changes).Count -gt 0) { throw 'El checkpoint requiere un estado base limpio.' }
        $gitDir = git -C $root rev-parse --absolute-git-dir
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo identificar el worktree.' }
        $commonDir = git -C $root rev-parse --path-format=absolute --git-common-dir
        if ($LASTEXITCODE -ne 0 -or $gitDir -eq $commonDir) {
            throw 'El checkpoint con commit requiere un worktree dedicado.'
        }
        $testPaths = @($protected.Keys)
        git -C $root --literal-pathspecs add -- @testPaths
        if ($LASTEXITCODE -ne 0) { throw 'No se pudieron preparar los tests de RED.' }
        git -C $root --literal-pathspecs commit --only -m 'Checkpoint RED del slice' -- @testPaths
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo crear el commit local de RED.' }
    }
    Copy-Item -LiteralPath $spec -Destination (Join-Path $state 'red-contract.md')
    Save-State 'red.json' @{
        contract = (Get-FileHash -LiteralPath $spec).Hash
        files = $current
        tests = $protected
        allowed = $allowed
    }
    Write-Output 'Referencia RED registrada.'
    return
}

$red = Get-Content -LiteralPath $redPath -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $spec) -or (Get-FileHash -LiteralPath $spec).Hash -ne $red.contract) {
    throw 'El contrato cambió después de RED.'
}
foreach ($test in $red.tests.PSObject.Properties) {
    if ($current[$test.Name] -ne $test.Value) { throw "El test cambió después de RED: $($test.Name)" }
}
$previous = @{}
foreach ($file in $red.files.PSObject.Properties) { $previous[$file.Name] = $file.Value }
$allowed = @{}
foreach ($file in $red.allowed.PSObject.Properties) { $allowed[$file.Name] = $file.Value }
$allPaths = @($previous.Keys) + @($current.Keys) | Sort-Object -Unique
foreach ($path in $allPaths) {
    if ($previous[$path] -eq $current[$path]) { continue }
    $operation = if (-not $previous.ContainsKey($path)) { 'crear' }
        elseif (-not $current.ContainsKey($path)) { 'eliminar' }
        else { 'modificar' }
    if ($allowed[$path] -ne $operation) { throw "Cambio fuera del contrato: $operation $path" }
}
Write-Output 'Integridad y alcance GREEN verificados.'
