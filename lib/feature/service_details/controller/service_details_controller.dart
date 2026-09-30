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

  Future<void> getServiceDetailsData(String serviceId) async {
    _isLoading = true;
    serviceDetailsModel = null;
    _variantList = [];
    update();
    try {
      Response response = await serviceDetailsRepo.getServiceDetailsData(serviceId);
      if(response.statusCode==200 && response.body is Map){
        serviceDetailsModel = ServiceDetailsModel.fromJson(Map<String, dynamic>.from(response.body));
        _variantList = [];
        final variations = serviceDetailsModel?.content?.variations ?? [];
        for (var element in variations) {
          if (element.variant == null || element.price == null) continue;
          _variantList.add(VariantModel(variantName: element.variant!, price: element.price!));
        }
        if (_variantList.isEmpty) {
          final react = serviceDetailsModel?.content?.variationsReactFormat ?? [];
          for (final element in react) {
            _variantList.add(VariantModel(
              variantName: element.variationName ?? '',
              price: element.variationPrice ?? 0,
            ));
          }
        }
        if (_variantList.isEmpty && (serviceDetailsModel?.content?.minBiddingPrice ?? 0) > 0) {
          _variantList.add(VariantModel(
            variantName: serviceDetailsModel?.content?.name ?? '',
            price: serviceDetailsModel!.content!.minBiddingPrice!,
          ));
        }
        _variantList.sort((a, b) => a.price.compareTo(b.price));
      }
    } catch (_) {
      serviceDetailsModel = null;
    } finally {
      _isLoading = false;
      update();
    }
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