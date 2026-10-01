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
        final lastPage = _pageSize ?? 1;
        if(_offset < lastPage) {
          getMySubscriptionData(offset+1, true, categoryId : selectedSubCategory == 0 ? null : serviceCategoryList?[selectedSubCategory].id.toString());
        }
      }
    });
  }

  bool _isAllCategoryFilter(String? categoryId) =>
      categoryId == null || categoryId.trim().isEmpty;

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
      if(response.statusCode==200 && response.body is Map){
        final parsed = _parseSubscriptionPayload(Map<String, dynamic>.from(response.body));
        if(!isFormPagination){
          _subscriptionList = parsed.items;
        } else {
          _subscriptionList.addAll(parsed.items);
        }
        _pageSize = parsed.lastPage ?? _pageSize ?? 1;
        if(_isAllCategoryFilter(categoryId) && parsed.total != null){
          _totalSubscription = parsed.total!;
        }
      } else if(response.statusCode== 401){
        ApiChecker.checkApi(response);
      } else if (response.body is Map) {
        ApiChecker.checkApi(response);
      }
    } catch (_) {}
    _isPaginationLoading = false;
    _isLoading = false;
    update();
  }

  _SubscriptionParseResult _parseSubscriptionPayload(Map<String, dynamic> body) {
    final items = <SubscriptionModelData>[];
    int? lastPage;
    int? total;

    try {
      final model = MySubscriptionModel.fromJson(body);
      final content = model.content;
      if (content?.data != null) {
        for (final row in content!.data!) {
          if (row.subCategory != null || (row.subCategoryId ?? '').isNotEmpty) {
            items.add(row);
          }
        }
        lastPage = content.lastPage;
        total = content.total;
        return _SubscriptionParseResult(items: items, lastPage: lastPage, total: total);
      }
    } catch (_) {}

    dynamic content = body['content'];
    dynamic list;
    if (content is Map) {
      list = content['data'] ?? content['subscriptions'];
      lastPage = int.tryParse(content['last_page']?.toString() ?? '');
      total = int.tryParse(content['total']?.toString() ?? '');
    } else if (content is List) {
      list = content;
    }

    if (list is List) {
      for (final element in list) {
        if (element is! Map) continue;
        try {
          final row = SubscriptionModelData.fromJson(Map<String, dynamic>.from(element));
          if (row.subCategory != null || (row.subCategoryId ?? '').isNotEmpty) {
            items.add(row);
          }
        } catch (_) {}
      }
    }

    return _SubscriptionParseResult(items: items, lastPage: lastPage, total: total);
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
    try {
      Response response = await subscriptionRepo.changeSubscriptionStatus(id);
      if(response.statusCode==200){
        if (index >= 0 && index < subscriptionList.length) {
          subscriptionList.removeAt(index);
          if (_totalSubscription > 0) {
            _totalSubscription--;
          }
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (_) {}
    _isSubscribeButtonLoading = false;
    update();
  }

  void changeSubscriptionIndex(int subscriptionIndex){
    _subscriptionIndex = subscriptionIndex;
    update();
  }
}

class _SubscriptionParseResult {
  final List<SubscriptionModelData> items;
  final int? lastPage;
  final int? total;

  _SubscriptionParseResult({
    required this.items,
    this.lastPage,
    this.total,
  });
}