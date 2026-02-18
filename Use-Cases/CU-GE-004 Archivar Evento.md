**Nombre del Caso de Uso:** Archivar Evento

**ID:** CU-GE-004

**Actor(es):** Coordinadora de EC

**Descripción:** La Coordinadora de EC archiva un evento en el sistema para que deje de estar disponible para inscripciones o modificaciones, manteniendo su información para fines de seguimiento y reportes.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- El evento a archivar existe en el sistema.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC selecciona la opción "Archivar evento" o un icono correspondiente junto a un evento en la lista de eventos.
2. El sistema solicita una confirmación a la Coordinadora de EC para archivar el evento.
3. La Coordinadora de EC confirma la acción.
4. El sistema cambia el estado del evento a **“Archivado”.**
    1. Se excluye de las listas activas
    2. Mantiene su información accesible únicamente para consulta y reportes.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora de EC cancela la acción antes de confirmar el archivado.
- **Alternativa B:** El evento cuenta con inscripciones activas.
    - El sistema debe notificar a los participantes inscritos sobre la cancelación del evento por parte de la Institución (CU-GE-025)
    - El sistema cambia el estado del evento a **“Cancelado”.**
- **Excepción C:** El evento ya se encuentra archivado.
    - El sistema notifica a la Coordinadora de EC que no se puede volver a archivar.
- **Excepción D:** Error del sistema al intentar archivar el evento.
    - El sistema muestra un mensaje de error.

**Post-condiciones:**

- El evento ya no es visible en la lista de eventos activos, pero su información se conserva para consulta y generación de reportes históricos.

---

**Aplicación en el sistema:**

- Opción al seleccionar un evento