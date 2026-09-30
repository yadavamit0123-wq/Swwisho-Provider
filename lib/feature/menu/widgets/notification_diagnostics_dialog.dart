import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/utils/app_audios.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

/// Hidden diagnostics (long-press on app version in More menu).
/// Lets us verify on-device: FCM token, subscribed topics, permission,
/// and whether local notification + sound work — without touching the server.
class NotificationDiagnosticsDialog extends StatefulWidget {
  const NotificationDiagnosticsDialog({super.key});

  @override
  State<NotificationDiagnosticsDialog> createState() => _NotificationDiagnosticsDialogState();
}

class _NotificationDiagnosticsDialogState extends State<NotificationDiagnosticsDialog> {
  String _token = 'loading...';
  String _zoneId = '';
  bool? _notificationsEnabled;
  bool _busy = false;
  String _serverResult = '';

  Future<void> _serverCheck() async {
    final buffer = StringBuffer();
    try {
      final tokenRes = await Get.find<AuthController>().authRepo.updateToken();
      buffer.writeln('fcm-token update → HTTP ${tokenRes?.statusCode}');
      buffer.writeln(_short(tokenRes?.body ?? tokenRes?.statusText ?? 'no response'));
    } catch (e) {
      buffer.writeln('fcm-token update → error: $e');
    }
    buffer.writeln('');
    try {
      final setupRes = await Get.find<NotificationSetupController>()
          .notificationSetupRepo
          .getNotificationSetupList(type: 'provider');
      buffer.writeln('notification-setup?type=provider → HTTP ${setupRes.statusCode}');
      final content = setupRes.body is Map ? setupRes.body['content'] : null;
      int count = 0;
      if (content is List) count = content.length;
      if (content is Map && content['data'] is List) count = (content['data'] as List).length;
      buffer.writeln('rows for provider: $count');
      buffer.writeln(_short(setupRes.body ?? setupRes.statusText));
    } catch (e) {
      buffer.writeln('notification-setup → error: $e');
    }
    buffer.writeln('');
    try {
      final zoneRes = await Get.find<UserProfileController>().userRepo.getZonesDataList();
      final isJson = zoneRes?.body is Map;
      buffer.writeln('zone-list → HTTP ${zoneRes?.statusCode} (${isJson ? 'JSON' : 'HTML/route missing'})');
      buffer.writeln(_short(zoneRes?.body ?? zoneRes?.statusText ?? 'no response'));
    } catch (e) {
      buffer.writeln('zone-list → error: $e');
    }
    if (mounted) setState(() => _serverResult = buffer.toString());
  }

  String _short(dynamic body) {
    final text = body is String ? body : jsonEncode(body);
    return text.length > 500 ? '${text.substring(0, 500)}…' : text;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    String token = 'unavailable';
    try {
      token = await FirebaseMessaging.instance.getToken() ?? 'null';
    } catch (e) {
      token = 'error: $e';
    }

    String zoneId = '';
    try {
      if (Get.isRegistered<UserProfileController>()) {
        zoneId = Get.find<UserProfileController>().myZoneId ?? '';
      }
    } catch (_) {}

    bool? enabled;
    try {
      enabled = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled();
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _token = token;
      _zoneId = zoneId;
      _notificationsEnabled = enabled;
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      showCustomSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = ['provider', if (_zoneId.isNotEmpty) 'provider-$_zoneId'];
    final permissionText = _notificationsEnabled == null
        ? 'unknown'
        : (_notificationsEnabled! ? 'ALLOWED' : 'BLOCKED (enable in phone settings)');

    return Dialog(
      insetPadding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Notification Diagnostics', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              _row('App version', AppConstants.appVersion),
              _row('Notification permission', permissionText),
              _row('Zone ID', _zoneId.isEmpty ? 'EMPTY (topic subscribe will fail)' : _zoneId),
              _row('Topics', topics.join(', ')),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              Text('FCM token', style: robotoMedium),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall),
              SelectableText(_token, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Copy token',
                height: 40,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: _token));
                  showCustomSnackBar('Token copied', type: ToasterMessageType.success);
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Test sound only',
                height: 40,
                isLoading: _busy,
                onPressed: () => _run(() async {
                  await AudioPlayer().play(AssetSource(AppAudios.requestSound));
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Test notification + sound',
                height: 40,
                isLoading: _busy,
                onPressed: () => _run(() async {
                  await NotificationHelper.showBigTextNotification(
                    title: 'Swwisho test',
                    body: 'If you see this with sound, the app side works.',
                    payload: jsonEncode({'type': 'general'}),
                    fln: flutterLocalNotificationsPlugin,
                    forceSound: true,
                  );
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Re-register token & topics',
                height: 40,
                isLoading: _busy,
                onPressed: () => _run(() async {
                  await Get.find<AuthController>().updateToken();
                  await _load();
                  showCustomSnackBar('Token & topics re-registered', type: ToasterMessageType.success);
                }),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Server check (token + notification setup)',
                height: 40,
                isLoading: _busy,
                onPressed: () => _run(_serverCheck),
              ),
              if (_serverResult.isNotEmpty) ...[
                const SizedBox(height: Dimensions.paddingSizeSmall),
                SelectableText(_serverResult, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                CustomButton(
                  btnTxt: 'Copy server result',
                  height: 40,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: _serverResult));
                    showCustomSnackBar('Copied', type: ToasterMessageType.success);
                  },
                ),
              ],
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomButton(
                btnTxt: 'Close',
                height: 40,
                transparent: true,
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: RichText(
        text: TextSpan(
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          children: [
            TextSpan(text: '$label: ', style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
