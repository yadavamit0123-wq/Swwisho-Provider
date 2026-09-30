import 'package:demandium_provider/utils/core_export.dart';

class ZoneListHelper {
  static bool isJsonMap(dynamic body) => body is Map;

  static List<ZoneData> extract(dynamic body) {
    final zones = <ZoneData>[];
    if (body is! Map) return zones;

    dynamic content = body['content'] ?? body['data'] ?? body['zones'];
    List<dynamic> raw = const [];

    if (content is List) {
      raw = content;
    } else if (content is Map) {
      if (content['data'] is List) {
        raw = content['data'];
      } else if (content['zones'] is List) {
        raw = content['zones'];
      } else if (content['zone'] is Map) {
        raw = [content['zone']];
      }
    } else if (body['zone'] is Map) {
      raw = [body['zone']];
    }

    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final id = map['id']?.toString();
      final name = map['name']?.toString();
      if (id == null || id.isEmpty) continue;
      zones.add(ZoneData(id: id, name: name ?? ''));
    }
    return zones;
  }

  static Future<List<ZoneData>> fetch({
    required ApiClient apiClient,
    double? latitude,
    double? longitude,
    String? currentZoneId,
    String? currentZoneName,
  }) async {
    final uris = <String>[
      '${AppConstants.zoneUrl}?limit=200&offset=1',
      '/api/v1/customer/zone/list',
      '/api/v1/zones?limit=100&offset=1',
    ];

    List<ZoneData> zones = [];
    for (final uri in uris) {
      try {
        final response = await apiClient.getData(uri);
        if (response.statusCode == 200 && isJsonMap(response.body)) {
          zones = extract(response.body);
          if (zones.isNotEmpty) break;
        }
      } catch (_) {}
    }

    if (zones.isEmpty && latitude != null && longitude != null && latitude != 0 && longitude != 0) {
      try {
        final response = await apiClient.getData(
          '${AppConstants.customerConfigUri}/get-zone-id?lat=$latitude&lng=$longitude',
        );
        if (response.statusCode == 200 && isJsonMap(response.body)) {
          zones = extract(response.body);
        }
      } catch (_) {}
    }

    if (currentZoneId != null && currentZoneId.isNotEmpty) {
      final exists = zones.any((z) => z.id == currentZoneId);
      if (!exists) {
        zones.insert(0, ZoneData(
          id: currentZoneId,
          name: (currentZoneName != null && currentZoneName.isNotEmpty) ? currentZoneName : 'Current zone',
        ));
      }
    }
    return zones;
  }
}
