import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'dart:ui' as ui;

class ContactLauncher {
  static String? _normalize(String? raw) {
    if (raw == null) return null;
    var s = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.isEmpty) return null;
    if (s.startsWith('00')) s = s.substring(2);
    if (s.startsWith('0') && !s.startsWith('20')) s = '20${s.substring(1)}';
    return s;
  }

  static Future<bool> openWhatsApp(
    BuildContext context, {
    String? phoneNumber,
    String? whatsappNumber,
    String message = 'مرحبا!',
  }) async {
    final chosen = whatsappNumber ?? phoneNumber;
    final normalized = _normalize(chosen);
    if (normalized == null || normalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: const Text('تعذر الحصول على رقم المعلن', textAlign: TextAlign.right),
          ),
        ),
      );
      return false;
    }
    final encodedText = Uri.encodeComponent(message);
    final deepNoPlus = Uri.parse('whatsapp://send?phone=$normalized&text=$encodedText');
    final deepPlus = Uri.parse('whatsapp://send?phone=%2B$normalized&text=$encodedText');
    final waUri = Uri.parse('https://wa.me/$normalized?text=$encodedText');
    final apiUri = Uri.parse('https://api.whatsapp.com/send?phone=$normalized&text=$encodedText');
    try {
      if (foundation.kIsWeb) {
        final ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
        final okWeb = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
        );
        if (!okWeb) throw Exception('no_handler');
        return okWeb;
      } else {
        var ok = await launchUrl(deepNoPlus, mode: LaunchMode.externalApplication);
        if (ok) return true;
        ok = await launchUrl(deepPlus, mode: LaunchMode.externalApplication);
        if (ok) return true;
        ok = await launchUrl(waUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
        ok = await launchUrl(apiUri, mode: LaunchMode.externalApplication);
        if (ok) return true;
        final okWebView = await launchUrl(
          apiUri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(enableJavaScript: true),
        );
        if (!okWebView) throw Exception('no_handler');
        return okWebView;
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: const Text('تعذر فتح واتساب', textAlign: TextAlign.right),
          ),
        ),
      );
      return false;
    }
  }

  static Future<bool> openPhone(
    BuildContext context, {
    String? phoneNumber,
    String? whatsappNumber,
  }) async {
    final chosen = phoneNumber ?? whatsappNumber;
    final normalized = _normalize(chosen);
    if (normalized == null || normalized.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: const Text('تعذر الحصول على رقم المعلن', textAlign: TextAlign.right),
          ),
        ),
      );
      return false;
    }
    final telUri = Uri.parse('tel:+$normalized');
    try {
      final ok = await launchUrl(telUri, mode: LaunchMode.externalApplication);
      return ok;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: ui.TextDirection.rtl,
            child: const Text('تعذر إجراء الاتصال', textAlign: TextAlign.right),
          ),
        ),
      );
      return false;
    }
  }
}

