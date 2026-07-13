class AvailableSlot {
  final String date;
  final String dayLabel;
  final String start;
  final String end;
  final int slotsUsed;
  final int maxSlots;

  const AvailableSlot({
    required this.date,
    required this.dayLabel,
    required this.start,
    required this.end,
    required this.slotsUsed,
    required this.maxSlots,
  });

  bool get isFull => slotsUsed >= maxSlots;
}
