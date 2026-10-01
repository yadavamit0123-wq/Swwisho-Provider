import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class AdvertisementRepo {
  final ApiClient apiClient;
  AdvertisementRepo({required this.apiClient});


  Future<Response> submitNewAdvertisement(Map<String, String> body, List<MultipartBody> selectedFile) async {
    return await apiClient.postMultipartData(
        AppConstants.submitNewAdvertisement,
        body,
        selectedFile , null,
    );
  }


  Future<Response> editAdvertisement ({required String id, required Map<String, String> body, List<MultipartBody>? selectedFile}) async {
    return await apiClient.postMultipartData(
      "${AppConstants.editAdvertisement}/$id",
      body,
      selectedFile , null,
    );
  }


  
  Future<Response> getAdvertisementList ({required String requestType, required int offset}) async {
    return await apiClient.getData(
        "${AppConstants.getAdvertisementList}?limit=10&offset=$offset&status=$requestType");
  }
  
  

  Future<Response> getAdvertisementDetails ({required String id}) async {
    return await apiClient.getData("${AppConstants.getAdvertisementDetails}/$id");
  }


  Future<Response> deleteAdvertisement ({required String id}) async {
    return await apiClient.deleteData("${AppConstants.deleteAdvertisement}/$id");
  }


  Future<Response> changeAdvertisementStatus ({required String id, required String status, required Map<String, String> body }) async {
    final uri = '${AppConstants.changeAdvertisementStatus}/$id/$status';
    Response response = await apiClient.putData(uri, body);
    if (response.statusCode == 200) return response;
    response = await apiClient.postData(uri, {...body, '_method': 'put'});
    if (response.statusCode == 200) return response;
    return await apiClient.postData(
      AppConstants.changeAdvertisementStatus,
      {...body, '_method': 'put', 'advertisement_id': id, 'status': status},
    );
  }


  Future<Response> reSubmitAdvertisement (String id,
      {required Map<String, String> body, required List<MultipartBody> selectedFile}) async {
    return await apiClient.postMultipartData(
      "${AppConstants.reSubmitAdvertisement}/$id",
      body,
      selectedFile , null,
    );
  }


  
}