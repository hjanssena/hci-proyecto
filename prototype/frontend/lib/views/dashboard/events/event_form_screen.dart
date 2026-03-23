import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/events/event.dart';
import '../../../models/events/professor.dart';
import '../../../viewmodels/events/event_form_viewmodel.dart';
import '../../../views/widgets/info_tooltip.dart';

class EventFormScreen extends StatefulWidget {
  final String mode; // 'create', 'edit', 'clone'
  final int? eventId;
  final VoidCallback onBack;

  const EventFormScreen({
    super.key,
    required this.mode,
    this.eventId,
    required this.onBack,
  });

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _scheduleCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _maxCapCtrl = TextEditingController();
  final _minInsCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _accredCtrl = TextEditingController();
  final _orgCtrl = TextEditingController();

  int? _categoryId;
  String _modality = 'PR';
  bool _epcPoints = false;
  bool _byContract = false;
  DateTime? _startDate;
  DateTime? _endDate;
  List<_ProfessorEntry> _professors = [];

  bool _initialized = false;
  bool _submitted = false;
  String? _startDateError;
  String? _endDateError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<EventFormViewModel>();
      if (widget.mode == 'edit' && widget.eventId != null) {
        vm.loadEventForEdit(widget.eventId!);
      } else if (widget.mode == 'clone' && widget.eventId != null) {
        vm.loadEventForClone(widget.eventId!);
      } else {
        vm.loadFormData();
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _scheduleCtrl.dispose();
    _durationCtrl.dispose();
    _locationCtrl.dispose();
    _maxCapCtrl.dispose();
    _minInsCtrl.dispose();
    _priceCtrl.dispose();
    _accredCtrl.dispose();
    _orgCtrl.dispose();
    super.dispose();
  }

  void _validateDates() {
    setState(() {
      _startDateError = _submitted && _startDate == null
          ? 'Seleccione la fecha de inicio'
          : null;
      if (_endDate == null && _submitted) {
        _endDateError = 'Seleccione la fecha de fin';
      } else if (_startDate != null &&
          _endDate != null &&
          _endDate!.isBefore(_startDate!)) {
        _endDateError = 'La fecha de fin no puede ser anterior a la de inicio';
      } else {
        _endDateError = null;
      }
    });
  }

  void _populateFromEvent(Event event) {
    if (_initialized) return;
    _initialized = true;
    _nameCtrl.text = event.name;
    _descCtrl.text = event.description;
    _scheduleCtrl.text = event.schedule;
    _durationCtrl.text = event.durationHours.toString();
    _locationCtrl.text = event.locationOrLink;
    _maxCapCtrl.text = event.maxCapacity.toString();
    _minInsCtrl.text = event.minInscriptions.toString();
    _priceCtrl.text = event.price.toStringAsFixed(2);
    _accredCtrl.text = event.accreditationRequirements;
    _orgCtrl.text = event.withOrganization ?? '';
    _categoryId = event.categoryId;
    _modality = event.modality;
    _epcPoints = event.epcPoints;
    _byContract = event.byContract;
    _startDate = DateTime.tryParse(event.startDate);
    _endDate = DateTime.tryParse(event.endDate);
    _professors = event.professors
        .map((ep) => _ProfessorEntry(professor: ep.professor, hours: ep.hours))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventFormViewModel>();

    if (vm.state == EventFormState.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.editingEvent != null) {
      _populateFromEvent(vm.editingEvent!);
    }

    final isClone = widget.mode == 'clone';
    final title = widget.mode == 'create'
        ? 'Crear evento'
        : isClone
        ? 'Crear evento (clonado)'
        : 'Editar evento';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isClone) ...[
                const SizedBox(width: 12),
                const InfoTooltip(
                  message:
                      'Los campos han sido prellenados con los datos del evento original.\nModifique las fechas, profesores y demás datos variables.',
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          if (vm.errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vm.errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                autovalidateMode: _submitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Name + Category
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: _buildField(
                            controller: _nameCtrl,
                            label: 'Nombre del evento',
                            highlight: isClone,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'El nombre es obligatorio'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: _categoryId,
                            decoration: const InputDecoration(
                              labelText: 'Categoría',
                              border: OutlineInputBorder(),
                            ),
                            items: vm.categories
                                .map(
                                  (c) => DropdownMenuItem<int>(
                                    value: c.id,
                                    child: Text(c.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _categoryId = v),
                            validator: (v) =>
                                v == null ? 'Seleccione una categoría' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildField(
                      controller: _descCtrl,
                      label: 'Descripción',
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'La descripción es obligatoria'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Row 2: Dates
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildDateField(
                            'Fecha de inicio',
                            _startDate,
                            (d) {
                              setState(() => _startDate = d);
                              _validateDates();
                            },
                            highlight: isClone,
                            errorText: _startDateError,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateField(
                            'Fecha de fin',
                            _endDate,
                            (d) {
                              setState(() => _endDate = d);
                              _validateDates();
                            },
                            highlight: isClone,
                            errorText: _endDateError,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            controller: _scheduleCtrl,
                            label: 'Horario',
                            hint: 'Ej: Lunes a Viernes 18:00 - 20:00',
                            highlight: isClone,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'El horario es obligatorio'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 120,
                          child: _buildField(
                            controller: _durationCtrl,
                            label: 'Duración (hrs)',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Obligatorio';
                              final n = int.tryParse(v.trim());
                              if (n == null || n <= 0)
                                return 'Debe ser mayor a 0';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 3: Modality + Location
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: DropdownButtonFormField<String>(
                            initialValue: _modality,
                            decoration: const InputDecoration(
                              labelText: 'Modalidad',
                              border: OutlineInputBorder(),
                            ),
                            items: Event.modalityLabels.entries
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _modality = v ?? 'PR'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildField(
                            controller: _locationCtrl,
                            label: _modality == 'VI'
                                ? 'Enlace de acceso'
                                : 'Aula / Ubicación',
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Este campo es obligatorio'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 4: Capacity + Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 180,
                          child: _buildField(
                            controller: _maxCapCtrl,
                            label: 'Capacidad máxima',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Obligatorio';
                              final n = int.tryParse(v.trim());
                              if (n == null || n <= 0)
                                return 'Debe ser mayor a 0';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 180,
                          child: _buildField(
                            controller: _minInsCtrl,
                            label: 'Mínimo inscripciones',
                            keyboardType: TextInputType.number,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Obligatorio';
                              final n = int.tryParse(v.trim());
                              if (n == null || n <= 0)
                                return 'Debe ser mayor a 0';
                              final maxCap =
                                  int.tryParse(_maxCapCtrl.text.trim()) ?? 0;
                              if (maxCap > 0 && n > maxCap)
                                return 'No puede exceder la capacidad';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SizedBox(
                          width: 180,
                          child: _buildField(
                            controller: _priceCtrl,
                            label: 'Precio (\$)',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Obligatorio';
                              final n = double.tryParse(v.trim());
                              if (n == null || n < 0)
                                return 'Ingrese un monto válido';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 5: Booleans
                    Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: CheckboxListTile(
                            title: const Text('Puntos EPC'),
                            value: _epcPoints,
                            onChanged: (v) =>
                                setState(() => _epcPoints = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: CheckboxListTile(
                            title: const Text('Por contrato'),
                            value: _byContract,
                            onChanged: (v) =>
                                setState(() => _byContract = v ?? false),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        if (_byContract) ...[
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              controller: _orgCtrl,
                              label: 'Organización',
                              validator: (v) =>
                                  _byContract && (v == null || v.trim().isEmpty)
                                  ? 'La organización es obligatoria'
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Accreditation
                    _buildField(
                      controller: _accredCtrl,
                      label: 'Requisitos de acreditación',
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Este campo es obligatorio'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Professors section
                    Row(
                      children: [
                        const Text(
                          'Profesores',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const InfoTooltip(
                          message:
                              'Asigne uno o más profesores al evento con las horas correspondientes.',
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _professors.add(_ProfessorEntry()));
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar profesor'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._professors.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final prof = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: DropdownButtonFormField<int>(
                                initialValue: prof.professor?.id,
                                decoration: InputDecoration(
                                  labelText: 'Profesor ${idx + 1}',
                                  border: const OutlineInputBorder(),
                                  filled: isClone,
                                  fillColor: isClone
                                      ? Colors.yellow.shade50
                                      : null,
                                ),
                                items: vm.professors
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p.id,
                                        child: Text(p.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    prof.professor = vm.professors.firstWhere(
                                      (p) => p.id == v,
                                    );
                                  });
                                },
                                validator: (v) =>
                                    v == null ? 'Seleccione un profesor' : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 120,
                              child: TextFormField(
                                initialValue: prof.hours > 0
                                    ? prof.hours.toString()
                                    : '',
                                decoration: InputDecoration(
                                  labelText: 'Horas',
                                  border: const OutlineInputBorder(),
                                  filled: isClone,
                                  fillColor: isClone
                                      ? Colors.yellow.shade50
                                      : null,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (v) =>
                                    prof.hours = int.tryParse(v) ?? 0,
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty)
                                    return 'Obligatorio';
                                  final n = int.tryParse(v.trim());
                                  if (n == null || n <= 0)
                                    return 'Debe ser > 0';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  setState(() => _professors.removeAt(idx)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onBack,
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: vm.state == EventFormState.saving
                              ? null
                              : _saveEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF002E5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: vm.state == EventFormState.saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool highlight = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: highlight,
        fillColor: highlight ? Colors.yellow.shade50 : null,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? value,
    ValueChanged<DateTime> onChanged, {
    bool highlight = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) onChanged(date);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              enabledBorder: errorText != null
                  ? OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
              filled: highlight,
              fillColor: highlight ? Colors.yellow.shade50 : null,
            ),
            child: Text(
              value != null
                  ? '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}'
                  : 'Seleccionar fecha',
              style: TextStyle(
                color: value != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  void _saveEvent() {
    setState(() => _submitted = true);
    _validateDates();

    final formValid = _formKey.currentState!.validate();
    final datesValid =
        _startDateError == null &&
        _endDateError == null &&
        _startDate != null &&
        _endDate != null;

    if (!formValid || !datesValid) return;

    final data = {
      'name': _nameCtrl.text.trim(),
      'category': _categoryId,
      'description': _descCtrl.text.trim(),
      'start_date':
          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
      'end_date':
          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
      'schedule': _scheduleCtrl.text.trim(),
      'duration_hours': int.tryParse(_durationCtrl.text) ?? 0,
      'modality': _modality,
      'location_or_link': _locationCtrl.text.trim(),
      'max_capacity': int.tryParse(_maxCapCtrl.text.trim()) ?? 0,
      'min_inscriptions': int.tryParse(_minInsCtrl.text.trim()) ?? 0,
      'price': _priceCtrl.text.trim(),
      'epc_points': _epcPoints,
      'accreditation_requirements': _accredCtrl.text.trim(),
      'by_contract': _byContract,
      'with_organization': _byContract ? _orgCtrl.text.trim() : null,
      'professors_data': _professors
          .where((p) => p.professor != null && p.hours > 0)
          .map((p) => {'professor_id': p.professor!.id, 'hours': p.hours})
          .toList(),
    };

    final vm = context.read<EventFormViewModel>();
    final isEdit = widget.mode == 'edit';
    vm.saveEvent(data, eventId: isEdit ? widget.eventId : null).then((error) {
      if (error == null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Evento actualizado exitosamente'
                  : 'Evento creado exitosamente',
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onBack();
      }
    });
  }
}

class _ProfessorEntry {
  Professor? professor;
  int hours;
  _ProfessorEntry({this.professor, this.hours = 0});
}
