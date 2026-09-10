import 'package:demandium_provider/utils/core_export.dart';

class EmptyFAQWidget extends StatelessWidget {
  const EmptyFAQWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'no_data_found'.tr,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ),
    );
  }
}
