import 'package:demandium_provider/helper/booking_sound_service.dart';
import 'package:demandium_provider/utils/core_export.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'settings'.tr),
      body: GetBuilder<AuthController>(builder: (authController) {
        return Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'notification_sound'.tr,
                    style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                  ),
                ),
                FlutterSwitch(
                  width: 45,
                  height: 24,
                  padding: 2,
                  toggleSize: 20,
                  value: authController.isNotificationActive(),
                  activeColor: Theme.of(context).primaryColor,
                  onToggle: (bool value) {
                    if (authController.isNotificationActive() != value) {
                      authController.toggleNotificationSound();
                    }
                    if (!value) {
                      BookingSoundService.stopAlert();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
