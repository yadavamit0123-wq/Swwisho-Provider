import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class  SubcategorySubscriptionController extends GetxController implements GetxService{
  final SubscriptionRepo subscriptionRepo;
  SubcategorySubscriptionController({required this.subscriptionRepo});

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  bool _isPaginationLoading= false;
  bool get isPaginationLoading => _isPaginationLoading;

  bool _isSubscribeButtonLoading= false;
  bool get isSubscribeButtonLoading => _isSubscribeButtonLoading;

  int _subscriptionIndex =- 1;
  int get  selectedSubscriptionIndex => _subscriptionIndex;

  List<SubscriptionModelData> _subscriptionList=[];
  List<SubscriptionModelData> get subscriptionList=> _subscriptionList;

  int? _pageSize;
  int? get pageSize => _pageSize;

  int _offset = 1;
  int get offset => _offset;

  int _totalSubscription = 0;
  int? get totalSubscription => _totalSubscription;

  ScrollController scrollController = ScrollController();

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      int selectedSubCategory =  Get.find<ServiceCategoryController>().selectedSubsCategoryIndex;
      List<ServiceCategoryModel> ? serviceCategoryList = Get.find<ServiceCategoryController>().serviceCategoryList;

      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getMySubscriptionData(offset+1, true, categoryId : selectedSubCategory == 0 ? '' : serviceCategoryList?[selectedSubCategory].id.toString());
        }
      }
    });
  }

  Future<void> getMySubscriptionData(int offset, bool isFormPagination, {String? categoryId}) async {
    _offset = offset;
    if(!isFormPagination){
      _subscriptionList =[];
      _isLoading = true;
      update();
    }
    else{
      _isPaginationLoading = true;
      update();
    }
    try {
      Response response = await subscriptionRepo.getSubcategorySubscriptionList(offset, categoryId: categoryId);
      if(response.statusCode==200 && response.body['response_code']=="default_200"){
        dynamic list;
        final content = response.body['content'];
        if (content is Map) {
          list = content['data'];
          _pageSize = int.tryParse(content['last_page']?.toString() ?? '');
          if(categoryId == null){
            _totalSubscription = int.tryParse(content['total']?.toString() ?? '') ?? _totalSubscription;
          }
        } else if (content is List) {
          list = content;
        }
        if (list is List) {
          for (var element in list) {
            try {
              if (element is Map && element['sub_category'] != null) {
                _subscriptionList.add(SubscriptionModelData.fromJson(Map<String, dynamic>.from(element)));
              }
            } catch (_) {}
          }
        }
      } else if(response.statusCode== 401){
        ApiChecker.checkApi(response);
      }
    } catch (_) {}
    _isPaginationLoading = false;
    _isLoading = false;
    update();
  }


  void removeSubscriptionItem(String id, {bool shouldUpdate = true}){

    for (var element in _subscriptionList) {
      if(element.subCategoryId == id){
        _subscriptionList.remove(element);
        _totalSubscription --;
        break;
      }
    }

    if(shouldUpdate){
      update();
    }
  }

  Future<void> unsubscribeCategory(String id,int index) async {
    _isSubscribeButtonLoading = true;
    update();
    Response response = await subscriptionRepo.changeSubscriptionStatus(id);
    if(response.statusCode==200){
      subscriptionList.removeAt(index);
      _totalSubscription--;
    }
    _isSubscribeButtonLoading = false;
    update();
  }

  void changeSubscriptionIndex(int subscriptionIndex){
    _subscriptionIndex = subscriptionIndex;
    update();
  }
}