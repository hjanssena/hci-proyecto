**Nombre del Caso de Uso:** Modificar Categoría de Evento

**ID:** CU-GE-014

**Actor(es):** Coordinadora de EC

**Descripción:**

La Coordinadora de EC actualiza los datos de una categoría de evento o capacitación existente, pudiendo modificar su **nombre** o su **estado** (Activa/Archivada).

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- La categoría a actualizar existe en el sistema.

**Flujo Básico (Camino Feliz):**

1. El sistema muestra la lista de categorías registradas.
2. La Coordinadora de EC selecciona la categoría que desea actualizar.
3. El sistema despliega la información editable de la categoría, incluyendo:
    - **Nombre de la categoría.**
    - **Estado actual** (Activa o Archivada).
4. La Coordinadora de EC realiza uno o ambos de los siguientes cambios:
    - **Modifica el nombre de la categoría.**
    - **Cambia el estado** entre Activa y Archivada.
5. La Coordinadora de EC guarda los cambios.
6. El sistema valida la información, actualiza la categoría y muestra un mensaje de confirmación.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora de EC cancela la actualización.
- **Excepción B:** El nuevo nombre ya existe.
    - El sistema notifica a la Coordinadora de EC sobre el nombre duplicado.
- **Excepción C:** El nuevo nombre está vacío o contiene caracteres inválidos.
    - El sistema solicita un valor válido.
- **Excepción D:** El cambio de estado a "Archivada" no puede completarse porque existen eventos activos asociados.
    - El sistema notifica la situación y sugiere resolver las dependencias.
- **Excepción E:** Error del sistema al intentar guardar los cambios.

**Post-condiciones:**

- La categoría ha sido actualizada en el sistema.
- Las categorías archivadas dejarán de estar disponibles para asignación en nuevos eventos.

Aplicación en el sistema:

- Formulario dentro de gestión de categorías