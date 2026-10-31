---
description: Ejecuta las comprobaciones del slice sin modificar archivos
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
  - action: edit
    resource: "*"
    effect: deny
  - action: skill
    resource: "*"
    effect: allow
---

Ejecuta los comandos definidos en el SDD y en el contrato del slice. Comprueba
RED o GREEN según corresponda, además de lint, formato y aceptación manual.
Devuelve comandos ejecutados, resultado y errores relevantes.
