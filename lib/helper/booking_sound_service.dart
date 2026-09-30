import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/feature/auth/controller/auth_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:demandium_provider/feature/notifications/repository/local_notification_inbox.dart';
import 'package:demandium_provider/utils/app_audios.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class BookingSoundService {
  static AudioPlayer? _player;
  static final Set<String> _activeBookingIds = {};
  static Timer? _pollTimer;

  static bool get isPlaying => _activeBookingIds.isNotEmpty;

  static bool _isNotificationSoundEnabled() {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().isNotificationActive();
      }
    } catch (_) {}
    return true;
  }

  static void startWatchingPending() {
    if (_pollTimer != null && _pollTimer!.isActive) return;
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (Get.isRegistered<BookingRequestController>()) {
        Get.find<BookingRequestController>().syncPendingAlerts();
      }
    });
  }

  static Future<void> playBookingAlert(String bookingId) async {
    if (bookingId.isEmpty) {
      return;
    }

    _activeBookingIds.add(bookingId);

    try {
      if (_isNotificationSoundEnabled()) {
        _player ??= AudioPlayer();
        await _player!.setReleaseMode(ReleaseMode.loop);
        await _player!.setVolume(1.0);
        await _player!.stop();
        await _player!.play(AssetSource(AppAudios.requestSound));
      } else {
        try {
          await _player?.stop();
        } catch (_) {}
      }
      startWatchingPending();
      try {
        await LocalNotificationInbox.addSimple(
          id: 'booking_$bookingId',
          title: 'New booking',
          body: 'You have a new booking request',
        );
      } catch (_) {}
    } catch (e) {
      // Fallback to a one-shot player if loop player fails.
      try {
        if (_isNotificationSoundEnabled()) {
          await AudioPlayer().play(AssetSource(AppAudios.requestSound));
        }
      } catch (_) {
        if (kDebugMode) {
          print('BookingSoundService.playBookingAlert: $e');
        }
      }
    }
  }

  static Future<void> stopAlert({String? bookingId}) async {
    if (bookingId != null && bookingId.isNotEmpty) {
      _activeBookingIds.remove(bookingId);
    } else {
      _activeBookingIds.clear();
    }

    if (_activeBookingIds.isEmpty) {
      try {
        await _player?.stop();
      } catch (_) {}
    }
  }

  static Set<String> _knownPendingIds = {};
  static bool _pendingSnapshotReady = false;

  static void onPendingListUpdated(List<String> pendingBookingIds) {
    final incoming = pendingBookingIds.where((id) => id.isNotEmpty).toSet();
    if (_pendingSnapshotReady) {
      final newIds = incoming.difference(_knownPendingIds);
      for (final id in newIds) {
        playBookingAlert(id);
      }
    }
    _pendingSnapshotReady = true;
    _knownPendingIds = incoming;

    if (_activeBookingIds.isEmpty) {
      return;
    }

    _activeBookingIds.removeWhere((id) => !pendingBookingIds.contains(id));
    if (_activeBookingIds.isEmpty) {
      stopAlert();
    }
  }

  static bool isBookingNotification(String? type) {
    final normalized = (type ?? '').toLowerCase().trim();
    return normalized == 'booking' ||
        normalized == 'servicerequest' ||
        normalized == 'service_request' ||
        normalized == 'new_booking' ||
        normalized == 'booking_request';
  }

  static String? extractBookingId(Map<String, dynamic> data) {
    final id = data['booking_id']?.toString() ??
        data['bookingId']?.toString() ??
        data['id']?.toString();
    if (id == null || id.isEmpty || id == 'null') {
      return null;
    }
    return id;
  }
}
