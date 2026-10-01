import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class ServiceDetailsRepo{
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  ServiceDetailsRepo({required this.apiClient,required this.sharedPreferences});

  Future<Response> getServiceDetailsData(String serviceId) async {
    final id = serviceId.trim();
    Response response = await apiClient.getData('${AppConstants.serviceDetailsUrl}/$id');
    if (response.statusCode == 200 && _hasServiceContent(response.body)) {
      return response;
    }
    final queryResponse = await apiClient.getData(
      '${AppConstants.serviceDetailsUrl}?id=$id&service_id=$id',
    );
    if (queryResponse.statusCode == 200) {
      return queryResponse;
    }
    return response.statusCode == 200 ? response : queryResponse;
  }

  bool _hasServiceContent(dynamic body) {
    if (body is! Map) return false;
    final content = body['content'];
    if (content is Map && (content['id'] != null || content['name'] != null)) {
      return true;
    }
    if (content is Map && content['data'] is Map) return true;
    return body['id'] != null && body['name'] != null;
  }

  Future<Response> getServiceFAQData(String serviceId) async {
    return await apiClient.getData("${AppConstants.serviceFaqUrl}?limit=30&offset=1&service_id=$serviceId");
  }

}