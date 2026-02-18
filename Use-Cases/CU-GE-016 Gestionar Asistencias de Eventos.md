**Nombre del Caso de Uso:** Gestionar Asistencia de Eventos

**ID:** CU-GE-016

**Actor(es):** Coordinadora de EC

**Descripción:** La coordinadora de EC carga las asistencias para cada evento que haya finalizado.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- Existen eventos registrados y participantes asociados.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC accede a la sección de asistencias dentro de Gestión de Eventos.
2. El sistema muestra una lista de eventos disponibles para la carga de asistencia.
3. La Coordinadora de EC selecciona un evento específico para el cual desea cargar asistencias.
4. El sistema despliega la opción para cargar asistencias.
5. La Coordinadora de EC carga las asistencias.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora de EC decide no cargar las asistencias después de ver la lista de eventos disponibles.
- **Excepción B:** Error en la carga del documento. El sistema informa a la Coordinadora de EC.

**Post-condiciones:**

- Las asistencias han sido cargadas y la información está disponible en el sistema para su uso en otras operaciones.

Aplicación en el sistema:

- Vista principal dentro de gestión de asistencias