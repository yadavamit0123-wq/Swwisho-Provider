import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:demandium_provider/feature/service_details/model/service_faq_model.dart';
import 'package:demandium_provider/feature/service_details/model/variant_model.dart';


enum ServiceTabControllerState {serviceOverview,priceTable,faq,review}

class ServiceDetailsController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService{
  final ServiceDetailsRepo serviceDetailsRepo;
  ServiceDetailsController({required this.serviceDetailsRepo});

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  List<VariantModel> _variantList=[];
  List<VariantModel> get variantList => _variantList;

  ServiceDetailsModel? serviceDetailsModel;
  ServiceFaqModel? serviceFaqModel;

  final List<Widget> myTabs = [
    Tab(text: 'overview'.tr),
    Tab(text: 'price_table'.tr),
    Tab(text: 'FAQs'.tr),
    Tab(text: 'review'.tr),
  ];

  TabController? controller;
  var servicePageCurrentState = ServiceTabControllerState.serviceOverview;

  Future<void> getServiceDetailsData(String serviceId, {ServiceModel? summaryService}) async {
    _isLoading = true;
    serviceDetailsModel = null;
    _variantList = [];
    update();
    try {
      final resolvedId = serviceId.trim().isNotEmpty
          ? serviceId.trim()
          : (summaryService?.id?.trim() ?? '');
      if (resolvedId.isNotEmpty) {
        Response response = await serviceDetailsRepo.getServiceDetailsData(resolvedId);
        if (response.statusCode == 200 && response.body is Map) {
          final body = Map<String, dynamic>.from(response.body as Map);
          final content = _parseServiceContent(body);
          if (content != null) {
            serviceDetailsModel = ServiceDetailsModel(
              responseCode: body['response_code']?.toString(),
              message: body['message']?.toString(),
              content: content,
            );
            _buildVariantList(content);
          } else {
            try {
              serviceDetailsModel = ServiceDetailsModel.fromJson(body);
              if (serviceDetailsModel?.content != null) {
                _buildVariantList(serviceDetailsModel!.content!);
              }
            } catch (_) {}
          }
        }
      }
      if (serviceDetailsModel?.content == null && summaryService != null) {
        serviceDetailsModel = ServiceDetailsModel(content: summaryService);
        _buildVariantList(summaryService);
      }
    } catch (_) {
      if (summaryService != null) {
        serviceDetailsModel = ServiceDetailsModel(content: summaryService);
        _buildVariantList(summaryService);
      } else {
        serviceDetailsModel = null;
      }
    } finally {
      _isLoading = false;
      update();
    }
  }

  ServiceModel? _parseServiceContent(Map<String, dynamic> body) {
    dynamic node = body['content'];
    if (node is Map) {
      final map = Map<String, dynamic>.from(node);
      if (map['data'] is Map) {
        node = map['data'];
      } else if (map['service'] is Map) {
        node = map['service'];
      } else {
        node = map;
      }
    } else if (body['data'] is Map) {
      node = body['data'];
    } else if (body.containsKey('id') || body.containsKey('name')) {
      node = body;
    }
    if (node is! Map) return null;
    try {
      return ServiceModel.fromJson(Map<String, dynamic>.from(node));
    } catch (_) {
      return null;
    }
  }

  void _buildVariantList(ServiceModel content) {
    _variantList = [];
    final variations = content.variations ?? [];
    for (var element in variations) {
      if (element.variant == null || element.price == null) continue;
      _variantList.add(VariantModel(variantName: element.variant!, price: element.price!));
    }
    if (_variantList.isEmpty) {
      final react = content.variationsReactFormat ?? [];
      for (final element in react) {
        _variantList.add(VariantModel(
          variantName: element.variationName ?? '',
          price: element.variationPrice ?? 0,
        ));
      }
    }
    if (_variantList.isEmpty && (content.minBiddingPrice ?? 0) > 0) {
      _variantList.add(VariantModel(
        variantName: content.name ?? '',
        price: content.minBiddingPrice!,
      ));
    }
    _variantList.sort((a, b) => a.price.compareTo(b.price));
  }

  Future<void> getServiceFAQData(String serviceId) async {
    try {
      Response response = await serviceDetailsRepo.getServiceFAQData(serviceId);
      if(response.statusCode==200 && response.body is Map){
        serviceFaqModel = ServiceFaqModel.fromJson(Map<String, dynamic>.from(response.body));
        update();
      }
    } catch (_) {}
  }

  void updateServicePageCurrentState(ServiceTabControllerState serviceDetailsTabControllerState, {bool shouldUpdate = true}){
    servicePageCurrentState = serviceDetailsTabControllerState;
    if(shouldUpdate){
      update();
    }else{
      controller?.index = 0;
    }

  }

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: myTabs.length);
  }

}