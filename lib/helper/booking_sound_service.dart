import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:demandium_provider/utils/app_audios.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class BookingSoundService {
  static AudioPlayer? _player;
  static final Set<String> _activeBookingIds = {};
  static Timer? _pollTimer;

  static bool get isPlaying => _activeBookingIds.isNotEmpty;

  static Future<void> _configurePlayer() async {
    _player ??= AudioPlayer();
    try {
      await _player!.setReleaseMode(ReleaseMode.loop);
      await _player!.setVolume(1.0);
      await _player!.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.alarm,
            audioFocus: AndroidAudioFocus.gain,
            audioMode: AndroidAudioMode.ringtone,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {
              AVAudioSessionOptions.mixWithOthers,
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('BookingSoundService._configurePlayer: $e');
      }
    }
  }

  static Future<void> playBookingAlert(String bookingId) async {
    if (bookingId.isEmpty) {
      return;
    }

    _activeBookingIds.add(bookingId);

    try {
      await _configurePlayer();
      await _player!.stop();
      await _player!.play(AssetSource(AppAudios.requestSound));
      _startPendingPoll();
    } catch (e) {
      if (kDebugMode) {
        print('BookingSoundService.playBookingAlert: $e');
      }
    }
  }

  static void _startPendingPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_activeBookingIds.isEmpty) {
        _pollTimer?.cancel();
        return;
      }
      if (Get.isRegistered<BookingRequestController>()) {
        Get.find<BookingRequestController>().getBookingRequestList('pending', 1, reload: true);
      }
    });
  }

  static Future<void> stopAlert({String? bookingId}) async {
    if (bookingId != null && bookingId.isNotEmpty) {
      _activeBookingIds.remove(bookingId);
    } else {
      _activeBookingIds.clear();
    }

    if (_activeBookingIds.isEmpty) {
      _pollTimer?.cancel();
      _pollTimer = null;
      try {
        await _player?.stop();
      } catch (_) {}
    }
  }

  static void onPendingListUpdated(List<String> pendingBookingIds) {
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
