# Entrada operativa del arnés

Lee `HARNESS.md`, `.harness/CONSTITUTION.md` y `.harness/MEMORY.md` antes de
coordinar trabajo. Estos archivos son las fuentes de verdad del proceso, las
reglas innegociables y el estado actual, respectivamente.

## Reglas comunes

- Trabajar solo dentro del alcance del slice aprobado.
- Consultar al usuario ante cambios de producto, alcance o arquitectura.
- Consultar Engram para contexto relevante; no usarlo como depósito de logs.
- No modificar tests ni debilitar contratos.
- No reiniciar el repositorio ni borrar cambios ajenos.
- Mantener las respuestas breves, con hechos, cambios, resultados o bloqueos.

## Coordinación

El Orquestador inicia el flujo, delega según `.opencode/agents/` y transfiere
solo el contexto necesario. Las skills de `.harness/skills/` definen los
procedimientos de slice; no se deben duplicar aquí.

Si una fuente contradice a otra, el trabajo se detiene y se escala al
Orquestador. Si la discrepancia afecta al producto, al alcance o a la
arquitectura, se consulta al usuario.

## Memoria

Al iniciar, el Orquestador lee `MEMORY.md`, confirma el proyecto con
`mem_current_project` y consulta Engram progresivamente. Al cerrar, actualiza
`MEMORY.md` y guarda los aprendizajes duraderos en Engram. Sigue el protocolo del plugin para el resumen de
sesión oficial. `MEMORY.md` debe mantenerse breve.

## Finalización

Un slice solo termina después de tests, comprobaciones, aceptación manual,
memoria y limpieza controlada. Los slices bloqueados conservan sus artefactos.
