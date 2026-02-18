**Nombre del Caso de Uso:** Consultar Eventos

**ID:** CU-GE-002

**Actor(es):** Coordinadora de EC

**Descripción:** La Coordinadora de EC consulta la lista de eventos registrados en el sistema, pudiendo aplicar filtros de búsqueda para visualizar los eventos según su estado, modalidad o fecha.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.
- La Coordinadora de EC cuenta con permisos para visualizar los eventos registrados.

**Flujo Básico (Camino Feliz):**

1. El sistema muestra una barra de búsqueda de eventos.
2. La Coordinadora de EC utiliza los **filtros disponibles** para la búsqueda, pudiendo filtrar los eventos por:
    - **Nombre del evento.**
3. El sistema actualiza y muestra la lista de eventos según los criterios seleccionados.
4. La Coordinadora de EC puede seleccionar un evento para **visualizar su información**.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** No existen eventos registrados en el sistema.
    - El sistema muestra el mensaje **“No existen eventos registrados actualmente.”**
- **Alternativa B:** No se encontraron resultados para los criterios aplicados.
    - El sistema muestra el mensaje **“No se encontraron eventos que coincidan con la búsqueda.”**
- **Excepción C:** Error en la carga de datos o pérdida de conexión.
    - El sistema muestra un mensaje de error y sugiere reintentar la acción.

**Post-condiciones:**

- La Coordinadora de EC ha visualizado la información de los eventos registrados.
- La Coordinadora puede proceder a realizar acciones adicionales.

---

**Aplicación en el sistema:**

- Vista principal dentro de gestión de eventos