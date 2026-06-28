import 'package:flutter/material.dart';

class TimeRangeEntry {
  TimeOfDay start;
  TimeOfDay end;

  TimeRangeEntry({required this.start, required this.end});

  factory TimeRangeEntry.defaultRange() => TimeRangeEntry(
    start: const TimeOfDay(hour: 9, minute: 0),
    end: const TimeOfDay(hour: 18, minute: 0),
  );
}

class DaySchedule {
  final String shortLabel;
  final String fullName;
  bool isOpen;
  List<TimeRangeEntry> ranges;

  DaySchedule({
    required this.shortLabel,
    required this.fullName,
    this.isOpen = true,
    List<TimeRangeEntry>? ranges,
  }) : ranges = ranges ?? [TimeRangeEntry.defaultRange()];
}

class OperatingHoursSelector extends StatefulWidget {
  final ValueChanged<List<DaySchedule>>? onChanged;
  final bool singleDay;
  final bool singleRange;

  const OperatingHoursSelector({
    super.key,
    this.onChanged,
    this.singleDay = false,
    this.singleRange = false,
  });

  @override
  State<OperatingHoursSelector> createState() => _OperatingHoursSelectorState();
}

class _OperatingHoursSelectorState extends State<OperatingHoursSelector> {
  late final List<DaySchedule> _days;

  DaySchedule? _expandedDay;

  @override
  void initState() {
    super.initState();
    _days = [
      DaySchedule(shortLabel: 'L', fullName: 'Lunes', isOpen: false),
      DaySchedule(shortLabel: 'M', fullName: 'Martes', isOpen: false),
      DaySchedule(shortLabel: 'M', fullName: 'Miércoles', isOpen: false),
      DaySchedule(shortLabel: 'J', fullName: 'Jueves', isOpen: false),
      DaySchedule(shortLabel: 'V', fullName: 'Viernes', isOpen: false),
      DaySchedule(shortLabel: 'S', fullName: 'Sábado', isOpen: false),
      DaySchedule(shortLabel: 'D', fullName: 'Domingo', isOpen: false),
    ];

    _expandedDay = null;
  }

  void _notify() => widget.onChanged?.call(_days);

  void _toggleDay(DaySchedule day) {
    setState(() {
      if (widget.singleDay) {
        for (final d in _days) {
          d.isOpen = d == day ? !d.isOpen : false;
        }
      } else {
        day.isOpen = !day.isOpen;
      }
      if (day.isOpen) {
        _expandedDay = day;
      } else if (_expandedDay == day) {
        _expandedDay = null;
      }
    });
    _notify();
  }

  Future<void> _pickTime(TimeRangeEntry range, bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? range.start : range.end,
    );
    if (picked == null || !mounted) return;

    final startMinutes = isStart
        ? picked.hour * 60 + picked.minute
        : range.start.hour * 60 + range.start.minute;
    final endMinutes = isStart
        ? range.end.hour * 60 + range.end.minute
        : picked.hour * 60 + picked.minute;

    if (isStart && startMinutes >= endMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de inicio debe ser menor a la de cierre'),
        ),
      );
      return;
    }

    if (!isStart && endMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de cierre debe ser mayor a la de inicio'),
        ),
      );
      return;
    }

    setState(() {
      if (isStart) {
        range.start = picked;
      } else {
        range.end = picked;
      }
    });
    _notify();
  }

  String _summary(DaySchedule day) {
    if (day.ranges.isEmpty) return '';
    if (day.ranges.length == 1) {
      final r = day.ranges.first;
      return '${r.start.format(context)} - ${r.end.format(context)}';
    }
    return '${day.ranges.length} horarios';
  }

  @override
  Widget build(BuildContext context) {
    final openDays = _days.where((d) => d.isOpen).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 6.0;
            final pillSize =
                ((constraints.maxWidth - gap * (_days.length - 1)) /
                        _days.length)
                    .clamp(34.0, 48.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [for (final day in _days) _dayPill(day, pillSize)],
            );
          },
        ),

        const SizedBox(height: 16),

        if (openDays.isEmpty)
          Text(
            'Selecciona al menos un día de atención.',
            style: Theme.of(context).textTheme.bodySmall,
          ),

        for (final day in openDays) _dayAccordion(day),
      ],
    );
  }

  Widget _dayPill(DaySchedule day, double size) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: () => _toggleDay(day),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: day.isOpen
              ? colors.primary
              : colors.error.withValues(alpha: 0.08),
          border: day.isOpen
              ? null
              : Border.all(color: colors.error, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          day.shortLabel,
          style: textTheme.bodyMedium?.copyWith(
            color: day.isOpen ? colors.onPrimary : colors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _dayAccordion(DaySchedule day) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isExpanded = _expandedDay == day;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expandedDay = isExpanded ? null : day),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Text(
                    day.fullName,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (!isExpanded)
                    Flexible(
                      child: Text(
                        _summary(day),
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),

          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int i = 0; i < day.ranges.length; i++)
                    _rangeRow(day, day.ranges[i], i),
                  if (!widget.singleRange)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(
                            () => day.ranges.add(TimeRangeEntry.defaultRange()),
                          );
                          _notify();
                        },
                        icon: Icon(Icons.add, size: 16, color: colors.primary),
                        label: Text(
                          'Agregar otro horario',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _rangeRow(DaySchedule day, TimeRangeEntry range, int index) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: _timeField(range.start, () => _pickTime(range, true)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('a', style: textTheme.bodySmall),
          ),
          Expanded(child: _timeField(range.end, () => _pickTime(range, false))),
          if (day.ranges.length > 1)
            IconButton(
              onPressed: () {
                setState(() => day.ranges.removeAt(index));
                _notify();
              },
              icon: Icon(Icons.close, size: 18, color: colors.error),
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.only(left: 8),
            ),
        ],
      ),
    );
  }

  Widget _timeField(TimeOfDay time, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(time.format(context), style: textTheme.bodySmall),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
