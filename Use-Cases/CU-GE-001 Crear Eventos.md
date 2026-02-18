**Nombre del Caso de Uso:** Crear Evento

**ID:** CU-GE-001

**Actor(es):** Coordinadora de EC

**Descripción:**

La Coordinadora de EC crea un nuevo evento en el sistema, especificando sus detalles como nombre, descripción, fechas, modalidad, profesor(es), precios y la cantidad mínima de inscripciones requeridas para su confirmación.

El sistema permite también **crear un nuevo evento tomando como base uno previamente realizado**, reutilizando información como profesores, categorías o configuraciones de descuento.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- Cuenta con permisos para gestionar eventos.
- Existen reglas de descuento preconfiguradas en el sistema (CU-GE-019).
- Existen categorías de evento preconfiguradas en el sistema (CU-GE-012).
- Existen profesores registrados en el sistema.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC selecciona la opción **“Crear evento”** dentro del módulo **“Gestión de eventos”**.
2. El sistema ofrece dos opciones:
    - **Crear un evento desde cero.**
    - **Crear un evento basado en uno existente.**
3. Si elige la segunda opción, el sistema muestra un buscador de eventos anteriores (CU-GE-002).
    - Al seleccionar uno, el sistema precarga los campos del evento base, como categoría, profesores, precios, modalidad, descuentos y requisitos.
    - La Coordinadora puede modificar cualquier dato antes de guardar.
4. El sistema presenta el **formulario de creación de evento** con los siguientes campos:
    - Nombre del evento.
    - Categoría del evento (lista de categorías configuradas).
    - Descripción general.
    - Estado del evento (Activo / Archivado).
    - Fechas: inicio y fin (no puede superar un año ni ser anterior a la fecha actual).
    - Horario del evento y duración (en horas).
    - Modalidad: presencial, virtual o híbrida.
    - Aula o enlace de acceso (según la modalidad).
    - Profesores (listado de profesores disponibles).
        - Horas del profesor.
    - Capacidad máxima y cantidad mínima de inscripciones requeridas.
    - Importe (precio base).
        - Descuentos aplicables (lista de descuentos preconfigurados, CU-GE-019).
    - Puntos EPC (Sí/No).
    - Requisitos de acreditación (texto).
    - Por contrato (Sí/No).
    - Con organización (texto).
5. La Coordinadora completa los datos requeridos y selecciona **“Guardar”**.
6. El sistema valida los datos y registra el evento con estado inicial **“En fase de inscripciones”**, indicando que aún no ha alcanzado el mínimo necesario para su confirmación.
7. El sistema muestra un mensaje de confirmación y lista el evento en la sección **“Gestión de eventos”**.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** La Coordinadora cancela la creación antes de guardar.
    - El sistema descarta los cambios y cierra el formulario.
- **Excepción B:** Faltan campos obligatorios.
    - El sistema resalta los campos faltantes.
- **Excepción C:** Fechas inválidas (fin anterior al inicio o fuera del rango permitido).
- **Excepción D:** Tarifas o precios con formato incorrecto.
- **Excepción E:** La cantidad mínima de inscripciones es mayor que la capacidad máxima.
    - El sistema muestra el error e impide guardar.

**Post-condiciones:**

- Se ha creado un nuevo evento con estado **“En fase de inscripciones”**.
- El evento incluye la **cantidad mínima de inscripciones requeridas** como parte de sus detalles.
- El evento aparece en la lista general de eventos con su estado visible.
- Cuando el número de inscripciones alcanza la cantidad mínima establecida, el evento puede pasar automáticamente o manualmente al estado **“Confirmado”**.

---

**Aplicación en el sistema:**

- Formulario dentro de gestión de eventos