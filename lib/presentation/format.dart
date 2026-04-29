import 'package:intl/intl.dart';

final NumberFormat _brlCurrency = NumberFormat.simpleCurrency(locale: 'pt_BR');

String formatBrl(double value) => _brlCurrency.format(value);
