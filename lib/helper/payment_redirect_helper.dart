import 'package:demandium_provider/utils/core_export.dart';

class PaymentRedirectHelper {
  static Future<void> handleRedirect(String url, String fromPage) async {
    bool isSuccess = url.contains('success') && url.contains(AppConstants.baseUrl);
    bool isFailed = url.contains('fail') && url.contains(AppConstants.baseUrl);
    bool isCancel = url.contains('cancel') && url.contains(AppConstants.baseUrl);

    if (isSuccess) {
      if (fromPage == 'signUp') {
        Get.offAllNamed(RouteHelper.signIn);
        showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: true));
      } else if (fromPage == 'business_plan') {
        Get.back();
        showCustomSnackBar('paid_successfully'.tr, type: ToasterMessageType.success);
        await Get.find<UserProfileController>().getProviderInfo(reload: true);
      } else {
        Future.delayed(const Duration(seconds: 1), () {
          Get.find<UserProfileController>().getProviderInfo(reload: true);
          showCustomSnackBar('paid_successfully'.tr, type: ToasterMessageType.success);
        });
        Get.back();
      }
    } else if (isFailed || isCancel) {
      Get.back();
      if (fromPage == 'signUp') {
        Get.offAllNamed(RouteHelper.signIn);
        showCustomBottomSheet(child: const WelcomeBottomSheet(fromSignup: true, isFromTransactionFailed: true));
      } else {
        showCustomSnackBar('transaction_failed'.tr);
      }
    }
  }
}
