import 'package:demandium_provider/utils/core_export.dart';

class ServiceOverview extends StatelessWidget {
  final ServiceDetailsController serviceDetailsController;

  const ServiceOverview({super.key, required this.serviceDetailsController});

  @override
  Widget build(BuildContext context) {
    final description = serviceDetailsController.serviceDetailsModel?.content?.description ?? '';

    return SliverToBoxAdapter(
      child: Center(
        child: Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          color: Theme.of(context).cardColor,
          child: HtmlWidget(description),
        ),
      ),
    );
  }
}
