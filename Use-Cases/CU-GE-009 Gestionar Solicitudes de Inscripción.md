**Nombre del Caso de Uso:** Gestionar Solicitudes de Inscripción

**ID:** CU-GE-009

**Actor(es):** Coordinación

**Descripción:** La coordinación revisa las solicitudes de inscripción enviadas por el Público General para un evento, y procede a aprobarlas, rechazarlas, o solicitar información adicional, gestionando así la lista final de participantes.

**Precondiciones:**

- La Coordinación ha iniciado sesión en el sistema.
- Existen solicitudes de inscripción con el estado "Pendiente de Revisión" o "Información Requerida".
- El evento asociado a la solicitud existe y está disponible para recibir inscripciones.

**Flujo Básico (Camino Feliz):**

1. La **Coordinación** accede a la sección de "Gestión de Eventos" y selecciona la opción "Gestión de Solicitudes de Inscripción".
2. El **sistema** muestra una lista de eventos con solicitudes pendientes.
3. La **Coordinación** selecciona un evento para revisar.
4. La **Coordinación** selecciona una solicitud específica para revisar.
5. El **sistema** muestra los detalles completos de la solicitud: información del solicitante, documentos cargados y estado actual.
6. La **Coordinación** revisa la información y los documentos para determinar si la solicitud cumple con los criterios.
7. **Si decide aprobar la solicitud:**
    1. La **Coordinación** selecciona la opción de Aprobar Solicitud.
    2. El **sistema** verifica el cupo disponible del evento para participantes inscritos.
    3. El **sistema** actualiza el estado de la solicitud a "Aprobada".
    4. El **sistema** registra al usuario como **Participante Inscrito** o **Inscrito - Pendiente de Pago** si aplica costo.
    5. El **sistema** envía una notificación al usuario indicando la aprobación y, si corresponde, las instrucciones de pago (relación con CU-PG-006: _Realizar Pago de Inscripción_).
8. **Si decide rechazar la solicitud:**
    1. La **Coordinación** selecciona la opción Rechazar Solicitud.
    2. El **sistema** solicita a la Coordinación que proporcione un motivo de rechazo.
    3. La **Coordinación** ingresa el motivo y confirma la acción.
    4. El **sistema** actualiza el estado de la solicitud a "Rechazada".
    5. El **sistema** notifica al usuario sobre el rechazo de su solicitud, incluyendo el motivo.
9. **Si decide solicitar más información:**
    1. La **Coordinación** selecciona la opción Solicitar Más Información.
    2. El **sistema** solicita el detalle de la información requerida.
    3. La **Coordinación** ingresa el detalle de la información requerida y confirma la acción.
    4. El **sistema** actualiza el estado de la solicitud a "Información Requerida".
    5. El **sistema** notifica al usuario sobre la información adicional requerida, con instrucciones para proporcionarla.

**Flujos Alternativos y Excepciones:**

- **Alternativa A (Cancelar Revisión):** La Coordinación decide no procesar la solicitud en ese momento y vuelve a la lista de solicitudes.
- **Excepción B (Evento sin cupo al aprobar):** Si al momento de aprobar, el cupo del evento ya fue llenado por otras aprobaciones o asignaciones.
    - El **sistema** informa a la Coordinación que el evento ha alcanzado su límite de cupo y no permite la aprobación.
- **Excepción C (Solicitud ya procesada):** Si la solicitud ya se encuentra con estado distinto a Pendiente de Revisión o Información Requerida, el sistema muestra un mensaje con el estado actual.
- **Excepción D (Error de Sistema):** Ocurre un error inesperado al intentar procesar la solicitud.
    - El **sistema** muestra un mensaje de error genérico.

**Post-condiciones:**

- El estado de la solicitud de inscripción ha cambiado (Aprobada, Rechazada, Información Requerida).
- Si la solicitud fue aprobada y se tiene registro del pago, el usuario está ahora registrado como participante del evento
- Se ha actualizado el conteo de participantes del evento.
- El usuario ha sido notificado sobre la decisión de la coordinación.

Aplicación en el sistema:

- Vista principal dentro de gestión de solicitudes