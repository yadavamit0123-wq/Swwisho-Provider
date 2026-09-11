import 'package:demandium_provider/utils/core_export.dart';

class NonEditableTextField extends StatelessWidget {
  final String text;

  const NonEditableTextField({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: Get.isDarkMode ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: robotoRegular.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}
