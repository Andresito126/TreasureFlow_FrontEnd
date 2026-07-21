import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

enum PostponeReason {
  citizenAbsent('El ciudadano no se encontraba'),
  cannotAccess('No se pudo acceder al domicilio'),
  materialNotReady('El material no estaba listo'),
  vehicleIssue('Problema con el vehículo'),
  outOfTime('Se acabó el tiempo de la jornada'),
  other('Otro');

  final String label;
  const PostponeReason(this.label);
}

class PostponeResult {
  final String reason;
  final DateTime newDate;
  const PostponeResult({required this.reason, required this.newDate});
}

Future<PostponeResult?> showPostponeReasonSheet(BuildContext context) {
  return showModalBottomSheet<PostponeResult>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _PostponeReasonSheet(),
  );
}

class _PostponeReasonSheet extends StatefulWidget {
  const _PostponeReasonSheet();

  @override
  State<_PostponeReasonSheet> createState() => _PostponeReasonSheetState();
}

class _PostponeReasonSheetState extends State<_PostponeReasonSheet> {
  PostponeReason? _selected;
  DateTime? _newDate;
  final _otherController = TextEditingController();

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  bool get _reasonReady {
    if (_selected == null) return false;
    if (_selected == PostponeReason.other) {
      return _otherController.text.trim().isNotEmpty;
    }
    return true;
  }

  bool get _canConfirm => _reasonReady && _newDate != null;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: tomorrow,
      firstDate: tomorrow,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Nueva fecha de recolección',
    );
    if (picked != null) setState(() => _newDate = picked);
  }

  void _confirm() {
    final reason = _selected == PostponeReason.other
        ? _otherController.text.trim()
        : _selected!.label;
    Navigator.of(
      context,
    ).pop(PostponeResult(reason: reason, newDate: _newDate!));
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + bottomInset,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Posponer esta parada',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Elige el motivo y la nueva fecha. El ciudadano será notificado.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                'Motivo',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              RadioGroup<PostponeReason>(
                groupValue: _selected,
                onChanged: (value) => setState(() => _selected = value),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final reason in PostponeReason.values)
                      RadioListTile<PostponeReason>(
                        value: reason,
                        title: Text(reason.label, style: textTheme.bodyMedium),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                  ],
                ),
              ),
              if (_selected == PostponeReason.other) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _otherController,
                  maxLength: 200,
                  minLines: 2,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Describe el motivo…',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 8),

              Text(
                'Nueva fecha de recolección',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: colors.onSurface.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_rounded,
                        size: 18,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _newDate == null
                              ? 'Selecciona una fecha (a partir de mañana)'
                              : _formatDate(_newDate!),
                          style: textTheme.bodyMedium?.copyWith(
                            color: _newDate == null
                                ? colors.onSurface.withValues(alpha: 0.5)
                                : colors.onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryButtonGreenWidget(
                text: 'Posponer parada',
                onPressed: _canConfirm ? _confirm : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
