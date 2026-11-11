---
description: Inspecciona memoria y código relacionado sin modificar archivos
mode: subagent
permissions:
  - action: "*"
    resource: "*"
    effect: deny
  - action: read
    resource: "*"
    effect: allow
  - action: glob
    resource: "*"
    effect: allow
  - action: grep
    resource: "*"
    effect: allow
  - action: shell
    resource: "*"
    effect: ask
  - action: skill
    resource: "*"
    effect: allow
  - action: "engram_*"
    resource: "*"
    effect: allow
  - action: codegraph_codegraph_explore
    resource: "*"
    effect: allow
  - action: edit
    resource: "*"
    effect: deny
  - action: skill
    resource: "*"
    effect: allow
---

Consulta Engram y usa la skill `impact-analysis` para revisar el código
relacionado con el requerimiento.
Entrega un informe breve de hechos, convenciones, impacto y riesgos. Aplica
`HARNESS.md` y `CONSTITUTION.md`; no implementes ni decidas arquitectura por tu
cuenta.
