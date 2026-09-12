import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? htmlType;
  final String? fromNotificationPage;
  const HtmlViewerScreen({super.key, @required this.htmlType,this.fromNotificationPage});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}
class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  bool _isUrlOnly(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final trimmed = value.trim();
    return trimmed.startsWith('http://') || trimmed.startsWith('https://');
  }

  String? _fallbackHtml() {
    final config = Get.find<SplashController>().customerConfigModel.content;
    if (config == null) return null;
    String? value;
    switch (widget.htmlType) {
      case HtmlType.privacyPolicy:
        value = config.privacyPolicy;
        break;
      case HtmlType.termsAndCondition:
        value = config.termsAndConditions;
        break;
      case HtmlType.aboutUs:
        value = config.aboutUs;
        break;
      case HtmlType.refundPolicy:
        value = config.refundPolicy;
        break;
      case HtmlType.cancellationPolicy:
        value = config.cancellationPolicy;
        break;
      default:
        return null;
    }
    if (_isUrlOnly(value)) return null;
    return value;
  }

  Widget _buildHtmlContent(String data, {String image = ''}) {
    data = data.replaceAll('href=', 'target="_blank" href=');
    return Center(
      child: Container(
        width: Dimensions.webMaxWidth,
        height: MediaQuery.of(context).size.height,
        color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor.withValues(alpha:Get.isDarkMode?0.5:1),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: Dimensions.paddingSizeSmall),
              if (image.isNotEmpty)
                SizedBox(
                  height: 80,
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    child: CustomImage(fit: BoxFit.cover, image: image),
                  ),
                ),
              Container(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                margin: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(1, 1),
                      blurRadius: 5,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                    )
                  ],
                ),
                child: HtmlWidget(
                  data,
                  textStyle: robotoRegular.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha:0.7),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: widget.htmlType == HtmlType.termsAndCondition ? 'terms_conditions'.tr
            : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr
            : widget.htmlType == HtmlType.privacyPolicy ? 'privacy_policy'.tr
            : widget.htmlType == HtmlType.refundPolicy ? 'refund_policy'.tr
            : widget.htmlType == HtmlType.cancellationPolicy ? 'cancellation_policy'.tr
            : 'no_data_found'.tr,
        onBackPressed:
        widget.fromNotificationPage!='null'?
            (){
          Get.offAllNamed(RouteHelper.initial);
        }:null
      ),
      body: GetBuilder<HtmlViewController>(
        initState: (state){
          Get.find<HtmlViewController>().getPagesContent();
        },
        builder: (htmlViewController){
          String? data;
          String? image;
          if(htmlViewController.pagesContent != null){
            data = widget.htmlType == HtmlType.termsAndCondition ? htmlViewController.pagesContent?.termsAndConditions?.liveValues ?? ""
                : widget.htmlType == HtmlType.aboutUs ? htmlViewController.pagesContent?.aboutUs?.liveValues??""
                : widget.htmlType == HtmlType.privacyPolicy ? htmlViewController.pagesContent?.privacyPolicy?.liveValues??""
                : widget.htmlType == HtmlType.refundPolicy ? htmlViewController.pagesContent?.refundPolicy?.liveValues??""
                : widget.htmlType == HtmlType.cancellationPolicy ? htmlViewController.pagesContent?.cancellationPolicy?.liveValues??""
                : null;

            image = widget.htmlType == HtmlType.termsAndCondition ? htmlViewController.pagesContent?.images?.termsAndConditions ??""
                : widget.htmlType == HtmlType.aboutUs ? htmlViewController.pagesContent?.images?.aboutUs ?? ""
                : widget.htmlType == HtmlType.privacyPolicy ? htmlViewController.pagesContent?.images?.privacyPolicy ?? ""
                : widget.htmlType == HtmlType.refundPolicy ? htmlViewController.pagesContent?.images?.refundPolicy ?? ""
                : widget.htmlType == HtmlType.cancellationPolicy ? htmlViewController.pagesContent?.images?.cancellationPolicy ?? ""
                : null;

            if(data != null && data.isNotEmpty && !_isUrlOnly(data)) {
              return _buildHtmlContent(data, image: image ?? '');
            }
          }

          final fallback = _fallbackHtml();
          if (fallback != null && fallback.isNotEmpty && !_isUrlOnly(fallback)) {
            return _buildHtmlContent(fallback);
          }

          if (htmlViewController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('no_data_found'.tr, style: robotoRegular),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                CustomButton(
                  btnTxt: 'retry'.tr,
                  onPressed: () => htmlViewController.getPagesContent(forceReload: true),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}