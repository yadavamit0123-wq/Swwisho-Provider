import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class BookingSetupWidget extends StatelessWidget {
  const BookingSetupWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BusinessSettingController>(builder: ( businessSettingController){

      final config = Get.find<SplashController>().configModel.content;

      return Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column( children: [

                  ListView.builder(itemBuilder: (context, index){
                    return SwitchButton(
                      titleText: businessSettingController.settingItem[index].settingTitle!,
                      value: businessSettingController.settingItem[index].settingsValue!,
                      onTap: (bool value) {
                        businessSettingController.toggleSettingsValue(index , value == true ? 1 : 0);
                      },
                      tooltipController: businessSettingController.settingItem[index].toolTipController!,
                      tootTipText: businessSettingController.settingItem[index].toolTipText!,
                    );},
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: businessSettingController.settingItem.length,
                  ),

                  SizedBox(height: Dimensions.paddingSizeSmall),

                  config?.serviceAtProviderPlace == 1 ? Container(
                    decoration: BoxDecoration(
                      boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('service_location'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                      SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text('service_location_business_setting_hint'.tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
                      ),
                      SizedBox(height: Dimensions.paddingSizeDefault),

                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                        ),

                        child: Column(children: [

                          _CheckBoxWidget(
                            title: "customer_location",
                            subTitle: "by_check_this_option_you_will_able_to_provide_service_at_customer_location",
                            value: businessSettingController.isActiveServiceInCustomerLocation,
                            onChanged: (bool? newValue) {
                              if(!businessSettingController.isActiveServiceInProviderLocation &&  businessSettingController.isActiveServiceInCustomerLocation){
                               showCustomSnackBar("you_can_not_disable_both_option_at_a_time".tr);
                              }else{
                                businessSettingController.updateServiceLocationValue(value: (newValue ?? false));
                              }

                            },
                          ),

                          Opacity(
                            opacity: config?.serviceAtProviderPlace == 1 ? 1.0 :  0.5,
                            child: _CheckBoxWidget(
                              title: "your_location",
                              subTitle: "by_check_this_option_you_will_able_to_provide_service_at_business_location",
                              value: businessSettingController.isActiveServiceInProviderLocation,
                              onChanged: (bool? newValue) {
                                if(config?.serviceAtProviderPlace == 1){
                                  if(!businessSettingController.isActiveServiceInCustomerLocation &&  businessSettingController.isActiveServiceInProviderLocation){
                                    showCustomSnackBar("you_can_not_disable_both_option_at_a_time".tr);
                                  }else{
                                    businessSettingController.updateServiceLocationValue(value: (newValue ?? false), isCustomerLocation: false);
                                  }
                                }else{
                                  showCustomSnackBar("admin_has_disable_this_option".tr);
                                }
                              },
                            ),
                          ),

                        ]),
                      ),
                    ]),
                  ) : SizedBox()

                ]),
              ),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault,),

            CustomButton(btnTxt: "update_settings".tr,
              onPressed: ()=> businessSettingController.updateBookingSettingsIntoServer(),
              isLoading: businessSettingController.isLoading,
            )
          ],
        ),
      );
    });
  }
}

class _CheckBoxWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  const _CheckBoxWidget({ required this.title, required this.subTitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row( crossAxisAlignment: CrossAxisAlignment.start, children: [
        Checkbox(
          value: value, onChanged: onChanged,
          activeColor: Theme.of(context).primaryColor,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 5, children: [
              Text(title.tr, style: robotoMedium),
              Text(
                subTitle.tr,
                style: robotoRegular.copyWith(
                  fontSize: Dimensions.fontSizeSmall,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  height: 1.5
                ),
              ),
            ]),
          ),
        ),

        SizedBox(width: 15)
      ]),
    );
  }
}

