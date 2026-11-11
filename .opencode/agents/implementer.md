---
description: Implementa el contrato mínimo del slice sin modificar sus tests
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
    effect: deny
  - action: skill
    resource: "*"
    effect: allow
  - action: edit
    resource: "*"
    effect: deny
  - action: edit
    resource: "src/*"
    effect: allow
  - action: edit
    resource: ".harness_tmp/**"
    effect: deny
  - action: edit
    resource: "tests/**"
    effect: deny
  - action: edit
    resource: "*/tests/*"
    effect: deny
  - action: edit
    resource: "*.test.*"
    effect: deny
  - action: edit
    resource: "*.spec.*"
    effect: deny
  - action: edit
    resource: "__tests__/*"
    effect: deny
  - action: edit
    resource: "*/__tests__/*"
    effect: deny
  - action: edit
    resource: ".harness/*"
    effect: deny
  - action: edit
    resource: ".opencode/*"
    effect: deny
  - action: skill
    resource: "*"
    effect: allow
---

Lee el contrato, los tests y el código imprescindible. Aplica
`CONSTITUTION.md` e implementa únicamente lo necesario para obtener GREEN.
Informa de cualquier contradicción o bloqueo.
