import 'package:demandium_provider/feature/dashboard/widgets/payment_method_dialog.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class CashOverflowDialog extends StatefulWidget {
  final double payablePercent;
  final double amount;

  const CashOverflowDialog({
    super.key,
    required this.payablePercent,
    required this.amount,
  });

  @override
  State<CashOverflowDialog> createState() => _CashOverflowDialogState();
}

class _CashOverflowDialogState extends State<CashOverflowDialog> {
  bool _isExpanded = false;

  void _toggleExpandStatus() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuspended = widget.payablePercent >= 100;
    final double progressValue = (widget.payablePercent / 100).clamp(0.0, 1.0);
    final String message = isSuspended ? 'your_limit_to_hold'.tr : 'looks_like_your'.tr;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radiusDefault),
              bottomLeft: Radius.circular(Dimensions.radiusDefault),
            ),
            color: isSuspended ? Theme.of(context).colorScheme.error : Colors.orange,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeExtraSmall,
            vertical: Dimensions.paddingSizeSmall + 1,
          ),
          child: InkWell(
            onTap: _toggleExpandStatus,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  _isExpanded ? Icons.arrow_forward_ios_sharp : Icons.arrow_back_ios_sharp,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall - 3),
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: progressValue),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 30,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 3,
                            backgroundColor: Colors.white,
                            strokeCap: StrokeCap.round,
                            color: const Color(0xF9F1AABB),
                          ),
                        ),
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: FittedBox(
                            child: Text(
                              "${widget.payablePercent.toInt()}%",
                              style: robotoBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                if (_isExpanded)
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.0, end: 1),
                    duration: const Duration(milliseconds: 130),
                    builder: (context, value, child) {
                      return Row(
                        children: [
                          if (value > 0.0)
                            SizedBox(
                              width: 180,
                              child: Text(
                                message,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Colors.white,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          if (value > 0.40)
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => PaymentMethodDialog(amount: widget.amount),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                  color: Colors.white,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.paddingSizeDefault,
                                  vertical: Dimensions.paddingSizeSmall - 2,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'pay_the_due'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                    Icon(
                                      Icons.arrow_forward_outlined,
                                      size: 15,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                        ],
                      );
                    },
                  ),
                const SizedBox(width: Dimensions.paddingSizeSmall + 2),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
