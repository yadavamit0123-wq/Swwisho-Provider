import 'package:demandium_provider/utils/core_export.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({super.key});

  @override
  State<AccountInformation> createState() => _AccountInformationState();
}

class _AccountInformationState extends State<AccountInformation> {
  @override
  void initState() {
    super.initState();
    final userController = Get.find<UserProfileController>();
    if (userController.providerModel == null) {
      userController.getProviderInfo(reload: true);
    } else {
      userController.refreshProviderInfoIfStale();
    }
    Get.find<TransactionController>().getWithdrawMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'account_information'.tr),
      body: RefreshIndicator(
        onRefresh: () async => Get.find<UserProfileController>().getProviderInfo(reload: true),
        child: GetBuilder<UserProfileController>(
          builder: (userController) {
            if (userController.providerModel == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            final account = userController.providerModel?.content?.providerInfo?.owner?.account;
            final receivableAmount = double.tryParse(account?.accountReceivable ?? '0') ?? 0;
            final payableAmount = double.tryParse(account?.accountPayable ?? '0') ?? 0;
            final pendingBalance = double.tryParse(account?.balancePending ?? '0') ?? 0;
            final totalWithdrawn = double.tryParse(account?.totalWithdrawn ?? '0') ?? 0;
            final cashCollection = double.tryParse(account?.cashCollection ?? '0') ?? 0;
            final transactionAmount = userController.getTransactionAmountAmount(payableAmount, receivableAmount);
            final transactionType = userController.getTransactionType(payableAmount, receivableAmount);

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                children: [
                  if(cashCollection > 0)
                    _AccountInfoCard(
                      title: 'cash_collection'.tr,
                      amount: cashCollection,
                      infoText: 'cash_collection'.tr,
                    ),
                  if(cashCollection > 0)
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  _AccountInfoCard(
                    title: 'account_payable'.tr,
                    amount: payableAmount,
                    infoText: 'account_payable_info'.tr,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _AccountInfoCard(
                    title: 'account_receivable'.tr,
                    amount: receivableAmount,
                    infoText: 'account_receivable_info'.tr,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _AccountInfoCard(
                    title: 'pending_withdrawn'.tr,
                    amount: pendingBalance,
                    infoText: 'pending_balance_info'.tr,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  _AccountInfoCard(
                    title: 'total_withdrawn'.tr,
                    amount: totalWithdrawn,
                    infoText: 'already_withdrawn_info'.tr,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transactionType == TransactionType.none
                              ? 'payable_balance'.tr
                              : 'final_payable_balance'.tr,
                          style: robotoMedium,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          PriceConverter.convertPrice(transactionAmount),
                          style: robotoBold.copyWith(
                            fontSize: Dimensions.fontSizeOverLarge,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Text(
                          _getBalanceDescription(transactionType),
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  if (transactionType != TransactionType.none)
                    GetBuilder<TransactionController>(
                      builder: (transactionController) {
                        return Column(
                          children: [
                            if (_shouldShowAdjustButton(transactionType))
                              CustomButton(
                                btnTxt: 'adjust'.tr,
                                isLoading: transactionController.isLoading,
                                onPressed: transactionController.adjustTransaction,
                              ),
                            if (_shouldShowAdjustButton(transactionType))
                              const SizedBox(height: Dimensions.paddingSizeDefault),
                            CustomButton(
                              btnTxt: _getPrimaryActionText(transactionType),
                              isLoading: transactionController.isLoading,
                              onPressed: () => _handlePrimaryAction(
                                transactionType,
                                transactionAmount,
                                transactionController,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  CustomButton(
                    btnTxt: 'see_withdraw_history'.tr,
                    transparent: true,
                    onPressed: () => Get.to(() => const TransactionScreen()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getBalanceDescription(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.payable:
      case TransactionType.adjustAndPayable:
        return 'payable_balance_text'.tr;
      case TransactionType.withdrawAble:
      case TransactionType.adjustWithdrawAble:
        return 'account_receivable_info'.tr;
      case TransactionType.adjust:
        return 'adjustable_balance_text'.tr;
      case TransactionType.none:
        return 'adjustable_balance_text'.tr;
    }
  }

  bool _shouldShowAdjustButton(TransactionType transactionType) {
    return transactionType == TransactionType.adjust ||
        transactionType == TransactionType.adjustAndPayable ||
        transactionType == TransactionType.adjustWithdrawAble;
  }

  String _getPrimaryActionText(TransactionType transactionType) {
    switch (transactionType) {
      case TransactionType.payable:
        return 'pay_now'.tr;
      case TransactionType.withdrawAble:
        return 'withdraw'.tr;
      case TransactionType.adjust:
        return 'adjust'.tr;
      case TransactionType.adjustAndPayable:
        return 'adjust_and_pay'.tr;
      case TransactionType.adjustWithdrawAble:
        return 'adjust_and_withdraw'.tr;
      case TransactionType.none:
        return 'empty_balance'.tr;
    }
  }

  Future<void> _handlePrimaryAction(
    TransactionType transactionType,
    double transactionAmount,
    TransactionController transactionController,
  ) async {
    switch (transactionType) {
      case TransactionType.payable:
        _openPaymentDialog(transactionAmount);
        break;
      case TransactionType.withdrawAble:
        Get.to(() => WithdrawRequestScreen(amount: transactionAmount));
        break;
      case TransactionType.adjust:
        await transactionController.adjustTransaction();
        break;
      case TransactionType.adjustAndPayable:
        await transactionController.adjustTransaction();
        _openPaymentDialog(transactionAmount);
        break;
      case TransactionType.adjustWithdrawAble:
        await transactionController.adjustTransaction();
        Get.to(() => WithdrawRequestScreen(amount: transactionAmount));
        break;
      case TransactionType.none:
        break;
    }
  }

  void _openPaymentDialog(double amount) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PaymentMethodDialog(amount: amount),
    );
  }
}

class _AccountInfoCard extends StatelessWidget {
  final String title;
  final double amount;
  final String infoText;

  const _AccountInfoCard({
    required this.title,
    required this.amount,
    required this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: robotoMedium),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                Text(
                  PriceConverter.convertPrice(amount),
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.info_outline_rounded, color: Theme.of(context).primaryColor),
            itemBuilder: (context) => [
              PopupMenuItem(value: infoText, child: Text(infoText, style: robotoRegular)),
            ],
          ),
        ],
      ),
    );
  }
}
