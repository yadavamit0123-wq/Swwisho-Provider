import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BookingRequestRepo{
  final ApiClient apiClient;

  BookingRequestRepo({required this.apiClient});

  Future<Response> getBookingRequestData(String requestType, int offset, ServiceType serviceType) async {
    final limit = Get.find<SplashController>().configModel.content?.paginationLimit ?? 10;
    final body = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      'booking_status': requestType,
    };
    if (serviceType != ServiceType.all) {
      body['service_type'] = serviceType.name;
    }
    return await apiClient.postData(AppConstants.bookingListUrl, body);
  }
}