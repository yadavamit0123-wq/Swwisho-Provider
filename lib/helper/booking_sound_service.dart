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
        if (Get.isRegistered<BookingRequestController>()) {
          Get.find<BookingRequestController>().syncPendingAlerts();
        }
      } catch (_) {}
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
      // Stop only when a booking leaves the pending set (accept/ignore/etc.),
      // not when the API briefly returns empty while FCM already alerted.
      final removedFromPending = _knownPendingIds.difference(incoming);
      for (final id in removedFromPending) {
        stopAlert(bookingId: id);
      }
    } else {
      for (final id in incoming) {
        playBookingAlert(id);
      }
    }

    _pendingSnapshotReady = true;
    _knownPendingIds = incoming;
  }

  static bool isBookingNotification(String? type) {
    final normalized = (type ?? '').toLowerCase().trim();
    return normalized == 'booking' ||
        normalized == 'servicerequest' ||
        normalized == 'service_request' ||
        normalized == 'new_booking' ||
        normalized == 'booking_request' ||
        normalized == 'new_booking_request' ||
        normalized == 'provider_booking';
  }

  static String? extractBookingId(Map<String, dynamic> data) {
    for (final key in const [
      'booking_id',
      'bookingId',
      'id',
      'readable_id',
      'readableId',
      'reference_id',
      'referenceId',
    ]) {
      final raw = data[key]?.toString();
      if (raw != null && raw.isNotEmpty && raw != 'null') {
        return raw;
      }
    }
    return null;
  }

  /// Booking alert sound (Settings toggle). Independent of per-type push setup.
  static Future<void> playBookingAlertFromMessage(Map<String, dynamic> data) async {
    final bookingId = extractBookingId(data);
    if (bookingId != null && bookingId.isNotEmpty) {
      await playBookingAlert(bookingId);
      return;
    }
    if (!_isNotificationSoundEnabled()) return;
    try {
      _player ??= AudioPlayer();
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.stop();
      await _player!.play(AssetSource(AppAudios.requestSound));
      startWatchingPending();
    } catch (_) {
      try {
        await AudioPlayer().play(AssetSource(AppAudios.requestSound));
      } catch (_) {}
    }
  }
}
