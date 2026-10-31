---
description: Define el contrato del slice y prepara los tests RED
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
  - action: edit
    resource: "*"
    effect: deny
  - action: edit
    resource: ".harness_tmp/**"
    effect: allow
  - action: edit
    resource: "tests/**"
    effect: allow
  - action: edit
    resource: "**/*test*"
    effect: allow
  - action: edit
    resource: "**/*spec*"
    effect: allow
  - action: skill
    resource: "*"
    effect: allow
---

Analiza el requerimiento y el informe del Explorador. Aplica `HARNESS.md` y
`CONSTITUTION.md`. Define la solución mínima y escribe
`.harness_tmp/current_slice_spec.md`, junto con los tests reales del slice en
estado RED. No modifiques código de producción.
