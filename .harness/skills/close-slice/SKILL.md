---
name: close-slice
description: Verifica, registra y cierra un slice vertical sin perder aprendizajes
---

1. Lee `HARNESS.md`, `CONSTITUTION.md` y `current_slice_spec.md`.
2. Delega al Verificador los tests, lint, formato y la comprobación `-Phase Green`.
3. Ante un fallo de implementación registra `-Phase Failure` con el comando,
   código de salida y diagnóstico. Devuelve esos datos al Implementador
   mientras queden intentos. Los fallos de entorno y de contrato van al rol
   responsable sin contar como intentos.
4. Al agotar tres intentos, conserva diff, archivos, contrato y evidencia.
   Actualiza `MEMORY.md` con el bloqueo y propone subtareas si el diagnóstico lo justifica.
5. Tras GREEN, realiza la aceptación manual definida.
6. Actualiza `MEMORY.md` con el estado actual y los próximos pasos.
7. Guarda en Engram los aprendizajes duraderos. Usa `mem_session_summary` según
   el protocolo del plugin al terminar la sesión o tras compactación.
8. Registra la deuda técnica en el SDD o registro del proyecto cuando exista.
9. Verifica la ruta y limpia únicamente los temporales del slice cerrado.
