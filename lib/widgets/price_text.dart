import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceText extends StatelessWidget {
  final String? price;
  final TextStyle? style;
  final String currencySuffix;
  final String? placeholder;

  const PriceText({
    super.key,
    required this.price,
    this.style,
    this.currencySuffix = 'ج',
    this.placeholder,
  });

  static String formatPrice(dynamic value) {
    if (value == null) return '0';
    num? n;
    if (value is num) {
      n = value;
    } else {
      final s = value.toString().trim();
      if (s.isEmpty) return '0';
      var normalized = s.replaceAll(RegExp(r'[^0-9.,]'), '');
      if (normalized.isEmpty) return '0';
      if (normalized.contains('.') && normalized.contains(',')) {
        normalized = normalized.replaceAll(',', '');
      } else if (normalized.contains(',') && !normalized.contains('.')) {
        normalized = normalized.replaceAll(',', '.');
      }
      final d = double.tryParse(normalized);
      if (d != null) {
        n = d;
      } else {
        final digits = normalized.replaceAll(RegExp(r'[^0-9]'), '');
        n = int.tryParse(digits) ?? 0;
      }
    }
    if (n is int || n % 1 == 0) {
      return NumberFormat.decimalPattern().format(n.toInt());
    }
    return NumberFormat('#,##0.##').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final p = price ?? '';
    if (p.isEmpty) {
      if (placeholder != null) {
        return Text(placeholder!, style: style);
      } else {
        return Text('', style: style);
      }
    }
    final formatted = PriceText.formatPrice(p);
    return Text('$formatted $currencySuffix', style: style);
  }
}
