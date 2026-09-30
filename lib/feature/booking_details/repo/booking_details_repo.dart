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

  Future<Response> acceptBookingRequest(String bookingID) async {
    Response response = await apiClient.putData(
      "${AppConstants.acceptBookingRequestUrl}/$bookingID",
      {'_method': 'put'},
    );
    if (_isSuccess(response)) return response;
    response = await apiClient.postData(
      "${AppConstants.acceptBookingRequestUrl}/$bookingID",
      {'_method': 'put'},
    );
    if (_isSuccess(response)) return response;
    return await apiClient.postData(AppConstants.acceptBookingRequestUrl, {
      '_method': 'put',
      'booking_id': bookingID,
    });
  }

  Future<Response> ignoreBookingRequest(String bookingID) async {
    Response response = await apiClient.postData(
      "${AppConstants.ignoreBookingRequestUrl}/$bookingID",
      {},
    );
    if (_isSuccess(response)) return response;
    response = await apiClient.putData(
      "${AppConstants.ignoreBookingRequestUrl}/$bookingID",
      {'_method': 'put'},
    );
    if (_isSuccess(response)) return response;
    return await apiClient.postData(AppConstants.ignoreBookingRequestUrl, {
      '_method': 'put',
      'booking_id': bookingID,
    });
  }

  bool _isSuccess(Response response) {
    if (response.statusCode != 200 || response.body is! Map) return false;
    final code = response.body['response_code']?.toString() ?? '';
    final errors = response.body['errors'];
    if (errors is List && errors.isNotEmpty) return false;
    return code.contains('success') ||
        code == 'default_200' ||
        code == 'status_update_success_200' ||
        code.endsWith('_200');
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