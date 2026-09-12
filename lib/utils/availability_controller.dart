import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AvailabilityController {
  final String offlineAt;
  final ValueNotifier<String> remainingTimeNotifier = ValueNotifier('');
  bool availableForOnline = false;

  late Timer _timer;

  AvailabilityController({required this.offlineAt}) {
    _startCountdown();
  }

  void _startCountdown() {
    DateTime offlineTime = _parseOfflineTime(offlineAt);
    DateTime allowedOnlineTime = offlineTime.add(const Duration(hours: 4));

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();

      if (now.isAfter(allowedOnlineTime)) {
        availableForOnline = true;
        remainingTimeNotifier.value = 'Now you can go';
        timer.cancel();
      } else {
        availableForOnline = false;
        final remaining = allowedOnlineTime.difference(now);
        final hours = remaining.inHours.toString().padLeft(2, '0');
        final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

        remainingTimeNotifier.value = '$hours:$minutes:$seconds';
      }
    });
  }

  DateTime _parseOfflineTime(String value) {
    final trimmed = value.trim();
    final formats = [
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS'),
    ];
    for (final format in formats) {
      try {
        return format.parse(trimmed);
      } catch (_) {}
    }
    try {
      return DateTime.parse(trimmed);
    } catch (_) {
      return DateTime.now().subtract(const Duration(hours: 24));
    }
  }

  void dispose() {
    _timer.cancel();
    remainingTimeNotifier.dispose();
  }
}
