import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BookingDetailsRepo{
  final ApiClient apiClient;

  BookingDetailsRepo({required this.apiClient});

  Future<Response> getBookingDetails(String bookingID) async {
    return await apiClient.getData("${AppConstants.bookingDetailsUrl}$bookingID");
  }

  Future<Response> getSubBookingDetails(String bookingID) async {
    return await apiClient.getData("${AppConstants.subBookingDetailsUrl}$bookingID");
  }

  static bool _bodyLooksLikeHtml(dynamic body) {
    if (body is! String) return false;
    final lower = body.trim().toLowerCase();
    return lower.startsWith('<!doctype') ||
        lower.startsWith('<html') ||
        lower.contains('<head>');
  }

  static bool isActionSuccess(Response response) {
    if (response.statusCode != 200) return false;
    if (_bodyLooksLikeHtml(response.body)) return false;
    if (response.body is! Map) return false;
    final body = Map<String, dynamic>.from(response.body as Map);
    final code = body['response_code']?.toString().trim() ?? '';
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) return false;
    if (code.isEmpty) return true;
    final lower = code.toLowerCase();
    if (lower.contains('fail') ||
        lower.contains('_400') ||
        lower.contains('_403') ||
        lower.contains('_404') ||
        lower.contains('_500')) {
      return false;
    }
    return lower.contains('success') ||
        lower.endsWith('_200') ||
        lower.contains('_201') ||
        code == 'status_update_success_200';
  }

  List<String> _distinctBookingIds(String bookingID, {String? alternateId}) {
    final ids = <String>[];
    void add(String? raw) {
      final value = raw?.toString().trim() ?? '';
      if (value.isEmpty || value == 'null' || ids.contains(value)) return;
      ids.add(value);
    }
    add(bookingID);
    add(alternateId);
    return ids;
  }

  Future<List<String>> _resolveBookingIds(String bookingID, {String? alternateId}) async {
    final ids = _distinctBookingIds(bookingID, alternateId: alternateId);
    void append(String? raw) {
      final value = raw?.toString().trim() ?? '';
      if (value.isEmpty || value == 'null' || ids.contains(value)) return;
      ids.add(value);
    }
    for (final id in List<String>.from(ids)) {
      try {
        final response = await getBookingDetails(id);
        if (response.statusCode != 200 || response.body is! Map) continue;
        final body = Map<String, dynamic>.from(response.body as Map);
        final content = body['content'];
        if (content is! Map) continue;
        final map = Map<String, dynamic>.from(content);
        append(map['id']?.toString());
        append(map['readable_id']?.toString());
      } catch (_) {}
    }
    return ids;
  }

  Future<Response> acceptBookingRequest(String bookingID, {String? alternateId}) async {
    final ids = await _resolveBookingIds(bookingID, alternateId: alternateId);
    Response last = Response(statusCode: 0, statusText: 'No booking id');
    for (final id in ids) {
      last = await _acceptBookingOnce(id);
      if (isActionSuccess(last)) return last;
    }
    return last;
  }

  Future<Response> _postBookingStatus(String id, String bookingStatus) async {
    final fields = {
      'booking_status': bookingStatus,
      '_method': 'put',
      'booking_otp': '',
    };
    Response response = await apiClient.postMultipartData(
      "${AppConstants.changeBookingStatus}/$id",
      fields,
      null,
      null,
    );
    if (isActionSuccess(response)) return response;

    response = await apiClient.postData(
      "${AppConstants.changeBookingStatus}/$id",
      fields,
    );
    if (isActionSuccess(response)) return response;

    return await apiClient.putData(
      "${AppConstants.changeBookingStatus}/$id",
      fields,
    );
  }

  Future<Response> _acceptBookingOnce(String id) async {
    // Demandium versions use either request-accept or request/accept. PUT is the RC method.
    Response response = Response(statusCode: 0, statusText: 'accept failed');
    for (final path in <String>[
      '/api/v1/provider/booking/request-accept/$id',
      '${AppConstants.acceptBookingRequestUrl}/$id',
    ]) {
      response = await apiClient.putData(path, {'method': 'put'});
      if (isActionSuccess(response)) return response;
      response = await apiClient.postData(path, {'_method': 'put'});
      if (isActionSuccess(response)) return response;
    }

    response = await _postBookingStatus(id, 'accepted');
    if (isActionSuccess(response)) return response;

    response = await apiClient.postData(
      "${AppConstants.acceptBookingRequestUrl}/$id",
      {},
    );
    if (isActionSuccess(response)) return response;

    response = await apiClient.postData(
      "${AppConstants.acceptBookingRequestUrl}/$id",
      {'_method': 'put'},
    );
    if (isActionSuccess(response)) return response;

    response = await apiClient.postData(AppConstants.acceptBookingRequestUrl, {
      'booking_id': id,
    });
    if (isActionSuccess(response)) return response;

    return await apiClient.postData(AppConstants.acceptBookingRequestUrl, {
      '_method': 'put',
      'booking_id': id,
    });
  }

  Future<Response> ignoreBookingRequest(String bookingID, {String? alternateId}) async {
    final ids = await _resolveBookingIds(bookingID, alternateId: alternateId);
    Response last = Response(statusCode: 0, statusText: 'No booking id');
    for (final id in ids) {
      last = await _ignoreBookingOnce(id);
      if (isActionSuccess(last)) return last;
    }
    return last;
  }

  Future<Response> _ignoreBookingOnce(String id) async {
    Response response = Response(statusCode: 0, statusText: 'ignore failed');
    for (final path in <String>[
      '/api/v1/provider/booking/request-ignore/$id',
      '${AppConstants.ignoreBookingRequestUrl}/$id',
    ]) {
      response = await apiClient.postData(path, {});
      if (isActionSuccess(response)) return response;
    }

    response = await apiClient.postDataWithoutBody(
      "${AppConstants.ignoreBookingRequestUrl}/$id",
    );
    if (isActionSuccess(response)) return response;

    for (final status in const ['canceled', 'cancelled']) {
      response = await _postBookingStatus(id, status);
      if (isActionSuccess(response)) return response;
    }

    response = await apiClient.postData(AppConstants.ignoreBookingRequestUrl, {
      'booking_id': id,
    });
    if (isActionSuccess(response)) return response;

    return await apiClient.postData(AppConstants.ignoreBookingRequestUrl, {
      '_method': 'put',
      'booking_id': id,
    });
  }

  Future<Response> cancelSubBooking(String subBookingId) async {
    return await apiClient.postData("${AppConstants.cancelSubBookingUrl}$subBookingId", {});
  }

  Future<Response> changeSchedule(String bookingID,String schedule) async {
    return await apiClient.putData("${AppConstants.changeScheduleUrl}/$bookingID",{'schedule': schedule});
  }

  Future<Response> changeBookingStatus(String bookingID,String status, String otp, List<MultipartBody>? photoEvidence, bool isSubBooking) async {
    return await apiClient.postMultipartData(
        "${isSubBooking ? AppConstants.changeSubBookingStatus : AppConstants.changeBookingStatus}/$bookingID",{'booking_status':status,'_method':'put', "booking_otp": otp}, photoEvidence,null
    );
  }

  Future<Response> sendBookingOTPNotification(String? bookingId) {
    return apiClient.getData("${AppConstants.bookingOTPNotificationUri}?booking_id=$bookingId");
  }

  Future<Response> getBookingPriceList(String zoneId , String serviceInfo){
    return apiClient.getData("${AppConstants.getBookingPriceList}?zone_id=$zoneId&service_info=$serviceInfo");
  }

  Future<Response> changeServiceLocation({
    required BookingEditType bookingEditType,ServiceAddress? address, required serviceLocation ,String? bookingId, String? subBookingId,
    bool? changeNextAllBooking,
  }){
    return apiClient.postData(AppConstants.changeServiceLocation, {
      "service_address" : jsonEncode(address),
      "service_location" : serviceLocation,
      "booking_id" : bookingId,
      "next_all_booking_change" : changeNextAllBooking == true && bookingEditType == BookingEditType.repeat ? "1": "0",
      "booking_repeat_id" : subBookingId
    });
  }

  Future<Response> removeCartServiceFromServer({CartModel? cart , String? bookingId, String? zoneId}){
    return apiClient.postData(AppConstants.removeCartServiceFromServer, {
      "_method" : "put",
      "booking_id" : bookingId,
      "zone_id" : zoneId,
      "variant_key" : cart?.variantKey,
      "service_id" : cart?.serviceId
    });
  }

  Future<Response> updateBooking({required BookingEditType bookingEditType,String? bookingId, String? subBookingId , String? zoneId, String? paymentStatus, String? servicemanId, String? bookingStatus, String? serviceSchedule, String? serviceInfo, bool? changeNextAllBooking }){
    return apiClient.postData( bookingEditType == BookingEditType.regular ? AppConstants.updateRegularBooking : AppConstants.updateRepeatBooking, {
      "_method" : "put",
      "booking_id" : bookingId,
      "zone_id" : zoneId,
      "payment_status" : paymentStatus,
      "serviceman_id" : servicemanId,
      "booking_status" : bookingStatus,
      "service_schedule" : serviceSchedule,
      "service_info" : serviceInfo,
      "booking_repeat_id" : subBookingId,
      "next_all_booking_change" : changeNextAllBooking == true && bookingEditType == BookingEditType.repeat ? "1": "0"
    });
  }
}
