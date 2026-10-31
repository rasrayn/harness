# Arnés de Desarrollo con IA

## Propósito

Arnés reutilizable para desarrollar software mediante slices verticales,
TDD, memoria persistente y mínima sobreingeniería.

## Principios

- KISS y YAGNI.
- Responsabilidad única (SRP): cada componente debe centrarse en una responsabilidad clara.
- Diseñar solo el slice actual.
- Implementar la solución mínima que satisfaga los tests.
- No crear abstracciones sin necesidad demostrada.
- Mantener el contexto de cada agente limitado.
- No inventar decisiones técnicas todavía no confirmadas.

## Documentos

- `HARNESS.md`: fuente maestra del arnés.
- `SDD.md`: fundamentos, arquitectura y roadmap del software.
- `.harness/AGENTS.md`: instrucciones operativas derivadas.
- `.harness/CONSTITUTION.md`: reglas innegociables y restricciones permanentes.
- `.harness/MEMORY.md`: memoria evolutiva del proyecto entre sesiones.
- `.harness/skills/`: skills derivadas.
- `.harness_tmp/current_slice_spec.md`: contrato temporal del slice.
- `.engram/`: datos locales de Engram MCP, memoria persistente a largo plazo.

`AGENTS.md`, los agentes y las skills son archivos operativos derivados y no
deben cambiar sus reglas sin actualizar antes `HARNESS.md`. `MEMORY.md` y
`current_slice_spec.md` son artefactos operativos y sí se actualizan durante el
flujo según sus procedimientos.

### Fuentes de verdad

- Proceso y política del arnés: `HARNESS.md`.
- Reglas innegociables: `.harness/CONSTITUTION.md`.
- Estado operativo actual: `.harness/MEMORY.md`.
- Responsabilidad y permisos de un rol: `.opencode/agents/<rol>.md`.
- Procedimiento reutilizable: `.harness/skills/<skill>/SKILL.md`.
- Decisiones y aprendizajes históricos: Engram MCP.

Los documentos operativos deben referenciar estas fuentes en lugar de copiar
sus reglas. Si dos fuentes discrepan, se detiene el trabajo y el Orquestador
resuelve la discrepancia antes de continuar.

## Roles

- **Orquestador:** coordina el ciclo, aplica las reglas y solicita decisiones.
- **Explorador:** consulta Engram e inspecciona el impacto del cambio.
- **Diseñador:** redacta el contrato y crea los tests.
- **Implementador:** implementa la solución mínima.
- **Verificador:** ejecuta tests, lint y comprobaciones del SDD.

El modelo y proveedor de cada rol se configuran fuera de este documento.

### Política de modelos

Aunque el proveedor y el modelo concreto se elijan por proyecto o sesión, se
prioriza el coste bajo según la complejidad de la tarea:

- **Diseñador:** modelo más capaz, porque define el contrato, los tests y las
  tareas que condicionan el resto del slice.
- **Orquestador:** modelo de capacidad suficiente para coordinar, detectar
  cambios de alcance y escalar bloqueos.
- **Explorador:** modelo económico para recuperar memoria e informar de hechos.
- **Implementador:** modelo económico, limitado por el contrato y los tests.
- **Verificador:** automatización local; modelo económico solo para interpretar
  errores o coordinar correcciones.

Si el contrato es ambiguo, el Implementador no debe compensarlo con más
autonomía: el trabajo vuelve al Diseñador.

## Skills

- `next-slice-orchestrator`: requerimiento, exploración, diseño, spec y tareas.
- `solve-slice-tdd`: implementación del contrato.
- `close-slice`: verificación, memoria y cierre.

## Flujo de un slice

1. Recibir el requerimiento.
2. Consultar Engram e inspeccionar el código relevante.
3. Confirmar alcance y arquitectura si se ven afectados.
4. Crear `current_slice_spec.md` y los tests reales.
5. Verificar RED.
6. Implementar sin modificar los tests ni el contrato.
7. Verificar GREEN, lint y formato según el SDD.
8. Realizar la aceptación manual.
9. Guardar en Engram un resumen de hasta tres líneas.
10. Limpiar únicamente los temporales del slice cerrado.

### Ejecución y verificación

- El Pre-check registra el estado base y separa los fallos preexistentes.
- El Verificador confirma RED por ausencia del comportamiento, no por un fallo
  ajeno al slice.
- El Implementador trabaja con el contrato y corrige solo errores derivados de
  su cambio.
- El Verificador devuelve el comando y el error relevante en cada fallo.
- El bucle Implementador-Verificador tiene un máximo de 3 intentos.
- Si falta una decisión o el test no expresa el comportamiento esperado, el
  trabajo vuelve al Diseñador.
- Si se requiere cambiar alcance o arquitectura, se consulta al usuario.
- Tras agotar los 3 intentos, se escala al usuario con el estado y la evidencia.
- Un fallo preexistente se registra como tal y solo bloquea si afecta al slice.

## Contrato del slice

Debe incluir:

- Objetivo observable.
- Alcance incluido y excluido.
- Restricciones aplicables.
- Archivos previstos.
- Contratos y tipos.
- Ubicación de los tests.
- Pre-check del estado base.
- Comandos de comprobación.
- Restricciones de calidad específicas.
- Criterios de aceptación manual.
- Dudas o bloqueos.
- Tareas de implementación.

El contrato debe ser breve. El Implementador puede leer el código
imprescindible para integrar el cambio, pero no recibe contexto general
innecesario.

## Checkpoints

El Orquestador debe consultar al usuario antes de:

- Cambiar el alcance acordado.
- Tomar una decisión de arquitectura.
- Resolver una ambigüedad que afecte al producto.
- Continuar ante un bloqueo no resoluble con el contexto disponible.

Puede actuar autónomamente en tareas rutinarias dentro del alcance aprobado.

## Memoria dinámica

Engram MCP es obligatorio.

- `.harness/CONSTITUTION.md` contiene las reglas innegociables.
- `.harness/MEMORY.md` resume el estado operativo actual del proyecto.
- Engram conserva la memoria persistente a largo plazo.

### Lectura

Al iniciar una sesión, el Orquestador lee la Constitución y `MEMORY.md`,
confirma el proyecto con `mem_current_project` y consulta `mem_context` o
`mem_search` solo para recuperar el contexto relacionado con el trabajo.
Para profundizar, usa la consulta progresiva de Engram: búsqueda, contexto
temporal y recuperación completa por identificador.

### Escritura

Guardar en Engram decisiones, configuraciones, bugs resueltos, descubrimientos,
convenciones y restricciones duraderas usando el formato `What`, `Why`,
`Where` y `Learned`. Usar `topic_key` solo para temas evolutivos y con claves
estables de dos niveles, como `architecture/auth-model`.

Al cerrar un slice, actualizar `MEMORY.md` con el estado y próximos pasos,
guardar el aprendizaje duradero en Engram y crear el resumen estructurado de
sesión mediante `mem_session_summary`. `MEMORY.md` debe mantenerse breve,
aproximadamente en 50 líneas o menos.

### Obsolescencia y privacidad

Contrastar siempre Engram con el código actual. Actualizar el mismo `topic_key`
cuando una decisión evoluciona, usar revisión y borrado suave cuando deje de
ser relevante, y conservar la historia solo si explica el estado actual.
No guardar secretos, tokens, contraseñas, conversaciones completas, logs
completos, código completo ni suposiciones no confirmadas.

Guardar:

- Decisiones duraderas y sus motivos.
- Convenciones.
- Problemas resueltos.
- Resumen de cierre del slice.

No guardar:

- Secretos, tokens o contraseñas.
- Conversaciones completas.
- Logs completos.
- Información que contradiga el estado actual del código.

## Cierre

Un slice solo se cierra cuando:

- Los tests pasan.
- El lint y formato pasan, si están definidos.
- Se completa la aceptación manual.
- Se registra el aprendizaje en Engram.
- Se conservan código y tests.
- Se limpian solo sus temporales.

Un slice bloqueado conserva sus artefactos para poder retomarse.

### Procedimiento de cierre y limpieza

1. El Verificador confirma tests, lint, formato y aceptación manual.
2. El Orquestador registra en `MEMORY.md` el estado actual y los próximos pasos.
3. Se guarda en Engram un resumen del slice de hasta tres líneas.
4. Las decisiones duraderas, bugs o descubrimientos se guardan por separado
   siguiendo el protocolo oficial de Engram.
5. La deuda técnica se registra en el SDD o registro del proyecto, con motivo
   y condición de revisión.
6. Se conservan el código, los tests y la evidencia mínima de aceptación.
7. Se comprueba que el slice no está bloqueado y que la ruta pertenece al
   temporal activo.
8. Se eliminan únicamente los artefactos temporales del slice cerrado.
9. Se inicia una nueva sesión solo después del cierre completo, cuando convenga
   reducir el contexto.

No se reinicia el repositorio ni se eliminan cambios ajenos al slice. Si el
slice está bloqueado, se conserva todo su contexto temporal.
