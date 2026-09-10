import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class WalletCashCard extends StatelessWidget {
  final JustTheController toolTipController;
  const WalletCashCard(this.toolTipController, {super.key});

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
      child: Container(height: 160, width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.lightBlue.shade100,width:Get.isDarkMode? 0.6:1),
              color: Theme.of(context).cardColor
          ),
          child: Stack(
            children: [
              Container(height: 160, width:  MediaQuery.of(context).size.width*.65,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topRight: Radius.circular(300),bottomLeft: Radius.circular(20),topLeft: Radius.circular(20)),
                  gradient: LinearGradient(begin:Alignment.bottomCenter,end: Alignment.topCenter,
                    colors: Get.isDarkMode?[Colors.transparent,Colors.transparent]:[Colors.blue.shade50,Colors.white],
                  ),
                ),
              ),
              GetBuilder<UserProfileController>(builder: (userProfileController) {

                double transactionAmount = 0;
                double receivableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0" ) ?? 0;
                double payableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0") ?? 0 ;
                double newAccountBalance = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.newAccountBalance.toString() ?? "0") ?? 0 ;

                transactionAmount =  userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);


                TransactionType transactionType =  userProfileController.getTransactionType(payableAmount, receivableAmount);

                if(transactionType == TransactionType.adjust){
                  transactionAmount = payableAmount;
                }else{
                  transactionAmount =  userProfileController.getTransactionAmountAmount(payableAmount, receivableAmount);
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'total_balance'.tr,
                          style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),

                        JustTheTooltip(
                          backgroundColor: Colors.black87,
                          controller: toolTipController,
                          preferredDirection: AxisDirection.down,
                          tailLength: 14, tailBaseWidth: 20,
                          content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            child:  Text(
                                'minimum_wallet_recharge_hint'.tr,
                                style: robotoRegular.copyWith(color: Colors.white,)
                            ),
                          ),
                          child:  InkWell(
                            onTap: ()=> toolTipController.showTooltip(),
                            child: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 18,),
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: Dimensions.paddingSizeSmall,),

                    Text(PriceConverter.convertPrice(newAccountBalance),
                      style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge * 1.2,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    // GetBuilder<TransactionController>(builder: (transactionController){
                    //   return  CustomButton(width: 220, height: 40,
                    //     isLoading: transactionController.isLoading,
                    //     btnTxt: 'Deposit Amount'.tr,
                    //     onPressed: () {
                    //       print('tranc........... = $newAccountBalance');
                    //       showModalBottomSheet(
                    //         context: context,
                    //         useRootNavigator: true,
                    //         isScrollControlled: true,
                    //         backgroundColor: Colors.transparent,
                    //         builder: (context) => PaymentMethodDialog(amount: newAccountBalance),
                    //       );
                    //     },
                    //   );
                    // }),

                    GetBuilder<TransactionController>(builder: (transactionController) {
                      TextEditingController amountController = TextEditingController();

                      return CustomButton(
                        width: 220,
                        height: 40,
                        isLoading: transactionController.isLoading,
                        btnTxt: 'Deposit Amount'.tr,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: Text(
                                  "Add fund to wallet",
                                  style: robotoBold.copyWith(),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                     Text(
                                      "Add fund from secured digital payment gateways",
                                      style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: amountController,
                                      hintText: "Enter Amount",
                                      title: "Amount",
                                      inputType: TextInputType.number,
                                    ),
                                  ],
                                ),
                                actions: [
                                  CustomButton(

                                    onPressed: () {
                                      String amountText = amountController.text.trim();

                                      if (amountText.isEmpty) {
                                        showCustomSnackBar("Please enter amount".tr,type: ToasterMessageType.info);
                                      }else if((double.tryParse(amountText) ?? 0) < AppConstants.minimumWalletRecharge){
                                        showCustomSnackBar('minimum_wallet_recharge_error'.tr,type: ToasterMessageType.info);
                                      } else {
                                        Navigator.pop(ctx);

                                        double newAccountBalance = double.tryParse(amountText) ?? 0;
                                        // double percentage = 2.36;
                                        // var charge = newAccountBalance * (percentage / 100);
                                        // var charge = newAccountBalance * 0.0236;
                                        showModalBottomSheet(
                                          context: context,
                                          useRootNavigator: true,
                                          isScrollControlled: true,
                                          backgroundColor:     Colors.transparent,
                                          builder: (context) => PaymentMethodDialog(
                                            amount: newAccountBalance,
                                          ),
                                        );
                                      }
                                    },
                                    color: Theme.of(context).primaryColor.withValues(alpha: 0.8),
                                    btnTxt: 'Continue',
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    })

                  ],
                );
              }),
            ],
          )
      ),
    );
  }

  void showRechargeAlertDialog(BuildContext context, {required VoidCallback onContinue}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Warning Icon
            Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 50,
            ),
            SizedBox(height: 16),
            // Title
            Text(
              "Recharge Alert",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 12),
            // Message
            Text(
              "minimum_wallet_recharge_error".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 24),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Cancel Button
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
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
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      onContinue();
                    },
                    child: Text(
                      "Continue",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }
}
