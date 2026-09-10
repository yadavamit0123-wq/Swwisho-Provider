import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class NotificationSetupRepo {
  final ApiClient apiClient;

  NotificationSetupRepo({required this.apiClient});

  Future<Response> getNotificationSetupList({required String type}) async {
    return await apiClient.getData('${AppConstants.getNotificationSetupList}?type=$type');
  }

  Future<Response> updateNotificationSetup({required dynamic body}) async {
    return await apiClient.postData(AppConstants.updateNotificationSetup, body);
  }
}
