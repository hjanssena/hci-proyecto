**Nombre del Caso de Uso:** Crear Categoría de Evento

**ID:** CU-GE-012

**Actor(es):** Coordinadora de EC

**Descripción:** La Coordinadora de EC crea una nueva categoría para clasificar los eventos o capacitaciones (por ejemplo, "Maestría", "Diplomado", "Curso", "Taller").

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC accede a la sección de **"Gestión de Categorías"** dentro del módulo **"Gestión de Eventos"**.
2. El sistema muestra la opción **"Crear nueva categoría"**
3. Se presenta un formulario con el campo **"Nombre de la categoría"**.
4. La Coordinadora de EC ingresa el nombre de la nueva categoría (ejemplo: "Diplomado").
5. La Coordinadora de EC guarda la nueva categoría.
6. El sistema valida la información, confirma la creación y añade la categoría a la lista disponible.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora de EC cancela la creación antes de guardar.
- **Excepción B:** El nombre de la categoría ya existe.
    - El sistema notifica a la Coordinadora de EC que el nombre está duplicado.
- **Excepción C:** El nombre de la categoría está vacío o contiene caracteres inválidos.
    - El sistema solicita un nombre válido.
- **Excepción D:** El nombre de la categoría excede la longitud máxima.
    - El sistema solicita un nombre válido.

**Post-condiciones:**

- Se ha creado una nueva categoría activa en el sistema.
- La categoría está disponible para asignarse a eventos.

Aplicación en el sistema:

- Formulario dentro de gestión de categorías.