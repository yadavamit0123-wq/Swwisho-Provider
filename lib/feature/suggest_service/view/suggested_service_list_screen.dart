import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class SuggestedServiceListScreen extends StatelessWidget {
  const SuggestedServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'service_request_list'.tr),
      body: GetBuilder<SuggestServiceController>(
        initState: (_) => Get.find<SuggestServiceController>().getSuggestedServiceList(1, reload: true),
        builder: (suggestServiceController) {
          if (suggestServiceController.suggestedServiceModel == null) {
            return const SuggestServiceListShimmer();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (suggestServiceController.suggestedServiceList.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(
                      children: [
                        Text('${'request'.tr} ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '(${suggestServiceController.suggestedServiceList.length})',
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (suggestServiceController.suggestedServiceList.isNotEmpty)
                  ListView.builder(
                    itemCount: suggestServiceController.suggestedServiceList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return SuggestServiceItemView(
                        suggestedService: suggestServiceController.suggestedServiceList[index],
                        index: index,
                      );
                    },
                  )
                else
                  SizedBox(
                    height: Get.height * 0.8,
                    child: Center(
                      child: Text(
                        'no_service_request_yet'.tr,
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
