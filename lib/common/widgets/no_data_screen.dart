import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class NoDataScreen extends StatelessWidget {
  final NoDataType? type;
  final String? text;
  const NoDataScreen({super.key, required this.text, this.type});

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      const Row(),
      type != NoDataType.none ?
      Image.asset(
        type == NoDataType.conversation ? Images.chatImage :
        type == NoDataType.request ? Images.noData :
        type == NoDataType.notification ? Images.emptyNotification :
        type == NoDataType.transaction ? Images.noTransaction :
        type == NoDataType.service ? Images.settingsLoading :
        type == NoDataType.customPost ? Images.customPost :
        type == NoDataType.myBids ? Images.myBids :
        type == NoDataType.others ? Images.othersNoData :
        type == NoDataType.subscriptions ? Images.settingsIcon :
        type == NoDataType.advertisement ? Images.emptyAdvertisementIcon :
        Images.help,

        width: MediaQuery.of(context).size.height * 0.06,
        height: MediaQuery.of(context).size.height * 0.06,
      ) : const SizedBox(),
      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
      Text(
        type == NoDataType.conversation ? 'your_inbox_list_empty_right_now'.tr :
        type == NoDataType.myBids ? 'bid_request_not_found'.tr :
        type == NoDataType.customPost ? 'new_request_not_found'.tr :
        type == NoDataType.others ? 'no_data_found'.tr :
        type == NoDataType.notification ? 'no_notification'.tr : text!.tr,
        style: robotoMedium.copyWith(
          fontSize: Dimensions.fontSizeDefault,
          color:Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.5),
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.08),
    ]);
  }
}