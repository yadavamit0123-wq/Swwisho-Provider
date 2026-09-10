import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class ApiChecker {
  static void checkApi(Response response, {bool showDefaultToaster = true}) {
    if (response.statusCode == 401) {
      Get.find<AuthController>().clearSharedData();
      if (Get.currentRoute != RouteHelper.getInitialRoute()) {
        Get.offAllNamed(RouteHelper.getInitialRoute());
        showCustomSnackBar("${response.statusCode!}".tr);
      }
    } else if (response.statusCode == 500) {
      showCustomSnackBar("${response.statusCode!}".tr, showDefaultSnackBar: showDefaultToaster);
    } else if (response.statusCode == 400 && response.body['errors'] != null) {
      showCustomSnackBar("${response.body['errors'][0]['message']}", showDefaultSnackBar: showDefaultToaster);
    } else if (response.statusCode == 429) {
      showCustomSnackBar("too_many_request".tr, showDefaultSnackBar: showDefaultToaster);
    } else {
      showCustomSnackBar("${response.body['message']}", showDefaultSnackBar: showDefaultToaster);
    }
  }
}
