import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class ServiceRepo{
  final ApiClient apiClient;

  ServiceRepo({required this.apiClient,});

  Future<Response> getCategoryList() async {
    return await apiClient.getData("${AppConstants.serviceCategoryUrl}?limit=100&offset=1");
  }

  Future<Response> getSubCategoryList(String id ,int offset) async {
    return await apiClient.getData("${AppConstants.serviceSubcategoryUrl}?limit=10&offset=$offset&id=$id");
  }

  bool _responseHasServiceRows(dynamic body) {
    if (body is! Map) return false;
    final content = body['content'];
    if (content is Map) {
      final data = content['data'] ?? content['services'] ?? content['service'];
      if (data is List && data.isNotEmpty) return true;
    } else if (content is List && content.isNotEmpty) {
      return true;
    }
    return body['data'] is List && (body['data'] as List).isNotEmpty;
  }

  Future<Response> getServiceListBasedOnSubcategory(String subCategoryId,{String queryText=""}) async {
    final id = subCategoryId.trim();
    final search = Uri.encodeComponent(queryText.trim());
    if (id.isEmpty) {
      return Response(statusCode: 0, statusText: 'Missing sub category id');
    }

    final queryParamUrl =
        "${AppConstants.serviceListBasedOnSubCategory}?limit=100&offset=1&sub_category_id=${Uri.encodeComponent(id)}&search=$search";
    Response response = await apiClient.getData(queryParamUrl);
    if (response.statusCode == 200 && _responseHasServiceRows(response.body)) {
      return response;
    }

    final pathUrl =
        "${AppConstants.serviceListBasedOnSubCategory}/$id?limit=100&offset=1&search=$search";
    final pathResponse = await apiClient.getData(pathUrl);
    if (pathResponse.statusCode == 200) {
      return pathResponse;
    }
    return response.statusCode == 200 ? response : pathResponse;
  }

  Future<Response> changeSubscriptionStatus(String id) async {
    return await apiClient.postData(AppConstants.changeSubscriptionStatusUrl, {'sub_category_id': [id]});
  }
}
