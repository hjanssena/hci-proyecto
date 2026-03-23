import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/debouncer.dart';
import '../../../models/events/enrollment.dart';
import '../../../viewmodels/events/enrollment_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';
import '../../../views/widgets/confirmation_dialog.dart';

class EnrollmentListScreen extends StatefulWidget {
  const EnrollmentListScreen({super.key});

  @override
  State<EnrollmentListScreen> createState() => _EnrollmentListScreenState();
}

class _EnrollmentListScreenState extends State<EnrollmentListScreen> {
  final _debouncer = Debouncer();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<EnrollmentViewModel>();
      vm.loadEvents();
      vm.fetchEnrollments();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EnrollmentViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestión de Inscripciones', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre del solicitante...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _debouncer.call(() => vm.setSearch(value)),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<int?>(
                value: vm.selectedEventId,
                hint: const Text('Filtrar por evento'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos los eventos')),
                  ...vm.events.map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis)),
                  ),
                ],
                onChanged: vm.setEventFilter,
              ),
              const SizedBox(width: 16),
              DropdownButton<String?>(
                value: vm.statusFilter,
                hint: const Text('Estado'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...Enrollment.statusLabels.entries.map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ),
                ],
                onChanged: vm.setStatusFilter,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.enrollments.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron solicitudes de inscripción.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                        ),
                      )
                    : SingleChildScrollView(
                        child: SizedBox(
                          width: double.infinity,
                          child: DataTable(
                            dataRowMinHeight: 36,
                            dataRowMaxHeight: 42,
                            headingRowHeight: 42,
                            columnSpacing: 24,
                            columns: const [
                              DataColumn(label: Text('Solicitante', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Evento', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Documentos', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: vm.enrollments.map((enr) {
                              final canProcess = enr.status == 'PE' || enr.status == 'IR';
                              return DataRow(cells: [
                                DataCell(Text(enr.applicantName)),
                                DataCell(Text(enr.eventName ?? 'Evento #${enr.eventId}')),
                                DataCell(StatusBadge(
                                  label: enr.statusDisplay,
                                  color: enr.statusColor,
                                  tooltip: enr.rejectionReason != null && enr.rejectionReason!.isNotEmpty
                                      ? 'Motivo: ${enr.rejectionReason}'
                                      : null,
                                )),
                                DataCell(
                                  enr.documentsUrl != null
                                      ? const Icon(Icons.description, color: Colors.blue, size: 20)
                                      : const Text('-'),
                                ),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canProcess) ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                        tooltip: 'Aprobar',
                                        onPressed: () => _approve(enr),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                        tooltip: 'Rechazar',
                                        onPressed: () => _reject(enr),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.help, size: 20, color: Colors.blue),
                                        tooltip: 'Solicitar información',
                                        onPressed: () => _requestInfo(enr),
                                      ),
                                    ],
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _approve(Enrollment enr) async {
    final confirmed = await showConfirmationDialog(context,
      title: 'Aprobar solicitud',
      message: '¿Aprobar la solicitud de "${enr.applicantName}"?',
      confirmLabel: 'Aprobar',
      confirmColor: Colors.green,
    );
    if (confirmed != null && context.mounted) {
      final error = await context.read<EnrollmentViewModel>().approveEnrollment(enr.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _reject(Enrollment enr) async {
    final reason = await showConfirmationDialog(context,
      title: 'Rechazar solicitud',
      message: '¿Rechazar la solicitud de "${enr.applicantName}"?',
      confirmLabel: 'Rechazar',
      confirmColor: Colors.red,
      requireReason: true,
      reasonLabel: 'Motivo de rechazo',
    );
    if (reason != null && context.mounted) {
      final error = await context.read<EnrollmentViewModel>().rejectEnrollment(enr.id, reason);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _requestInfo(Enrollment enr) async {
    final details = await showConfirmationDialog(context,
      title: 'Solicitar información',
      message: 'Indique la información requerida al solicitante "${enr.applicantName}":',
      confirmLabel: 'Solicitar',
      confirmColor: Colors.blue,
      requireReason: true,
      reasonLabel: 'Detalle de información requerida',
    );
    if (details != null && context.mounted) {
      final error = await context.read<EnrollmentViewModel>().requestInfo(enr.id, details);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }
}
