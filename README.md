# Arnés de desarrollo con IA

Plantilla reutilizable para desarrollar software mediante slices verticales,
TDD, Engram MCP y OpenCode con codeGraph para proyectos de mayor embergadura.

## Requisitos

- Windows y PowerShell.
- OpenCode Desktop o CLI.
- Engram instalado y disponible en `PATH`.
- Un proyecto destino existente o una carpeta vacía.

## Instalación de Engram

Instala Engram una vez por ordenador. Consulta su documentación oficial:

<https://github.com/Gentleman-Programming/engram>

En Windows, con un binario ya instalado:

```powershell
engram version
engram setup opencode
```

Reinicia OpenCode y abre una sesión nueva después de configurar Engram.

## Instalar el arnés en un proyecto

Clona este repositorio:

```powershell
git clone https://github.com/rasrayn/harness.git
cd harness
```

Instala el arnés indicando la ruta del proyecto destino:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto
```

Si la ruta contiene espacios, usa comillas:

```powershell
.\setup-harness.ps1 -ProjectPath "C:\Mis proyectos\mi-app"
```

El script crea:

- `HARNESS.md`.
- `.harness/` con Constitución, memoria inicial y skills.
- `.opencode/` con agentes y configuración del proyecto.
- `.harness_tmp/current_slice_spec.md`.
- Exclusiones necesarias en `.gitignore`.

No copia el README, SDD, código, `.engram/` ni la memoria del proyecto fuente.

## Activar CodeGraph

CodeGraph es opcional. Para activarlo necesitas OpenCode V2, Node.js y el CLI
`codegraph` en `PATH`. Instala el CLI siguiendo la
[documentación de CodeGraph](https://colbymchenry.github.io/codegraph/getting-started/installation/).
Desde el repositorio del arnés, instala la dependencia del helper y ejecuta:

```powershell
npm.cmd ci --prefix tools/codegraph
.\setup-harness.ps1 -ProjectPath "C:\Mis proyectos\mi-app" -WithCodeGraph
```

El instalador registra el MCP en el proyecto, conserva los servidores
existentes e inicializa el índice local. Reinicia OpenCode, abre una sesión
desde el destino y pide al Explorador que identifique un llamador conocido.
Puedes comprobar la conexión con `opencode mcp list` y revisar el índice con
`codegraph status --json`. Para un proyecto de prueba con el árbol limpio, usa
`codegraph status --strict` si tu versión lo admite. En CodeGraph 1.6.2,
comprueba que `index.state` es `complete` y que la consulta devuelve el
llamador esperado.

Piloto verificado en Windows con PowerShell 7.6.9, Node.js 24.11.0,
OpenCode 2.2.5, CodeGraph 1.6.2 y Engram 3.6.0.

Si la inicialización queda a medias, repite el instalador. Si CodeGraph
indica que hay un bloqueo, comprueba primero que el proceso propietario
ya no está activo. Solo entonces usa `codegraph unlock` desde el destino
y repite la instalación.

## Reinstalar o actualizar

Por defecto, los archivos existentes se conservan:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto
```

Para actualizar los archivos distribuidos por el arnés:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto -Force
```

`-Force` conserva la configuración existente de OpenCode, `MEMORY.md` y el
contrato activo. Con `-WithCodeGraph`, el instalador puede añadir la entrada MCP
de CodeGraph a esa configuración.

## Comprobación

Para proyectos con otra estructura, ajusta las reglas `edit` del Implementador
y el Diseñador en `.opencode/agents/`. La configuración inicial permite
producción bajo `src/` y reconoce las convenciones habituales de pruebas. Las
denegaciones de pruebas del Implementador deben quedar después de los permisos
de producción.

Si estás retomando un contrato de una instalación anterior, conserva su
contenido y adapta las secciones de rutas autorizadas y tests protegidos a
`.harness/slice-template.md` antes de registrar RED.

Desde el proyecto destino:

```powershell
Get-ChildItem .harness
Get-ChildItem .opencode\agents
Get-ChildItem .harness\skills -Recurse -Filter SKILL.md
```

Abre una sesión nueva de OpenCode y solicita al Orquestador que confirme el
proyecto con Engram.

## Estructura del repositorio

- `HARNESS.md`: proceso y política del arnés.
- `.harness/`: reglas, Constitución y skills.
- `.opencode/agents/`: roles y permisos.
- `setup-harness.ps1`: instalador para proyectos destino.

La memoria de Engram se crea y mantiene fuera de este repositorio, por proyecto.
