import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class NotificationSettingScreen extends StatefulWidget{
  const NotificationSettingScreen({super.key});

  @override
  State<NotificationSettingScreen> createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {

    NotificationSetupController controller = Get.find<NotificationSetupController>();
    controller.clearSearchController(shouldUpdate: false);
    controller.getNotificationSetupList(type: "provider");
    controller.getNotificationSetupList(type: "serviceman");
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<NotificationSetupController>(builder: (businessSettingController){
      return Scaffold( backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "notification_channel_setup".tr),

        body:  Column(children: [

          Container(
            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: Colors.blue
                  )
              ),
            ),
            child: TabBar(
              unselectedLabelColor:Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
              indicatorColor: Theme.of(context).primaryColor,
              labelColor: Theme.of(context).primaryColorLight,
              labelStyle:  robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
              labelPadding: EdgeInsets.zero,
              controller: businessSettingController.tabController,
              tabs:  [
                SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width* .5,
                  child:Center(
                    child: Text("notification_for_you".tr),
                  ),
                ),
                // SizedBox(
                //   height: 40,
                //   width: MediaQuery.of(context).size.width*.4,
                //   child:  Center(
                //     child: Text("serviceman".tr),
                //   ),
                // ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault,),
          NotificationSetupSearchWidget(tabController: businessSettingController.tabController,),

          const SizedBox(height: Dimensions.paddingSizeSmall,),

          Expanded(
            child: TabBarView(
              controller: businessSettingController.tabController,
              children: const [
                ProviderNotificationSetup(),
                // ServicemanNotificationSetup(),
              ],
            ),
          ),
        ]),
      );
    });
  }
}