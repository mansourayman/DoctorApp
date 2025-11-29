import 'package:intl/intl.dart';

String formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  } catch (e) {
    return iso;
  }
}
