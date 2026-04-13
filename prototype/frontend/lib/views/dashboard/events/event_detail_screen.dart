import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/events/event.dart';
import '../../../viewmodels/events/event_list_viewmodel.dart';
import '../../../viewmodels/events/event_form_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';
import '../../../views/widgets/confirmation_dialog.dart';

class EventDetailScreen extends StatefulWidget {
  final int eventId;
  final VoidCallback onBack;
  final void Function(int) onEdit;

  const EventDetailScreen({
    super.key,
    required this.eventId,
    required this.onBack,
    required this.onEdit,
  });

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Event? _event;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    final vm = context.read<EventFormViewModel>();
    await vm.loadEventForEdit(widget.eventId);
    if (mounted) {
      setState(() {
        _event = vm.editingEvent;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_event == null) return const Center(child: Text('Evento no encontrado'));

    final e = _event!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(e.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              StatusBadge(label: e.statusDisplay, color: e.statusColor),
            ],
          ),
          const SizedBox(height: 24),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info grid
                  _buildInfoGrid(e),
                  const SizedBox(height: 24),

                  // Schedules
                  if (e.schedules.isNotEmpty) ...[
                    const Text('Horario semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...e.schedules.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, size: 18, color: Colors.blueGrey),
                          const SizedBox(width: 8),
                          SizedBox(width: 100, child: Text(s.dayLabel, style: const TextStyle(fontWeight: FontWeight.w600))),
                          Text('${s.startTime} - ${s.endTime}'),
                        ],
                      ),
                    )),
                    const SizedBox(height: 24),
                  ],

                  // Professors
                  if (e.professors.isNotEmpty) ...[
                    const Text('Profesores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...e.professors.map((ep) => ListTile(
                      leading: const Icon(Icons.school),
                      title: Text(ep.professor.name),
                      subtitle: Text(ep.professor.email),
                      trailing: Text('${ep.hours} horas'),
                      dense: true,
                    )),
                    const SizedBox(height: 24),
                  ],

                  // Cancellation info
                  if (e.status == 'CA' && e.cancellationReason != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Motivo de cancelación', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          const SizedBox(height: 4),
                          Text(e.cancellationReason!),
                          if (e.cancellationDate != null) ...[
                            const SizedBox(height: 4),
                            Text('Fecha: ${e.cancellationDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Actions
                  Row(
                    children: [
                      if (e.status != 'AR' && e.status != 'CA')
                        ElevatedButton.icon(
                          onPressed: () => widget.onEdit(widget.eventId),
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002E5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (e.status != 'AR' && e.status != 'CA')
                        OutlinedButton.icon(
                          onPressed: () => _archiveEvent(e),
                          icon: const Icon(Icons.archive, color: Colors.orange),
                          label: const Text('Archivar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: const BorderSide(color: Colors.orange),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ),
                      const SizedBox(width: 12),
                      if (e.status == 'IN' || e.status == 'CO')
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          onPressed: () => _cancelEvent(e),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar evento'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(Event e) {
    return Wrap(
      spacing: 32,
      runSpacing: 16,
      children: [
        _infoItem('Categoría', e.categoryName ?? ''),
        _infoItem('Modalidad', e.modalityDisplay),
        _infoItem('Fecha de inicio', e.startDate),
        _infoItem('Fecha de fin', e.endDate),
        _infoItem('Duración', '${e.durationHours} horas'),
        _infoItem('Ubicación/Enlace', e.locationOrLink),
        _infoItem('Capacidad máxima', e.maxCapacity.toString()),
        _infoItem('Mínimo inscripciones', e.minInscriptions.toString()),
        _infoItem('Precio', '\$${e.price.toStringAsFixed(2)}'),
        _infoItem('Puntos EPC', e.epcPoints ? 'Sí' : 'No'),
        _infoItem('Por contrato', e.byContract ? 'Sí' : 'No'),
        if (e.withOrganization != null && e.withOrganization!.isNotEmpty)
          _infoItem('Organización', e.withOrganization!),
        _infoItem('Requisitos de acreditación', e.accreditationRequirements),
      ],
    );
  }

  Widget _infoItem(String label, String value) {
    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Future<void> _archiveEvent(Event event) async {
    final result = await showConfirmationDialog(context,
      title: 'Archivar evento',
      message: '¿Está segura de archivar este evento?',
      confirmLabel: 'Archivar',
      confirmColor: Colors.orange,
    );
    if (result != null && context.mounted) {
      final error = await context.read<EventListViewModel>().archiveEvent(event.id!);
      if (context.mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        } else {
          widget.onBack();
        }
      }
    }
  }

  Future<void> _cancelEvent(Event event) async {
    final reason = await showConfirmationDialog(context,
      title: 'Cancelar evento',
      message: '¿Está segura de cancelar este evento?',
      confirmLabel: 'Cancelar evento',
      confirmColor: Colors.red,
      requireReason: true,
      reasonLabel: 'Motivo de cancelación',
    );
    if (reason != null && context.mounted) {
      final error = await context.read<EventListViewModel>().cancelEvent(event.id!, reason);
      if (context.mounted) {
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        } else {
          widget.onBack();
        }
      }
    }
  }
}
