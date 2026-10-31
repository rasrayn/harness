# Arnés de desarrollo con IA

Plantilla reutilizable para desarrollar software mediante slices verticales,
TDD, Engram MCP y OpenCode.

## Instalación en un proyecto

Requisitos:

- Windows y PowerShell.
- OpenCode.
- Engram instalado y configurado globalmente.

Desde este repositorio:

```powershell
.\setup-harness.ps1 -ProjectPath C:\ruta\al\proyecto
```

Usa `-Force` solo si quieres reemplazar archivos del arnés existentes.
El script no copia el README, SDD, código ni memoria del proyecto fuente.

## Estructura

- `HARNESS.md`: proceso y política del arnés.
- `.harness/`: reglas, Constitución y skills.
- `.opencode/agents/`: roles y permisos.
- `setup-harness.ps1`: instalador para proyectos destino.

La memoria de Engram se crea y mantiene fuera de este repositorio, por proyecto.
