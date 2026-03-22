import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../viewmodels/events/attendance_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';
import '../../../views/widgets/info_tooltip.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  int? _selectedEventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceViewModel>().loadEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AttendanceViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Gestión de Asistencias', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const InfoTooltip(
                message: 'Seleccione un evento para descargar la plantilla de asistencia,\n'
                    'cargar el archivo completado (CSV o XLSX), o consultar los registros existentes.\n\n'
                    'Formato esperado: Columna "Participante" y columna "Asistio" (Si/No).',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Event selector + Actions
          Row(
            children: [
              SizedBox(
                width: 400,
                child: DropdownButtonFormField<int>(
                  value: _selectedEventId,
                  decoration: const InputDecoration(
                    labelText: 'Seleccionar evento',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: vm.events.map((e) =>
                    DropdownMenuItem(value: e.id, child: Text(e.name, overflow: TextOverflow.ellipsis)),
                  ).toList(),
                  onChanged: (v) {
                    setState(() => _selectedEventId = v);
                    if (v != null) vm.fetchRecords(v);
                  },
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: _selectedEventId == null ? null : () => _downloadTemplate(vm),
                icon: const Icon(Icons.download),
                label: const Text('Descargar plantilla'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _selectedEventId == null || vm.isUploading ? null : () => _uploadFile(vm),
                icon: vm.isUploading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.upload_file),
                label: const Text('Cargar asistencias'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002E5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Messages
          if (vm.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
              child: Text(vm.errorMessage!, style: TextStyle(color: Colors.red.shade700)),
            ),
          if (vm.successMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
              child: Text(vm.successMessage!, style: TextStyle(color: Colors.green.shade700)),
            ),

          const SizedBox(height: 8),

          // Records table
          Expanded(
            child: _selectedEventId == null
                ? Center(
                    child: Text(
                      'Seleccione un evento para ver los registros de asistencia.',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    ),
                  )
                : vm.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : vm.records.isEmpty
                        ? Center(
                            child: Text(
                              'No se han cargado registros de asistencia para este evento.',
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
                                columns: const [
                                  DataColumn(label: Text('Participante', style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text('Asistió', style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: vm.records.map((r) {
                                  return DataRow(cells: [
                                    DataCell(Text(r.participantName)),
                                    DataCell(StatusBadge(
                                      label: r.attended ? 'Sí' : 'No',
                                      color: r.attended ? Colors.green : Colors.red,
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

  Future<void> _downloadTemplate(AttendanceViewModel vm) async {
    final bytes = await vm.downloadTemplate(_selectedEventId!);
    if (bytes != null) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', 'Plantilla_Asistencia_Evento_$_selectedEventId.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<void> _uploadFile(AttendanceViewModel vm) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      await vm.uploadAttendance(_selectedEventId!, file.bytes!.toList(), file.name);
    }
  }
}
