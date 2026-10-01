/// Parses provider booking list API responses across minor backend shape differences.
class BookingListParser {
  BookingListParser._();

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static List<dynamic> extractBookingRows(dynamic body) {
    final root = _asMap(body);
    if (root == null) return const [];

    final content = root['content'];
    final contentMap = _asMap(content);

    dynamic bookingsNode;
    if (contentMap != null) {
      bookingsNode = contentMap['bookings'] ?? contentMap['booking'];
      if (bookingsNode == null && _looksLikeBookingList(contentMap['data'])) {
        return List<dynamic>.from(contentMap['data'] as List);
      }
    } else if (content is List && _looksLikeBookingList(content)) {
      return List<dynamic>.from(content);
    }

    if (bookingsNode is Map && bookingsNode['data'] is List) {
      return List<dynamic>.from(bookingsNode['data'] as List);
    }
    if (bookingsNode is List) {
      return List<dynamic>.from(bookingsNode);
    }

    final rootBookings = root['bookings'];
    if (rootBookings is Map && rootBookings['data'] is List) {
      return List<dynamic>.from(rootBookings['data'] as List);
    }
    if (rootBookings is List) {
      return List<dynamic>.from(rootBookings);
    }

    if (root['data'] is List && _looksLikeBookingList(root['data'])) {
      return List<dynamic>.from(root['data'] as List);
    }

    return const [];
  }

  static int extractLastPage(dynamic body, {int fallback = 1}) {
    final root = _asMap(body);
    if (root == null) return fallback;

    final contentMap = _asMap(root['content']);
    if (contentMap != null) {
      final bookings = contentMap['bookings'];
      if (bookings is Map) {
        final page = int.tryParse(bookings['last_page']?.toString() ?? '');
        if (page != null && page > 0) return page;
      }
      final page = int.tryParse(contentMap['last_page']?.toString() ?? '');
      if (page != null && page > 0) return page;
    }

    final rootBookings = root['bookings'];
    if (rootBookings is Map) {
      final page = int.tryParse(rootBookings['last_page']?.toString() ?? '');
      if (page != null && page > 0) return page;
    }

    return fallback;
  }

  static Map<String, dynamic>? extractBookingCounts(dynamic body) {
    final root = _asMap(body);
    if (root == null) return null;

    final contentMap = _asMap(root['content']);
    if (contentMap == null) return null;

    final counts = contentMap['bookings_count'];
    if (counts is Map) {
      return Map<String, dynamic>.from(counts);
    }
    return null;
  }

  static bool _looksLikeBookingList(dynamic value) {
    if (value is! List || value.isEmpty) return false;
    for (final item in value) {
      if (item is Map &&
          (item.containsKey('booking_status') ||
              item.containsKey('readable_id') ||
              item.containsKey('id'))) {
        return true;
      }
    }
    return false;
  }
}
