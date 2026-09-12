
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';


class BottomNavScreen extends StatefulWidget {
  final int pageIndex;

  static Future<void> loadData({int pageIndex = 0}) async {
    Get.find<LocalizationController>().filterLanguage(shouldUpdate: false);
    Get.find<AuthController>().updateToken();
    Get.find<DashboardController>().getDashboardData(reload: true);

    final userController = Get.find<UserProfileController>();
    if (userController.providerModel == null) {
      userController.getProviderInfo(reload: true);
    }

    Future.microtask(() {
      userController.refreshProviderInfoIfStale();
      Get.find<ServiceCategoryController>().getCategoryList(shouldUpdate: true, reloadSubcategory: true);
      Get.find<HtmlViewController>().getPagesContent();
      Get.find<BusinessSubscriptionController>().getSubscriptionPackageList();
      Get.find<ConversationController>().getChannelList(1, type: "serviceman");
      Get.find<ConversationController>().getChannelList(1, type: "customer");
      Get.find<ServicemanSetupController>().getAllServicemanList(1, reload: true, status: 'all');
      Get.find<UserProfileController>().trialWidgetShow(route: "");
      if (pageIndex != 1) {
        Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet();
      }
    });
  }

  const BottomNavScreen({super.key, required this.pageIndex});

  @override
  BottomNavScreenState createState() => BottomNavScreenState();
}

class BottomNavScreenState extends State<BottomNavScreen> {
  int _pageIndex = 0;
  final Set<int> _visitedTabs = {};
  final Map<int, Widget> _pageCache = {};
  bool _canExit = GetPlatform.isWeb ? true : false;

  @override
  void initState() {
    super.initState();
    BottomNavScreen.loadData(pageIndex: widget.pageIndex);
    _pageIndex = widget.pageIndex;
    _visitedTabs.add(_pageIndex);
  }

  Widget _pageWidget(int index) {
    return _pageCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return const DashBoardScreen();
        case 1:
          return const BookingRequestScreen();
        case 2:
          return const AllServicesScreen();
        default:
          return const SizedBox.shrink();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;

    return CustomPopScopeWidget(
      onPopInvoked: (){
        if (_pageIndex != 0) {
          _setPage(0);
        } else {
          if(_canExit) {
            exit(0);
          }else {
            showCustomSnackBar('back_press_again_to_exit'.tr,  type: ToasterMessageType.info);
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        }
      },
      child: Scaffold(
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeDefault,
            bottom: padding.bottom > 15 ? 0 : Dimensions.paddingSizeDefault,
          ),
          decoration: BoxDecoration(
              color: Get.isDarkMode?Theme.of(context).colorScheme.surface:Theme.of(context).primaryColor,
              boxShadow:[
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Theme.of(context).primaryColor.withValues(alpha:0.5),
                )]
          ),
          child: SafeArea(
            child: Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
              child: Row(children: [
                _getBottomNavItem(0, Images.dashboard, 'dashboard'.tr),
                _getBottomNavItem(1, Images.requests, 'requests'.tr),
                _getBottomNavItem(2, Images.service, 'services'.tr),
                _getBottomNavItem(3, Images.more, 'more'.tr),
              ]),
            ),
          ),
        ),
        body: IndexedStack(
          index: _pageIndex,
          sizing: StackFit.expand,
          children: List.generate(3, (index) {
            if (!_visitedTabs.contains(index)) {
              return const SizedBox.shrink();
            }
            return _pageWidget(index);
          }),
        ),
        floatingActionButton: Get.find<SplashController>().configModel.content?.biddingStatus==1 && Get.find<SplashController>().showCustomBookingButton?   GestureDetector(
          onTap: () => Get.to(()=> const CustomerRequestListScreen()),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: shadow,
              borderRadius: BorderRadius.circular(50),
              color: Theme.of(context).cardColor,
            ),
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault-2),
            child: Image.asset(Images.createPostIconWithRedDot,height: 40,width: 40,

            ),
          ),
        ): null,
      ),
    );
  }

  void _setPage(int pageIndex) {
    if(pageIndex == 3) {
      Get.find<UserProfileController>().trialWidgetShow(route: "show-dialog");
      Get.bottomSheet(
        const MenuScreen(),
        backgroundColor: Colors.transparent, isScrollControlled: true,
        barrierColor: Colors.black.withValues(alpha:Get.isDarkMode ? 0.7 : 0.6 ),
      ).then((_){
        Get.find<UserProfileController>().trialWidgetShow(route: "");
      });
    } else {
      _visitedTabs.add(pageIndex);
      setState(() => _pageIndex = pageIndex);
    }
  }

  Widget _getBottomNavItem(int index, String icon, String title) {
    return Expanded(child: InkWell(
      onTap: () => _setPage(index),
      child: Column(mainAxisSize: MainAxisSize.min, children: [

        icon.isEmpty ? const SizedBox(width: 20, height: 20) : Image.asset(
          icon, width: 17, height: 17,
          color: _pageIndex == index ? Get.isDarkMode ? Theme.of(context).primaryColor : Colors.white : Colors.grey.shade400
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(title, style: robotoRegular.copyWith(
          fontSize: Dimensions.fontSizeSmall,
          color: _pageIndex == index ? Get.isDarkMode ? Theme.of(context).primaryColor : Colors.white : Colors.grey.shade400
        )),

      ]),
    ));
  }

}
