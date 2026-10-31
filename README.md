# Arnés de desarrollo con IA

Plantilla reutilizable para desarrollar software mediante slices verticales,
TDD, Engram MCP y OpenCode.

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
git clone https://github.com/[usuario]/harness.git
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

## Reinstalar o actualizar

Por defecto, los archivos existentes se conservan:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto
```

Para reemplazar los archivos del arnés:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto -Force
```

Usa `-Force` solo después de revisar los cambios locales del proyecto.

## Comprobación

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
