import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class AdvertisementSection extends StatelessWidget {
  const AdvertisementSection({super.key, });

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserProfileController>(builder: (userProfileController){
      return GetBuilder<DashboardController>(
        builder: (dashboardController) => Padding(padding: const EdgeInsets.only(top : Dimensions.paddingSizeLarge),
          child: Stack(children: [

            Container(width: Get.width,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadowOnlyBottom,
              ),
              child: Column(children:[

                const SizedBox(height: Dimensions.paddingSizeDefault,),
                Image.asset(Images.dashboardAdsIcon, height: 70,),

                const SizedBox(height: Dimensions.paddingSizeSmall,),
                Text("want_to_get_highlighted".tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge,)),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

                Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraMoreLarge * 1.5),
                  child: Text("create_ads_to_get_highlighted_on_the_app_and_web_browser".tr, style: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5)
                  ),textAlign: TextAlign.center,),
                ),

                const SizedBox(height: Dimensions.paddingSizeDefault,),

                CustomButton(btnTxt: "create_ads".tr, width: 170, onPressed: (){

                  Get.find<BusinessSubscriptionController>().openTrialEndBottomSheet().then((isTrial){
                    if(isTrial){
                      if(Get.find<UserProfileController>().checkAvailableFeatureInSubscriptionPlan(featureType: "advertisement")){
                        Get.find<AdvertisementController>().resetAllValues();
                        Get.to(()=>const CreateAdvertisementScreen(isEditScreen: false));
                      }
                    }
                  });

                },),

                const SizedBox(height: Dimensions.paddingSizeDefault,),

              ],),
            ),

            Positioned(top: 0, right: 0, child:  Image.asset(Images.adsRoundShape, height: 100,),),

            Positioned(bottom: 0, left: 0, child:  Image.asset(Images.adsCurveShape, height: 100,),)

          ],),
        ),
      );
    });
  }
}
