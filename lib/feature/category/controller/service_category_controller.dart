import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class ServiceCategoryController extends GetxController implements GetxService{
  final ServiceRepo serviceRepo;
  ServiceCategoryController({required this.serviceRepo});

  int  _selectedCategoryIndex= 0;
  int  _selectedSubsCategoryIndex = 0;
  int _subscriptionIndex=-1;
  int get  selectedSubscriptionIndex => _subscriptionIndex;


  int get  selectedCategory => _selectedCategoryIndex;
  int get  selectedSubsCategoryIndex =>_selectedSubsCategoryIndex;

  bool _isSubCategoryLoading = false;
  bool _isSubscriptionLoading = false;
  bool _isPaginationLoading = false;
  int? subscriptionStatus;


  bool get isSubCategoryLoading => _isSubCategoryLoading;
  bool get isSubscriptionLoading => _isSubscriptionLoading;
  bool get isPaginationLoading => _isPaginationLoading;

  List<ServiceCategoryModel> ? serviceCategoryList;
  List<ServiceSubCategoryModel> serviceSubCategoryList =[];

  List<ServiceModel>? _serviceList;
  List<ServiceModel>? get serviceList => _serviceList;

  List<ServiceModel>? _searchServiceList;
  List<ServiceModel>? get searchServiceList => _searchServiceList;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  int _offset = 1;
  int get offset => _offset;

  int _pageSize =1;
  int get pageSize => _pageSize;




  final ScrollController scrollController = ScrollController();
  var searchController = TextEditingController();

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize ) {
          if(serviceCategoryList != null && serviceCategoryList!.isNotEmpty) getSubCategoryList(offset: _offset+1,isFromPagination: true);
        }
      }
    });
  }
  
  Future<void> getCategoryList({bool shouldUpdate = true, bool reloadSubcategory = false}) async {

    Response response = await serviceRepo.getCategoryList();
    if(response.statusCode == 200){
      serviceCategoryList = [];
      dynamic list;
      final body = response.body;
      if (body is Map) {
        final content = body['content'];
        if (content is Map) {
          list = content['data'] ?? content['categories'];
        } else if (content is List) {
          list = content;
        }
        list ??= body['data'];
      }
      if (list is List) {
        for (var category in list) {
          try {
            if (category is Map) {
              serviceCategoryList!.add(ServiceCategoryModel.fromJson(Map<String, dynamic>.from(category)));
            }
          } catch (_) {}
        }
      }

      if((serviceCategoryList!.isNotEmpty && serviceSubCategoryList.isEmpty) || reloadSubcategory){
        getSubCategoryList(offset: 1, isFromPagination: false);
      }
    }
    else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  int _subcategoryApitHitCount = 0;

  Future<void> getSubCategoryList({required int offset, bool isFromPagination = false, String? categoryId}) async {

    _subcategoryApitHitCount++;
    _offset = offset;
    if(!isFromPagination){
      serviceSubCategoryList = [];
      _isSubCategoryLoading = true;
      update();
    }
    _isPaginationLoading = true;
    update();

    Response response = await serviceRepo.getSubCategoryList(serviceCategoryList?[selectedCategory].id.toString() ?? "", offset);
    if(response.statusCode == 200){
      if(!isFromPagination){
        serviceSubCategoryList = [];
      }

      try {
        dynamic list;
        final body = response.body;
        if (body is Map) {
          final content = body['content'];
          if (content is Map) {
            list = content['data'] ?? content['sub_categories'] ?? content['childes'];
            _pageSize = int.tryParse('${content['last_page']}') ?? _pageSize;
          } else if (content is List) {
            list = content;
          }
          list ??= body['data'];
        }
        if (list is List) {
          for (var subCategory in list) {
            try {
              if (subCategory is Map) {
                serviceSubCategoryList.add(ServiceSubCategoryModel.fromJson(Map<String, dynamic>.from(subCategory)));
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
    }
    else {
      ApiChecker.checkApi(response);
    }
    _subcategoryApitHitCount --;
    _isSubCategoryLoading = false;
    _isPaginationLoading = false;

    if( _subcategoryApitHitCount == 0){
      update();
    }

  }


  bool _subscriptionApiSuccess(Response response) {
    if (response.statusCode != 200) return false;
    if (response.body is! Map) return true;
    final code = response.body['response_code']?.toString() ?? '';
    if (code.isEmpty) return true;
    return code == 'default_200' || code.contains('success') || code.endsWith('_200');
  }

  String _responseMessage(Response response, {required bool success}) {
    if (response.body is Map && response.body['message'] != null) {
      return response.body['message'].toString();
    }
    return success ? 'successfully_updated'.tr : 'something_went_wrong'.tr;
  }

  Future<void> _refreshSubscriptionsAfterChange() async {
    try {
      if (Get.isRegistered<SubcategorySubscriptionController>()) {
        await Get.find<SubcategorySubscriptionController>().getMySubscriptionData(1, false);
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().getDashboardData();
      }
    } catch (_) {}
  }

  Future<ResponseModel> changeSubscriptionStatus(String id, int index,{String fromPage = ""}) async {
      _isSubscriptionLoading = true;
      update();
      try {
      Response response  = await serviceRepo.changeSubscriptionStatus(id);
      final success = _subscriptionApiSuccess(response);

      if(success){
        final unsubscribing = fromPage == "category"
            ? serviceSubCategoryList[index].isSubscribed == 1
            : true;

        if(fromPage == "category"){
          serviceSubCategoryList[index].isSubscribed = unsubscribing ? 0 : 1;
        }

        if (unsubscribing) {
          if(fromPage == "dashboard"){
            Get.find<DashboardController>().removeSubscriptionItem(id);
            Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(id);
            Get.back();
          } else if (fromPage == "subscription_list"){
            Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(id);
            Get.find<DashboardController>().removeSubscriptionItem(id);
          } else if (fromPage == "subscription_details"){
            Get.find<SubcategorySubscriptionController>().removeSubscriptionItem(id);
            Get.find<DashboardController>().removeSubscriptionItem(id);
            Get.back();
          } else {
            await _refreshSubscriptionsAfterChange();
          }
        } else {
          await _refreshSubscriptionsAfterChange();
        }

        changeSubscriptionIndex(-1);
        return ResponseModel(true, _responseMessage(response, success: true));
      } else{
        changeSubscriptionIndex(-1);
        ApiChecker.checkApi(response);
        return ResponseModel(false, _responseMessage(response, success: false));
      }
      } catch (_) {
        return ResponseModel(false, 'something_went_wrong'.tr);
      } finally {
        _isSubscriptionLoading = false;
        update();
      }
  }

  Future<void> getServiceListBasedOnSubcategory({required String subCategoryId, bool shouldUpdate = false}) async {

    _serviceList = null;
    _searchServiceList = null;
    if(shouldUpdate){
      update();
    }

    try {
      Response response = await serviceRepo.getServiceListBasedOnSubcategory(subCategoryId);
      if(response.statusCode == 200){
        _serviceList = [];
        final list = _extractServiceRows(response.body);
        if (list != null) {
          for (var service in list) {
            try {
              if (service is Map) {
                _serviceList?.add(ServiceModel.fromJson(Map<String, dynamic>.from(service)));
              }
            } catch (_) {}
          }
        }
      }
      else {
        _serviceList = [];
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _serviceList = [];
    }

    update();
  }

  List<dynamic>? _extractServiceRows(dynamic body) {
    if (body is! Map) return null;
    final content = body['content'];
    dynamic list;
    if (content is Map) {
      list = content['data'] ?? content['services'] ?? content['service'];
    } else if (content is List) {
      list = content;
    }
    list ??= body['data'];
    if (list is List) return list;
    return null;
  }

  Future<void> getSearchedServiceListBasedOnSubcategory({required String subCategoryId, bool shouldUpdate = false, String? queryText}) async {

    _searchServiceList = null;
    _isSearchComplete = false;
    update();

    try {
      Response response = await serviceRepo.getServiceListBasedOnSubcategory(subCategoryId,queryText: queryText ?? "");
      if(response.statusCode == 200){
        _searchServiceList = [];
        final list = _extractServiceRows(response.body);
        if (list != null) {
          for (var service in list) {
            try {
              if (service is Map) {
                _searchServiceList?.add(ServiceModel.fromJson(Map<String, dynamic>.from(service)));
              }
            } catch (_) {}
          }
        }
      }
      else {
        _searchServiceList = [];
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      _searchServiceList = [];
    }

    _isSearchComplete = true;
    update();
  }


  void changeCategory(int categoryIndex, {bool isUpdate = true}){
    _selectedCategoryIndex = categoryIndex;
    if(isUpdate) {
      update();
    }
  }

  void changeSubscriptionCategoryIndex(int categoryIndex, {bool isUpdate = true}){
    _selectedSubsCategoryIndex = categoryIndex;
    if(isUpdate) {
      update();
    }
  }

  void changeSubscriptionIndex(int subscriptionIndex){
    _subscriptionIndex = subscriptionIndex;
    update();
  }

  void toggleSubscriptionStatus(int subscriptionStatus){
    subscriptionStatus= subscriptionStatus;
    update();
  }
  void showSuffixIcon(context,String text){
    if(text.isNotEmpty){
      _isActiveSuffixIcon = true;
    }else if(text.isEmpty){
      _isActiveSuffixIcon = false;
    }
    update();
  }

  void clearSearchController({bool shouldUpdate = true} ){
    searchController.clear();
    _isSearchComplete = true;
    _searchServiceList = null;
    _isActiveSuffixIcon = false;
    if(shouldUpdate){
      update();
    }
  }

}