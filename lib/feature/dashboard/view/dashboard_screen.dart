import 'package:demandium_provider/feature/dashboard/widgets/advertisement_section.dart';
import 'package:demandium_provider/feature/nav/widgets/subscription_trail_end_widget.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

import '../../profile/view/wallet_information/view/wallet_information.dart';


class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});
  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}
class _DashBoardScreenState extends State<DashBoardScreen>{
  final toolTip = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<DashboardController>().getMonthlyBookingsDataForChart(DateConverter.stringYear(DateTime.now()),DateTime.now().month.toString());
    Get.find<DashboardController>().getYearlyBookingsDataForChart(DateConverter.stringYear(DateTime.now()));
    Get.find<BusinessSettingController>().getBookingSettingsDataFromServer();
    Get.find<BusinessSettingController>().getServiceAvailabilitySettingsFromServer();
  }

  void checkWallet(double balance, BuildContext context) {
    if (balance < AppConstants.minimumWalletRecharge) {
      Future.delayed(Duration.zero, () {
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Warning Icon with Animation
                  AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber[700],
                      size: 50,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Title
                  Text(
                    "Low Wallet Balance",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Message
                  Text(
                    "Your wallet balance is $balance. Recharge now to continue accepting bookings!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Recharge Button with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.to(WalletInformation());
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.account_balance_wallet, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "Recharge Now",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Cancel Button
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(initState: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final userProfileController = Get.find<UserProfileController>();

            if (!userProfileController.hasShownWalletDialog) {
              double balance = double.parse(userProfileController.newWalletAmount.toString() ?? '0');
              checkWallet(balance, context);
              userProfileController.hasShownWalletDialog = true;
            }
          });
        }, builder: (userProfileController){

      bool canShow = userProfileController.providerModel != null && userProfileController.providerModel!.content !=null && userProfileController.providerModel!.content!.subscriptionInfo !=null
          && userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails !=null && userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.trialDuration !=0
          && DateConverter.countDays(endDate: DateTime.parse(userProfileController.providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.packageEndDate!)) > 0;
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar:  MainAppBar(
          color: Theme.of(context).primaryColor,
          title: AppConstants.appName,
          titleFontSize: Dimensions.fontSizeExtraLarge + 4,
        ),
        body: RefreshIndicator(
          color: Theme.of(context).primaryColorLight,
          backgroundColor: Theme.of(context).cardColor,
          onRefresh: () async {
            await Get.find<DashboardController>().getDashboardData();
            Get.find<DashboardController>().changeGraph(EarningType.monthly);
            Get.find<DashboardController>().changeRecentActivityView(status: true, shouldUpdate: true);
            Get.find<DashboardController>().changeTypeOfShowBookingStatus(status: true, shouldUpdate: true);
            await Get.find<DashboardController>().getMonthlyBookingsDataForChart(DateConverter.stringYear(DateTime.now()),
                DateTime.now().month.toString());
            await Get.find<DashboardController>().getYearlyBookingsDataForChart(DateConverter.stringYear(DateTime.now()));
            await Get.find<UserProfileController>().getProviderInfo(reload: true);
            Get.find<NotificationController>().getNotifications(1,saveNotificationCount: false);
            Get.find<SplashController>().getConfigData();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                ListTile(
                  title: Text("${"you_are".tr} ${userProfileController.isOnline ? 'online'.tr : 'offline'.tr}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  trailing: Switch(value: userProfileController.isOnline, onChanged: (value) {
                    // userProfileController.changeStatus(value);
                    if(userProfileController.isOnline){
                      if(!(userProfileController.availabilityController?.availableForOnline ?? true)){
                        offline(userProfileController.availabilityController?.remainingTimeNotifier.value ?? 'after 4 hours', true);
                      }else{
                        offlineWarning(userProfileController);
                      }
                    }else{
                      if(!(userProfileController.availabilityController?.availableForOnline ?? true)){
                        offline(userProfileController.availabilityController?.remainingTimeNotifier.value ?? 'after 4 hours', false);
                      }else{
                        userProfileController.changeStatus(value);
                      }
                    }
                  },
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    inactiveThumbColor: Colors.red,
                    trackOutlineColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (!userProfileController.isOnline) {
                          return Colors.red;
                        }
                        return Colors.transparent;
                      },
                    ),
                    trackOutlineWidth: WidgetStatePropertyAll(1.0),
                    activeColor: Colors.green,
                  ),
                  subtitle: userProfileController.availabilityController == null ? null : ValueListenableBuilder<String>(
                    valueListenable: userProfileController.availabilityController!.remainingTimeNotifier,
                    builder: (context, value, child) {
                      return Text("${userProfileController.availabilityController?.availableForOnline ?? false ? '' : 'Available in:'} $value", style: const TextStyle(fontSize: 12));
                    },
                  ),
                ),
                TopCardSection(toolTip: toolTip,),
                const AdvertisementSection(),
                const GraphSection(),
                const RecentActivitySection(),
                const MySubscriptionSection(),
                // const ServiceManSection(),
              ],
            ),
          ),
        ),
        //floatingActionButton: Container(height: 20, color: Colors.red,),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: canShow && !userProfileController.trialWidgetNotShow ? const SubscriptionTrailEndWidget() : const SizedBox(),
      );
    });
  }

  offlineWarning(UserProfileController controller){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Warning',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to go offline?\n\nOnce offline, you won’t be able to go online again for the next 4 hours.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                controller.changeStatus(false);
              },
              child: Text('Ok', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

  }

  offline(String remainingTime, bool isOnline){
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              SizedBox(width: 8),
              Text(
                'Not Allowed',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            'You cannot go ${isOnline ? 'offline' : 'online'} right now.\nYou must wait 4 hours after going ${isOnline ? 'online' : 'offline'}. Please try again in: $remainingTime',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Ok', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );

  }
}
