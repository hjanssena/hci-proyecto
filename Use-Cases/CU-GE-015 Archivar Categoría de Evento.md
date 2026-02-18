**Nombre del Caso de Uso:** Archivar Categoría de Evento

**ID:** CU-GE-015

**Actor(es):** Coordinadora de EC

**Descripción:** La Coordinadora de EC archiva una categoría de evento, de modo que deja de estar disponible para nuevas asignaciones, pero se mantiene en el sistema para fines históricos.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- La categoría a archivar existe en el sistema.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC selecciona la categoría que desea archivar de la lista.
2. El sistema solicita una confirmación para proceder con el archivado.
3. La Coordinadora de EC confirma la acción.
4. El sistema cambia el estado de la categoría a **“Archivada”.**
5. Se retira de las opciones disponibles para nuevas asignaciones.
6. Es actualizada la lista de categorías.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora de EC cancela el proceso de archivado.
- **Excepción B:** La categoría está siendo utilizada por uno o más eventos activos.
    - El sistema notifica a la Coordinadora de EC
    - Se sugiere reasignar los eventos a otra categoría antes de poder archivarla.

**Post-condiciones:**

- La categoría ha sido marcada como **“Archivada”** y ya no está disponible para su selección en nuevos eventos o capacitaciones.
- Los eventos previamente asociados a la categoría archivada conservarán la referencia para fines de registro histórico.

Aplicación en el sistema:

- Opción dentro de vista principal de gestión de categorías