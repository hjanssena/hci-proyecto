import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/debouncer.dart';
import '../../../models/events/event.dart';
import '../../../viewmodels/events/event_list_viewmodel.dart';
import '../../../viewmodels/events/event_form_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';
import '../../../views/widgets/confirmation_dialog.dart';
import 'event_form_screen.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _debouncer = Debouncer();
  final _searchController = TextEditingController();

  // Sub-navigation state
  String? _subView; // null=list, 'create', 'edit', 'clone', 'detail'
  int? _selectedEventId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventListViewModel>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToList() {
    setState(() {
      _subView = null;
      _selectedEventId = null;
    });
    context.read<EventFormViewModel>().reset();
    context.read<EventListViewModel>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    if (_subView == 'create' || _subView == 'edit' || _subView == 'clone') {
      return EventFormScreen(
        mode: _subView!,
        eventId: _selectedEventId,
        onBack: _navigateToList,
      );
    }
    if (_subView == 'detail') {
      return EventDetailScreen(
        eventId: _selectedEventId!,
        onBack: _navigateToList,
        onEdit: (id) => setState(() { _subView = 'edit'; _selectedEventId = id; }),
      );
    }

    return _buildListView();
  }

  Widget _buildListView() {
    final vm = context.watch<EventListViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('Gestión de Eventos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: () => _showCloneDialog(context),
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Clonar evento'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFC79316),
                  side: const BorderSide(color: Color(0xFFC79316), width: 1.5),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => setState(() => _subView = 'create'),
                icon: const Icon(Icons.add),
                label: const Text('Crear evento'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002E5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search & Filters
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onChanged: (value) => _debouncer.call(() => vm.setSearch(value)),
                ),
              ),
              const SizedBox(width: 16),
              DropdownButton<String?>(
                value: vm.statusFilter,
                hint: const Text('Estado'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos')),
                  ...Event.statusLabels.entries.map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ),
                ],
                onChanged: vm.setStatusFilter,
              ),
              const SizedBox(width: 16),
              DropdownButton<String?>(
                value: vm.modalityFilter,
                hint: const Text('Modalidad'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas')),
                  ...Event.modalityLabels.entries.map((e) =>
                    DropdownMenuItem(value: e.key, child: Text(e.value)),
                  ),
                ],
                onChanged: vm.setModalityFilter,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.events.isEmpty
                    ? Center(
                        child: Text(
                          vm.searchQuery.isNotEmpty
                              ? 'No se encontraron eventos que coincidan con la búsqueda.'
                              : 'No existen eventos registrados actualmente.',
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
                              DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Motivo', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Modalidad', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: vm.events.map((event) {
                              return DataRow(cells: [
                                DataCell(
                                  Text(event.name, overflow: TextOverflow.ellipsis),
                                  onTap: () => setState(() { _subView = 'detail'; _selectedEventId = event.id; }),
                                ),
                                DataCell(Text(event.categoryName ?? '')),
                                DataCell(StatusBadge(label: event.statusDisplay, color: event.statusColor)),
                                DataCell(
                                  event.cancellationReason != null && event.cancellationReason!.isNotEmpty
                                      ? ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 200),
                                          child: Text(event.cancellationReason!, overflow: TextOverflow.ellipsis, maxLines: 2, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
                                        )
                                      : const Text('-', style: TextStyle(color: Colors.grey)),
                                ),
                                DataCell(Text(event.modalityDisplay)),
                                DataCell(Text(event.startDate)),
                                DataCell(Text('\$${event.price.toStringAsFixed(2)}')),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility, size: 20),
                                      tooltip: 'Ver detalle',
                                      onPressed: () => setState(() { _subView = 'detail'; _selectedEventId = event.id; }),
                                    ),
                                    if (event.status != 'AR' && event.status != 'CA')
                                      IconButton(
                                        icon: const Icon(Icons.edit, size: 20),
                                        tooltip: 'Editar',
                                        onPressed: () => setState(() { _subView = 'edit'; _selectedEventId = event.id; }),
                                      ),
                                    if (event.status != 'AR' && event.status != 'CA')
                                      IconButton(
                                        icon: const Icon(Icons.archive, size: 20, color: Colors.orange),
                                        tooltip: 'Archivar',
                                        onPressed: () => _archiveEvent(event),
                                      ),
                                    if (event.status == 'IN' || event.status == 'CO')
                                      IconButton(
                                        icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                        tooltip: 'Cancelar',
                                        onPressed: () => _cancelEvent(event),
                                      ),
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

  Future<void> _archiveEvent(Event event) async {
    final result = await showConfirmationDialog(
      context,
      title: 'Archivar evento',
      message: '¿Está segura de archivar el evento "${event.name}"?\n\n'
          'Si el evento tiene inscripciones activas, será cancelado automáticamente.',
      confirmLabel: 'Archivar',
      confirmColor: Colors.orange,
    );
    if (result != null && context.mounted) {
      final error = await context.read<EventListViewModel>().archiveEvent(event.id!);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _cancelEvent(Event event) async {
    final reason = await showConfirmationDialog(
      context,
      title: 'Cancelar evento',
      message: '¿Está segura de cancelar el evento "${event.name}"?\n\n'
          'Se notificará a los participantes inscritos.',
      confirmLabel: 'Cancelar evento',
      confirmColor: Colors.red,
      requireReason: true,
      reasonLabel: 'Motivo de cancelación',
    );
    if (reason != null && context.mounted) {
      final error = await context.read<EventListViewModel>().cancelEvent(event.id!, reason);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showCloneDialog(BuildContext context) async {
    final vm = context.read<EventListViewModel>();
    // Ensure events are loaded
    if (vm.events.isEmpty) await vm.fetchEvents();

    if (!context.mounted) return;

    final selectedId = await showDialog<int>(
      context: context,
      builder: (ctx) {
        String searchText = '';
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final filtered = vm.events.where((e) =>
              e.name.toLowerCase().contains(searchText.toLowerCase())
            ).toList();

            return AlertDialog(
              title: const Text('Clonar evento existente'),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Buscar evento...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (v) => setDialogState(() => searchText = v),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final event = filtered[i];
                          return ListTile(
                            title: Text(event.name),
                            subtitle: Text('${event.categoryName ?? ''} · ${event.statusDisplay}'),
                            trailing: StatusBadge(label: event.modalityDisplay, color: const Color(0xFF002E5F)),
                            onTap: () => Navigator.pop(ctx, event.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              ],
            );
          },
        );
      },
    );

    if (selectedId != null) {
      setState(() {
        _subView = 'clone';
        _selectedEventId = selectedId;
      });
    }
  }
}
