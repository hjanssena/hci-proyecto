import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/debouncer.dart';
import '../../../models/events/payment.dart';
import '../../../viewmodels/events/payment_viewmodel.dart';
import '../../../views/widgets/status_badge.dart';
import '../../../views/widgets/confirmation_dialog.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final _debouncer = Debouncer();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentViewModel>().fetchPayments();
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
    final vm = context.watch<PaymentViewModel>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gestión de Pagos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Filters
          Row(
            children: [
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Buscar por nombre del participante...',
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
                  ...Payment.statusLabels.entries.map((e) =>
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
                : vm.payments.isEmpty
                    ? Center(
                        child: Text(
                          'No se encontraron pagos.',
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
                              DataColumn(label: Text('Participante', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Evento', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Monto', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                              DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Comprobante', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: vm.payments.map((pay) {
                              final canProcess = pay.status == 'PE';
                              return DataRow(cells: [
                                DataCell(Text(pay.applicantName)),
                                DataCell(Text(pay.eventName, overflow: TextOverflow.ellipsis)),
                                DataCell(Text('\$${pay.amount.toStringAsFixed(2)}')),
                                DataCell(StatusBadge(
                                  label: pay.statusDisplay,
                                  color: pay.statusColor,
                                  tooltip: pay.rejectionReason != null && pay.rejectionReason!.isNotEmpty
                                      ? 'Motivo: ${pay.rejectionReason}'
                                      : null,
                                )),
                                DataCell(
                                  pay.proofOfPaymentUrl != null
                                      ? IconButton(
                                          icon: const Icon(Icons.receipt_long, color: Colors.blue, size: 20),
                                          tooltip: 'Ver comprobante',
                                          onPressed: () => _showProofDialog(pay),
                                        )
                                      : const Text('-'),
                                ),
                                DataCell(Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (canProcess) ...[
                                      IconButton(
                                        icon: const Icon(Icons.check_circle, size: 20, color: Colors.green),
                                        tooltip: 'Confirmar pago',
                                        onPressed: () => _confirmPayment(pay),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, size: 20, color: Colors.red),
                                        tooltip: 'Rechazar pago',
                                        onPressed: () => _rejectPayment(pay),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.upload_file, size: 20, color: Colors.blue),
                                        tooltip: 'Solicitar comprobante',
                                        onPressed: () => _requestVoucher(pay),
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

  void _showProofDialog(Payment pay) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Comprobante de ${pay.applicantName}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: pay.proofOfPaymentUrl != null
              ? Column(
                  children: [
                    const Icon(Icons.receipt_long, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text('Archivo: ${pay.proofOfPaymentUrl!.split('/').last}'),
                    const SizedBox(height: 8),
                    Text('Monto: \$${pay.amount.toStringAsFixed(2)}'),
                    Text('Evento: ${pay.eventName}'),
                  ],
                )
              : const Center(child: Text('No se ha cargado comprobante.')),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Future<void> _confirmPayment(Payment pay) async {
    final confirmed = await showConfirmationDialog(context,
      title: 'Confirmar pago',
      message: '¿Confirmar el pago de \$${pay.amount.toStringAsFixed(2)} de "${pay.applicantName}"?',
      confirmLabel: 'Confirmar',
      confirmColor: Colors.green,
    );
    if (confirmed != null && context.mounted) {
      final error = await context.read<PaymentViewModel>().confirmPayment(pay.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _rejectPayment(Payment pay) async {
    final reason = await showConfirmationDialog(context,
      title: 'Rechazar pago',
      message: '¿Rechazar el pago de "${pay.applicantName}"?',
      confirmLabel: 'Rechazar',
      confirmColor: Colors.red,
      requireReason: true,
      reasonLabel: 'Motivo de rechazo',
    );
    if (reason != null && context.mounted) {
      final error = await context.read<PaymentViewModel>().rejectPayment(pay.id, reason);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _requestVoucher(Payment pay) async {
    final confirmed = await showConfirmationDialog(context,
      title: 'Solicitar comprobante',
      message: '¿Solicitar al participante "${pay.applicantName}" que cargue su comprobante de pago?',
      confirmLabel: 'Solicitar',
      confirmColor: Colors.blue,
    );
    if (confirmed != null && context.mounted) {
      final error = await context.read<PaymentViewModel>().requestVoucher(pay.id);
      if (error != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Se ha notificado al participante.'), backgroundColor: Colors.green),
        );
      }
    }
  }
}
