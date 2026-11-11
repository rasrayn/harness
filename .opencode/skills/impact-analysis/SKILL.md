---
name: impact-analysis
description: Identifica dependencias y pruebas relevantes antes de redactar el contrato de un slice
---

1. Identifica los símbolos o puntos de entrada candidatos a partir del requerimiento.
2. Si está disponible, consulta `codegraph_codegraph_explore` con los nombres de
   los símbolos y sus rutas. Revisa llamadores y dependencias directas. Amplía a
   un segundo salto si aparece otro módulo o punto de entrada.
3. Si la herramienta falta, falla o devuelve resultados parciales, busca las
   referencias y lee los archivos relevantes. Comprueba en el código las
   relaciones que condicionen el alcance.
4. Entrega al Orquestador las rutas y símbolos afectados, los tests relacionados
   y las relaciones pendientes de confirmar. Indica cualquier límite de
   cobertura para que el Diseñador pueda tenerlo en cuenta.
