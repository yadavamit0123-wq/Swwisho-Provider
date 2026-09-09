import 'package:demandium_provider/feature/profile/view/wallet_information/widgets/wallet_cash_card.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class WalletInformation extends StatefulWidget {
  const WalletInformation({super.key});
  @override
  State<WalletInformation> createState() => _WalletInformationState();
}
class _WalletInformationState extends State<WalletInformation> {

  JustTheController tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();
    Get.find<UserProfileController>().getProviderInfo(reload: true);
    Get.find<UserProfileController>().updateNumberOfTimeShowingDialog();

  }
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      onRefresh: ()async => Get.find<UserProfileController>().getProviderInfo(reload: true),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "wallet_information".tr),
        body: GetBuilder<UserProfileController>(builder: (userProfileController){

          double receivableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? "0" ) ?? 0;
          double payableAmount = double.tryParse(userProfileController.providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? "0") ?? 0 ;
          TransactionType transactionType =  userProfileController.getTransactionType(payableAmount, receivableAmount);

          print('trans type = ${transactionType.name}');
          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    // transactionType == TransactionType.none ? const SizedBox(height: Dimensions.paddingSizeDefault,) : WalletCashCard(tooltipController),
                    WalletCashCard(tooltipController),

                  ],
                ),
              ),

            ],
          );
        }),
      ),
    );
  }
}
