# Deviaciones de los Casos de Uso

Este documento registra las diferencias entre la implementación del prototipo y lo descrito en los casos de uso originales.

## CU-GE-001: Crear Evento

- **Profesores**: Se agregó un modelo `Professor` y `EventProfessor` (M2M con horas) que no existía en el backend original. La documentación menciona "Profesores (listado de profesores disponibles)" con horas, lo cual requería esta estructura de datos.
- **Descuentos aplicables (CU-GE-019)**: No se implementaron. Está explícitamente fuera del alcance del proyecto según el README ("Discount Management: No tools for managing discounts for each course").
- **Clonación de eventos**: Se implementó como endpoint dedicado `GET /events/{id}/clone/` que retorna datos del evento sin ID ni campos de estado/cancelación, listos para prellenar el formulario de creación. Los campos variables se resaltan con fondo amarillo en el formulario.
- **Notificaciones al usuario**: Las notificaciones por correo electrónico mencionadas en el flujo (ej. notificar participantes al cancelar) están simuladas — el backend registra la acción pero no envía correos reales a participantes (solo al sistema de coordinación existente).

## CU-GE-002: Consultar Evento

- **Filtros**: Se implementó búsqueda por nombre (search-as-you-type) y filtros por estado y modalidad. La documentación solo menciona filtro por nombre, pero se agregaron los filtros adicionales para mejorar la usabilidad.

## CU-GE-004: Archivar Evento

- Implementado según la documentación. Si el evento tiene inscripciones activas, se convierte a "Cancelado" automáticamente (Alternativa B).

## CU-GE-009: Gestionar Solicitudes de Inscripción

- **Vista por evento**: Se implementó un selector de evento para filtrar inscripciones, además de filtro por estado y búsqueda por nombre. La documentación describe navegar primero a eventos y luego a solicitudes — en el prototipo se usa una vista consolidada con filtros dropdown.
- **Visualización de documentos**: Se muestra un ícono indicando si hay documentos cargados. No se implementó un visor de documentos completo (fuera del alcance del prototipo).

## CU-GE-010: Validar Pagos Manuales

- **Comprobante de pago**: Se muestra información básica del comprobante en un diálogo. No se implementó una vista completa de comparación lado a lado con el extracto bancario (esto requeriría integración con sistemas externos).
- **Solicitar comprobante**: Implementado como acción que registra la solicitud. La notificación al participante es simulada.

## CU-GE-012-015: Gestión de Categorías

- Implementado completamente según la documentación. Crear, consultar, modificar y archivar categorías funciona con validación de eventos activos asociados.

## CU-GE-016: Gestionar Asistencia

- **No implementado**: Este módulo fue removido del prototipo. No será evaluado en esta versión de pruebas de usabilidad.

## CU-GE-025: Cancelación de Evento

- **Flujo de voucher/reembolso**: El backend registra la cancelación y genera vouchers para participantes con pago confirmado (via signals). El flujo donde cada participante elige entre voucher o reembolso no está completamente implementado en el frontend — el prototipo asume generación automática de voucher. Esto se debe a que el portal público del participante está fuera del alcance.
- **Motivo de cancelación**: Implementado como campo obligatorio en el diálogo de confirmación.

## Notas Generales

- **Navegación**: Se usa un NavigationRail lateral con 5 secciones (Eventos, Categorías, Inscripciones, Pagos, Mi cuenta) en lugar de una estructura jerárquica anidada. La sección de Asistencias fue removida del prototipo.
- **Esquema de color**: Se aplicó la identidad visual institucional con #002E5F como color principal y #C79316 como color de acento en toda la interfaz.
- **Idioma**: Toda la interfaz está en español, incluyendo mensajes de error en lenguaje administrativo natural.
- **Login**: El sistema de autenticación (login, registro, verificación de correo, recuperación de contraseña) ya estaba implementado y no se modificó.
