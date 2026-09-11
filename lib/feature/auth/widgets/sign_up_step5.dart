import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class SignUpStep5 extends StatelessWidget {
  const SignUpStep5({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GetBuilder<SplashController>(builder: (splashController) {
        final config = splashController.configModel.content;
        final paymentMethodList = config?.paymentMethodList ?? [];
        final showFreeTrial = config?.subscriptionFreeTrail == 1;
        final showDigitalPayment = config?.digitalPayment == 1 && paymentMethodList.isNotEmpty;

        return GetBuilder<SignUpController>(builder: (signUpController) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: ClampingScrollPhysics(),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  Text(
                    'free_trail_hint_text'.tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                  if (showFreeTrial)
                    BusinessPlanCard(
                      icon: Images.subscriptionIcon,
                      title: 'free_trail',
                      subtitle: 'you_can_pay_the_due_in_later',
                      isSelected: signUpController.selectedSubscriptionPaymentType == SubscriptionPaymentType.freeTrail,
                      onTap: () => signUpController.updateSubscriptionPaymentType(SubscriptionPaymentType.freeTrail),
                    ),

                  if (showFreeTrial && showDigitalPayment)
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                  if (showDigitalPayment)
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).disabledColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                        border: Border.all(color: Theme.of(context).disabledColor.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child: Row(
                              children: [
                                Text('${'pay_via_online'.tr} ', style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault)),
                                Flexible(
                                  child: Text(
                                    "(${'faster_and_secure_way_to_pay_bill'.tr})",
                                    style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall,
                                      color: Theme.of(context).hintColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  DigitalPaymentButtonWidget(
                                    isSelected: signUpController.selectedDigitalPaymentMethodIndex == index,
                                    paymentMethod: paymentMethodList[index],
                                  ),
                                  Positioned.fill(
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                      child: CustomInkWell(
                                        onTap: () {
                                          signUpController.updateSubscriptionPaymentType(SubscriptionPaymentType.digital);
                                          signUpController.updateDigitalPaymentMethodIndex(index);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            shrinkWrap: true,
                            itemCount: paymentMethodList.length,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          ),
                        ],
                      ),
                    ),

                  if (!showFreeTrial && !showDigitalPayment)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraLarge),
                      child: Text(
                        'no_payment_method_available'.tr,
                        style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodySmall?.color),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  const SizedBox(height: Dimensions.paddingSizeLarge),
                ],
              ),
            ),
          );
        });
      }),
    );
  }
}
