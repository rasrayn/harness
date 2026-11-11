---
name: next-slice-orchestrator
description: Coordina exploración, diseño, contrato, tests RED y tareas del siguiente slice vertical
---

1. Lee el requerimiento y aclara el objetivo observable.
2. Lee `HARNESS.md`, `CONSTITUTION.md` y `MEMORY.md`.
3. Confirma el proyecto con `mem_current_project` y consulta Engram de forma progresiva, filtrando por módulo cuando ya se conozca.
4. Delega la inspección al Explorador con la skill `impact-analysis`. Pasa su informe de impacto al Diseñador antes de redactar el contrato.
5. Define el alcance mínimo y consulta al usuario si cambia arquitectura o producto.
6. Ejecuta `.harness/verify-slice.ps1 -Phase Baseline` antes de delegar al Diseñador el contrato y los tests.
7. Comprueba que el contrato use `.harness/slice-template.md` y tenga tareas ejecutables.
8. Pide al Verificador que ejecute RED. Registra comando, salida y causa.
9. Tras un RED válido ejecuta `.harness/verify-slice.ps1 -Phase Red`. Añade
   `-Checkpoint` en un worktree dedicado con estado base limpio. Si dependes de
   cambios locales del usuario, conserva la referencia RED en la carpeta actual.
   Delega la implementación cuando quede registrada la referencia.
