import 'date_only.dart';

String yyyymmdd(DateTime dt) {
  final d = dateOnly(dt);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}$mm$dd';
}
