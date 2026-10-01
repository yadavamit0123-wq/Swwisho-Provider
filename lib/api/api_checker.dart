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
    } else if (response.statusCode == 400 && response.body is Map && response.body['errors'] != null) {
      final errors = response.body['errors'];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        showCustomSnackBar('${errors.first['message']}', showDefaultSnackBar: showDefaultToaster);
      } else {
        showCustomSnackBar(_messageFromBody(response.body) ?? 'something_went_wrong'.tr, showDefaultSnackBar: showDefaultToaster);
      }
    } else if (response.statusCode == 429) {
      showCustomSnackBar("too_many_request".tr, showDefaultSnackBar: showDefaultToaster);
    } else {
      showCustomSnackBar(
        _messageFromBody(response.body) ?? response.statusText ?? 'something_went_wrong'.tr,
        showDefaultSnackBar: showDefaultToaster,
      );
    }
  }

  static String? _messageFromBody(dynamic body) {
    if (body is Map) {
      final message = body['message'];
      if (message != null && message.toString().isNotEmpty) {
        return message.toString();
      }
    } else if (body is String && body.trim().isNotEmpty) {
      final text = body.trim();
      if (_looksLikeHtml(text)) {
        return null;
      }
      return text;
    }
    return null;
  }

  static bool _looksLikeHtml(String text) {
    final lower = text.toLowerCase();
    return lower.startsWith('<!doctype') ||
        lower.startsWith('<html') ||
        lower.contains('<head>') ||
        lower.contains('<body');
  }
}
