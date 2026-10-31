# Constitución del proyecto

Reglas innegociables. Toda spec, plan, tarea y cambio debe cumplirlas.

## Principios

- **KISS:** elegir la solución más simple que satisfaga el comportamiento.
- **YAGNI:** no implementar necesidades futuras.
- **Responsabilidad única:** cada componente debe centrarse en una responsabilidad clara.
- **La spec manda:** no se implementa nada que no esté en la spec activa.
- **Tests como puerta:** RED debe confirmarse antes de implementar y no se
  acepta ni se cierra un slice mientras sus tests sigan en rojo.
- **Diseño justo a tiempo:** no decidir detalles que el slice actual no necesita.

## Restricciones confirmadas

- No inventar decisiones de producto, arquitectura o stack.
- No crear abstracciones, interfaces o patrones sin necesidad demostrada.
- No modificar ni debilitar tests para conseguir que pasen.
- Mantener el contexto y las transferencias entre agentes limitados.
- Los comandos técnicos y decisiones específicas pertenecen al SDD.

## Política de cambios

Esta constitución solo cambia cuando aparece una regla permanente nueva o se
revisa una regla existente. Los cambios deben reflejarse primero en `HARNESS.md`
y requerir confirmación del usuario.
