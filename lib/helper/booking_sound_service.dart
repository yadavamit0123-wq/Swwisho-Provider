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
  static DateTime? _lastImmediateSoundAt;
  static final Map<String, DateTime> _recentAlertByBookingId = {};

  static bool get isPlaying => _activeBookingIds.isNotEmpty;

  static bool _isNotificationSoundEnabled() {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().isNotificationActive();
      }
    } catch (_) {}
    return true;
  }

  /// Call on app launch — stop any loop and treat the next pending fetch as baseline (no replay).
  static Future<void> prepareForAppLaunch() async {
    await stopAlert();
    _pendingSnapshotReady = false;
    _knownPendingIds = {};
    _lastImmediateSoundAt = null;
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

  /// Start loop sound immediately (FCM path). Does not wait on API sync.
  static Future<void> startLoopSoundNow() async {
    if (!_isNotificationSoundEnabled()) return;
    _lastImmediateSoundAt = DateTime.now();
    try {
      _player ??= AudioPlayer();
      unawaited(_player!.stop());
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.play(AssetSource(AppAudios.requestSound));
    } catch (e) {
      try {
        await AudioPlayer().play(AssetSource(AppAudios.requestSound));
      } catch (_) {
        if (kDebugMode) {
          print('BookingSoundService.startLoopSoundNow: $e');
        }
      }
    }
  }

  static void _markRecentAlert(String bookingId) {
    if (bookingId.isEmpty) return;
    _recentAlertByBookingId[bookingId] = DateTime.now();
  }

  static bool _wasRecentlyAlerted(String bookingId) {
    final at = _recentAlertByBookingId[bookingId];
    if (at == null) return false;
    return DateTime.now().difference(at) < const Duration(seconds: 45);
  }

  static Future<void> playBookingAlert(String bookingId) async {
    if (bookingId.isEmpty) {
      return;
    }

    _activeBookingIds.add(bookingId);
    _markRecentAlert(bookingId);

    try {
      await startLoopSoundNow();
      if (!_isNotificationSoundEnabled()) {
        try {
          await _player?.stop();
        } catch (_) {}
      }
      startWatchingPending();
      unawaited(Future.microtask(() async {
        try {
          if (Get.isRegistered<BookingRequestController>()) {
            await Get.find<BookingRequestController>().syncPendingAlerts();
          }
        } catch (_) {}
        try {
          await LocalNotificationInbox.addSimple(
            id: 'booking_$bookingId',
            title: 'New booking',
            body: 'You have a new booking request',
          );
        } catch (_) {}
      }));
    } catch (e) {
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
        if (_wasRecentlyAlerted(id)) {
          _activeBookingIds.add(id);
          continue;
        }
        if (_lastImmediateSoundAt != null &&
            DateTime.now().difference(_lastImmediateSoundAt!) <
                const Duration(seconds: 40)) {
          _activeBookingIds.add(id);
          continue;
        }
        playBookingAlert(id);
      }
      // Stop only when a booking leaves the pending set (accept/ignore/etc.),
      // not when the API briefly returns empty while FCM already alerted.
      final removedFromPending = _knownPendingIds.difference(incoming);
      for (final id in removedFromPending) {
        stopAlert(bookingId: id);
      }
    } else {
      // Existing pendings on cold start / first fetch — track only, do not play sound.
      for (final id in incoming) {
        _markRecentAlert(id);
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

  static Map<String, dynamic> mergedPayload(Map<String, dynamic> data, {String? title, String? body}) {
    final merged = Map<String, dynamic>.from(data);
    if (title != null && title.isNotEmpty) {
      merged.putIfAbsent('title', () => title);
    }
    if (body != null && body.isNotEmpty) {
      merged.putIfAbsent('body', () => body);
    }
    return merged;
  }

  static bool looksLikeBookingMessage(Map<String, dynamic> data) {
    if (isBookingNotification(data['type']?.toString())) return true;
    if ((extractBookingId(data) ?? '').isNotEmpty) return true;
    final text =
        '${data['title'] ?? ''} ${data['body'] ?? ''} ${data['message'] ?? ''}'
            .toLowerCase();
    return text.contains('booking') ||
        text.contains('service request') ||
        text.contains('new request') ||
        text.contains('order request');
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
    _lastImmediateSoundAt = DateTime.now();
    await startLoopSoundNow();
    startWatchingPending();
  }
}
