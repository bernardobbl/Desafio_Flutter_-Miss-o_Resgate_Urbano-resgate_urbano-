import 'package:intl/intl.dart';

class AppDateUtils {
  static final _dateFormatter = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  static String formatDate(DateTime dt) => _dateFormatter.format(dt);
  static String formatDateTime(DateTime dt) => _dateTimeFormatter.format(dt);

  static String tempoDecorrido(DateTime criacao) {
    final diff = DateTime.now().difference(criacao);
    if (diff.inSeconds < 60) return 'agora mesmo';
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes}min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'há 1 dia';
    if (diff.inDays < 30) return 'há ${diff.inDays} dias';
    if (diff.inDays < 365) return 'há ${(diff.inDays / 30).floor()} meses';
    return 'há ${(diff.inDays / 365).floor()} anos';
  }
}
