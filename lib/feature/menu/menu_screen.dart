import 'package:demandium_provider/utils/core_export.dart';

class MenuModel {
  final String icon;
  final String title;
  final String route;
  final bool isLogout;

  MenuModel({
    required this.icon,
    required this.title,
    this.route = '',
    this.isLogout = false,
  });
}

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Get.find<SplashController>().configModel.content;

    final menuList = <MenuModel>[
      MenuModel(icon: Images.profileInformation, title: 'my_profile'.tr, route: RouteHelper.getProfileRoute()),
      MenuModel(icon: Images.translate, title: 'language'.tr, route: 'language_sheet'),
      MenuModel(icon: Images.notificationIcon, title: 'notifications'.tr, route: RouteHelper.getNotificationRoute()),
      MenuModel(icon: Images.notificationSetup, title: 'notification_channel_setup'.tr, route: RouteHelper.getNotificationScreen()),
      MenuModel(icon: Images.help, title: 'help_&_support'.tr, route: RouteHelper.getHelpAndSupportScreen()),
      MenuModel(icon: Images.reportFilterIcon, title: 'reports_&_analytics'.tr, route: RouteHelper.getReportingPageRoute('menu')),
      MenuModel(icon: Images.mySubscriptions, title: 'subscriptions'.tr, route: RouteHelper.getMySubscriptionRoute()),
      if (config?.biddingStatus == 1)
        MenuModel(icon: Images.customPost, title: 'custom_booking_request'.tr, route: 'custom_post'),
      MenuModel(icon: Images.privacyPolicyIcon, title: 'privacy_policy'.tr, route: RouteHelper.getHtmlRoute(page: 'privacy-policy')),
      MenuModel(icon: Images.logout, title: 'logout'.tr, isLogout: true),
    ];

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        color: Theme.of(context).cardColor,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: Get.back,
              child: Icon(Icons.keyboard_arrow_down_rounded, size: 30, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: Dimensions.paddingSizeExtraSmall),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : 6,
                childAspectRatio: 1,
                crossAxisSpacing: Dimensions.paddingSizeExtraSmall,
                mainAxisSpacing: Dimensions.paddingSizeExtraSmall,
              ),
              itemCount: menuList.length,
              itemBuilder: (context, index) => _MenuButton(menu: menuList[index]),
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Text(
              '${'app_version'.tr} ${AppConstants.appVersion}',
              style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final MenuModel menu;

  const _MenuButton({required this.menu});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final route = menu.route;
        final isLogout = menu.isLogout;
        Get.back();
        if (isLogout) {
          Get.find<AuthController>().clearSharedData();
          Get.offAllNamed(RouteHelper.signIn);
          return;
        }
        if (route == 'custom_post') {
          Get.to(() => const CustomerRequestListScreen());
          return;
        }
        if (route == 'language_sheet') {
          Get.bottomSheet(
            const ChooseLanguageBottomSheet(),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            barrierColor: Colors.black.withValues(alpha: Get.isDarkMode ? 0.7 : 0.6),
          );
          return;
        }
        if (route.isNotEmpty) {
          Get.toNamed(route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(menu.icon, height: 28, width: 28),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),
          Text(
            menu.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
          ),
        ],
      ),
    );
  }
}
