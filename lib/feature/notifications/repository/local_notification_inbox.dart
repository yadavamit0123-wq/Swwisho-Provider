import 'dart:convert';

import 'package:demandium_provider/feature/notifications/model/notofication_model.dart';
import 'package:demandium_provider/utils/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationInbox {
  static const int _maxItems = 80;

  static Future<List<Data>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.localNotificationInbox);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      final items = <Data>[];
      for (final item in decoded) {
        if (item is Map) {
          items.add(Data.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveFromRemote(RemoteMessage message) async {
    final title = message.data['title']?.toString()
        ?? message.notification?.title
        ?? AppConstants.appName;
    final body = message.data['body']?.toString()
        ?? message.notification?.body
        ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final image = message.data['image']?.toString()
        ?? message.notification?.android?.imageUrl
        ?? '';

    final item = Data(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: body,
      coverImageFullPath: image.isNotEmpty ? image : null,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      isActive: 1,
    );
    await add(item);
  }

  static Future<void> add(Data item) async {
    try {
      final items = await load();
      final duplicate = items.any((existing) =>
          existing.title == item.title &&
          existing.description == item.description &&
          _isRecent(existing.createdAt));
      if (duplicate) return;
      items.insert(0, item);
      if (items.length > _maxItems) {
        items.removeRange(_maxItems, items.length);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.localNotificationInbox,
        jsonEncode(items.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  static bool _isRecent(String? createdAt) {
    final parsed = DateTime.tryParse(createdAt ?? '');
    if (parsed == null) return false;
    return DateTime.now().difference(parsed).inSeconds < 15;
  }
}
