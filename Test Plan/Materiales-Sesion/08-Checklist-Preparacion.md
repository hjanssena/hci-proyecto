# Checklist de Preparación de la Sesión
### Para el facilitador — revisar **antes** de cada sesión

---

## Día previo a la sesión

- [ ] Confirmar cita con el participante (hora, lugar o liga de videollamada).
- [ ] Verificar que el participante cumple con los criterios de reclutamiento:
  - [ ] Experiencia con software administrativo (Excel, ERP, sistemas escolares).
  - [ ] Sin exposición previa al prototipo.
  - [ ] Edad entre 25 y 55 años.
- [ ] Enviar al participante un correo recordatorio con:
  - [ ] Día, hora y duración estimada (60 min).
  - [ ] Indicaciones técnicas (si es remoto: liga, navegador, micrófono).
  - [ ] Mención de que la sesión será grabada con su consentimiento.

---

## Preparación técnica del entorno

- [ ] Prototipo desplegado y accesible desde el dispositivo de prueba.
- [ ] Datos pre-cargados en el prototipo (`python manage.py seed_data`):
  - [ ] Al menos **1 evento archivado clonable** llamado *"Diplomado en Comercio Internacional"* (Escenario A).
  - [ ] Categorías activas disponibles: **Diplomado, Taller, Curso, Maestría** (al menos 3, requerido para Escenario B y NFR-OP-3).
  - [ ] Profesor existente: **Mtra. Ana María González Ruiz** (Escenario B) y **Dr. Roberto Hernández Sánchez** (Escenario A).
  - [ ] Ningún evento llamado *"Curso de Finanzas Personales para Profesionistas"* (para no bloquear el guardado en Escenario B).
  - [ ] Ninguna categoría llamada *"Seminario Internacional"* ni *"Seminario Empresarial Internacional"* (para no romper C1/C2).
- [ ] Confirmar datos fijos de los escenarios (ya están en la hoja de tareas, no modificar entre sesiones):
  - **Escenario A:** Fecha de inicio = 25-Mayo-2026 · Instructor = Dr. Roberto Hernández Sánchez.
  - **Escenario B:** Ficha técnica completa del *"Curso de Finanzas Personales para Profesionistas"* en `04-Hoja-Tareas-Participante.md`.
- [ ] Navegador en modo limpio (sin historial ni autocompletado del prototipo).
- [ ] Resolución 1920×1080 confirmada (para validar requisito de listado tabular).
- [ ] Cronómetro listo (solo visible para el facilitador).
- [ ] Software de grabación abierto y probado:
  - [ ] Captura de pantalla.
  - [ ] Captura de audio.
  - [ ] Espacio suficiente en disco.
- [ ] En remoto: liga estable, cámara y micrófono probados, función de compartir pantalla habilitada para el participante.

---

## Materiales impresos o digitales

- [ ] Guion del facilitador (`01`)
- [ ] Carta de consentimiento informado (`02`) — **dos copias** si es presencial (una para el participante, una para el equipo).
- [ ] Cuestionario pre-test (`03`)
- [ ] Hoja de tareas del participante (`04`)
- [ ] Encuesta SEQ post-tarea (`05`)
- [ ] Guion de entrevista post-test (`06`)
- [ ] Hoja de observación del facilitador (`07`) — **en blanco**, una por participante.
- [ ] Bolígrafo / dispositivo para registrar notas.

---

## Justo antes de iniciar (5 min antes)

- [ ] Cerrar todas las aplicaciones distractoras (chat, correo, notificaciones).
- [ ] Activar modo "no molestar" del sistema operativo.
- [ ] Verificar que el cronómetro está en cero.
- [ ] Verificar que la grabadora **NO** está grabando todavía (se inicia tras firmar consentimiento).
- [ ] Tener agua para el participante (sesión presencial).
- [ ] Respirar — y recordar: **silencio activo, no responder preguntas guía.**

---

## Inmediatamente después de la sesión

- [ ] Detener y guardar la grabación con nombre estándar: `P-XX_AAAA-MM-DD.mp4`.
- [ ] Completar las observaciones cualitativas pendientes en la hoja `07` (verbatims, momentos clave).
- [ ] Archivar el consentimiento firmado en carpeta segura.
- [ ] Resetear el prototipo a estado limpio para el siguiente participante:
  - [ ] Eliminar la nueva edición clonada del Diplomado (Escenario A).
  - [ ] Eliminar el evento *"Curso de Finanzas Personales para Profesionistas"* recién creado (Escenario B).
  - [ ] Eliminar la categoría creada o restaurarla si fue archivada (Escenario C).
  - [ ] Alternativa: re-ejecutar `python manage.py seed_data` para resetear todo de un golpe.
- [ ] Anotar cualquier incidencia técnica en la bitácora del estudio.

---

## Después de las 5 sesiones (análisis)

- [ ] Consolidar las 5 hojas `07` en una tabla resumen comparativa.
- [ ] Calcular medias y desviaciones de los tiempos.
- [ ] Calcular tasa de éxito agregada para Escenario C.
- [ ] Transcribir verbatims relevantes.
- [ ] Construir mapa de afinidad con los comentarios cualitativos.
- [ ] Generar el reporte final comparando cada métrica contra los umbrales NFR (Pass / Partial / Fail).
