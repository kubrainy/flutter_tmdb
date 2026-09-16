String formatDateTr(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  final parts = isoDate.split('-');
  if (parts.length != 3) return isoDate;
  final year = parts[0];
  final month = parts[1];
  final day = parts[2];
  return '$day.$month.$year';
}
