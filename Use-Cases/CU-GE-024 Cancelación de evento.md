## **Nombre del Caso de Uso:** Cancelar Evento

**ID:** CU-GE-025

**Actor(es):** Coordinadora de EC

---

### **Descripción:**

La Coordinadora de EC cancela un evento previamente programado, ofreciendo a los participantes la opción de recibir un **voucher de descuento** para futuras inscripciones o una **devolución del dinero** mediante el mismo método de pago utilizado.

Si el participante acepta el voucher, el sistema lo genera de acuerdo con las reglas de negocio establecidas; de lo contrario, se inicia el proceso de reembolso monetario.

---

### **Precondiciones:**

- El evento se encuentra **registrado y activo** en el sistema.
- Existen participantes **inscritos con pago confirmado**.
- La Coordinadora de EC tiene permisos para cancelar eventos.

---

### **Flujo Básico (Camino Feliz):**

1. La **Coordinadora de EC** accede al módulo **Gestión de Eventos**.
2. La **Coordinadora de EC** selecciona el evento que desea cancelar.
3. La **Coordinadora de EC** confirma la **cancelación del evento**, indicando el **motivo de cancelación**.
4. El **sistema** notifica a los participantes afectados sobre la cancelación.
5. Cada participante elige entre:
    - **Opción A:** Recibir un **voucher de descuento** aplicable a futuros eventos.
        - El **sistema** genera un voucher aplicando las reglas preestablecidas (por ejemplo, 100% del monto pagado, válido por 1 año, uso único).
        - El **sistema** almacena el voucher y notifica al participante.
    - **Opción B:** Recibir la **devolución del dinero** mediante el mismo método de pago utilizado.
        - El **sistema** registra la solicitud de devolución y **genera una orden de reembolso** mediante el mismo método de pago.
        - El **sistema** actualiza el estado de pago como “Reembolso en proceso” o “Reembolso completado”.
6. El **sistema** marca el evento como **cancelado** registrando la fecha y motivo.

---

### **Flujos Alternativos y Excepciones:**

- **Excepción A:** Error en la generación del voucher.
    - El sistema notifica a la Coordinadora de EC y registra el incidente para revisión.
- **Excepción B:** Fallo en la devolución monetaria (por ejemplo, método de pago inválido o vencido).
    - El sistema notifica al participante y a la Coordinadora de EC para gestionar la devolución por medios alternativos.

---

### **Post-condiciones:**

- El evento se marca como **cancelado** en el sistema.
- Los participantes han sido notificados.
- Se ha generado un **voucher** o iniciado un **reembolso monetario**, según la decisión del participante.

---

### **Aplicación en el sistema:**

- Funcionalidad dentro del módulo **Gestión de Eventos**.