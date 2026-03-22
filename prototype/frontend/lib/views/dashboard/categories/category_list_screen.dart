import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/debouncer.dart';
import '../../../viewmodels/events/category_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  final _debouncer = Debouncer();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryViewModel>().fetchCategories();
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
    final vm = context.watch<CategoryViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text('Gestión de Categorías', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showCategoryDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Crear categoría'),
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

          // Search & Filter row
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
              DropdownButton<bool?>(
                value: vm.activeFilter,
                hint: const Text('Estado'),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Todas')),
                  DropdownMenuItem(value: true, child: Text('Activas')),
                  DropdownMenuItem(value: false, child: Text('Archivadas')),
                ],
                onChanged: vm.setActiveFilter,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : vm.categories.isEmpty
                    ? Center(
                        child: Text(
                          vm.searchQuery.isNotEmpty
                              ? 'No se encontraron categorías que coincidan con la búsqueda.'
                              : 'No existen categorías registradas actualmente.',
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
                              DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: vm.categories.map((cat) {
                              return DataRow(cells: [
                                DataCell(Text(cat.name)),
                                DataCell(StatusBadge(
                                  label: cat.isActive ? 'Activa' : 'Archivada',
                                  color: cat.isActive ? Colors.green : Colors.grey,
                                )),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      tooltip: 'Editar',
                                      onPressed: () => _showCategoryDialog(context, category: cat),
                                    ),
                                    if (cat.isActive)
                                      IconButton(
                                        icon: const Icon(Icons.archive, size: 20, color: Colors.orange),
                                        tooltip: 'Archivar',
                                        onPressed: () => _archiveCategory(context, cat),
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

  Future<void> _showCategoryDialog(BuildContext context, {dynamic category}) async {
    final nameController = TextEditingController(text: category?.name ?? '');
    bool isActive = category?.isActive ?? true;
    final formKey = GlobalKey<FormState>();
    String? dialogError;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(category == null ? 'Crear categoría' : 'Editar categoría'),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dialogError != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(dialogError!, style: TextStyle(color: Colors.red.shade700)),
                  ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la categoría',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'El nombre es obligatorio';
                    if (v.trim().length > 255) return 'El nombre no puede exceder 255 caracteres';
                    return null;
                  },
                ),
                if (category != null) ...[
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Activa'),
                    value: isActive,
                    onChanged: (v) => setDialogState(() => isActive = v),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002E5F),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final vm = context.read<CategoryViewModel>();
                String? error;
                if (category == null) {
                  error = await vm.createCategory(nameController.text.trim());
                } else {
                  error = await vm.updateCategory(
                    category.id,
                    name: nameController.text.trim(),
                    isActive: isActive,
                  );
                }
                if (error != null) {
                  setDialogState(() => dialogError = error);
                } else {
                  if (ctx.mounted) Navigator.pop(ctx);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _archiveCategory(BuildContext context, dynamic category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archivar categoría'),
        content: Text('¿Está segura de archivar la categoría "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Archivar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final error = await context.read<CategoryViewModel>().archiveCategory(category.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }
}
