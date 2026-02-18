**Nombre del Caso de Uso:** Consultar Categorías de Evento/Capacitación

**ID:** CU-GE-013

**Actor(es):** Coordinadora de EC

**Descripción:** La Coordinadora de EC visualiza una lista de todas las categorías de eventos existentes en el sistema.

**Precondiciones:**

- La Coordinadora de EC ha iniciado sesión en el sistema.

**Flujo Básico (Camino Feliz):**

1. La Coordinadora de EC accede a la sección de **"Gestión de Categorías"**.
2. El sistema muestra una lista con todas las categorías registradas.
    1. Se incluye el nombre y su estado (activa o archivada).
3. La Coordinadora de EC puede utilizar filtros o la barra de búsqueda para localizar categorías específicas
    1. Permite el filtrado por nombre y por estado.
4. El sistema actualiza la lista según los criterios aplicados.

**Flujos Alternativos y Excepciones:**

- **Alternativa A:** No existen categorías registradas.
    - El sistema muestra un mensaje indicando que no hay categorías disponibles.

**Post-condiciones:**

- La Coordinadora de EC ha visualizado la información de las categorías registradas.
- La lista de categorías puede servir como base para realizar acciones adicionales, como modificar o archivar categorías.

Aplicación en el sistema:

- Vista principal dentro de gestión de categorías