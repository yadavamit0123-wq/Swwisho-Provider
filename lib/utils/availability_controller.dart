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
    DateTime offlineTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(offlineAt);
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

  void dispose() {
    _timer.cancel();
    remainingTimeNotifier.dispose();
  }
}
