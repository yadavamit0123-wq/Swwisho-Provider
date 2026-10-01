import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class  BusinessSubscriptionController extends GetxController implements GetxService{
  final SubscriptionRepo subscriptionRepo;
  BusinessSubscriptionController({required this.subscriptionRepo,});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool? _paginationLoading = false;
  bool? get paginationLoading => _paginationLoading;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  int? _pageSize;
  int _offset = 1;

  int? get pageSize => _pageSize;
  int get offset => _offset;

  PackageSubscriptionModel? _packageSubscriptionModel;
  PackageSubscriptionModel? get packageSubscriptionModel => _packageSubscriptionModel;

  List<SubscriptionTransactionModel>? _transactionList ;
  List<SubscriptionTransactionModel>? get transactionList => _transactionList;

  List<SubscriptionTransactionModel>? _searchedTransactionList = [];
  List<SubscriptionTransactionModel>? get searchedTransactionList => _searchedTransactionList;


  int _selectedPackageIndex = 0;
  int get selectedPackageIndex => _selectedPackageIndex;

  int _selectedDigitalPaymentMethodIndex = -1;
  int get selectedDigitalPaymentMethodIndex => _selectedDigitalPaymentMethodIndex;

  final ScrollController scrollController = ScrollController();
  var searchController = TextEditingController();
  DateTimeRange? dateTimeRange;

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        final lastPage = _pageSize ?? 1;
        if (_offset < lastPage) {
          getSubscriptionTransactionList(_offset + 1, isFromPagination: true);
        }
      }
    });
  }


  Future<void> getSubscriptionPackageList({bool reload = false}) async {
    if(reload ||  _packageSubscriptionModel == null ){
      _packageSubscriptionModel = null ;
      update();
      try {
        Response response = await subscriptionRepo.getSubscriptionPackageList();
        if(response.statusCode == 200 && response.body is Map){
          _packageSubscriptionModel = PackageSubscriptionModel.fromJson(
            Map<String, dynamic>.from(response.body),
          );
        } else {
          _packageSubscriptionModel = PackageSubscriptionModel(subscriptionPackages: []);
        }
      } catch (_) {
        _packageSubscriptionModel = PackageSubscriptionModel(subscriptionPackages: []);
      }
      update();
    }
  }

  Future<void> getSubscriptionTransactionList(int offset, {bool isFromPagination = false,bool reload = false, bool isFirst = false}) async{
    _offset = offset;

    if(reload){
      if(!isFirst){
        update();
      }
    }
    if (_offset == 1 && !isFromPagination) {
      _transactionList = null;
    }
    try {
      Response response = await subscriptionRepo.getSubscriptionTransactionList(offset,);

      if(response.statusCode == 200 && response.body is Map){
        final body = Map<String, dynamic>.from(response.body);
        final content = body['content'];
        dynamic list;
        if (content is Map) {
          list = content['data'];
          _pageSize = int.tryParse(content['last_page']?.toString() ?? '') ?? _pageSize ?? 1;
        } else if (content is List) {
          list = content;
        }

        if(_offset==1){
          _transactionList = [];
        }
        _transactionList ??= [];
        if (list is List) {
          for (final channel in list) {
            if (channel is! Map) continue;
            try {
              _transactionList!.add(
                SubscriptionTransactionModel.fromJson(Map<String, dynamic>.from(channel)),
              );
            } catch (_) {}
          }
        }
      }else{
        if (_offset == 1) {
          _transactionList = [];
        }
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      if (_offset == 1) {
        _transactionList = [];
      }
    }

    _paginationLoading = false;
    _isLoading = false;
    update();
  }


  Future<void> getSearchedSubscriptionTransactionList({String? queryText, String? startDate, String? endDate}) async{

    _searchedTransactionList = null;
    _isSearchComplete = false;
    update();

    Response response = await subscriptionRepo.getSearchedSubscriptionTransactionList(queryText: queryText, startDate: startDate, endDate: endDate);

    if(response.statusCode == 200 && response.body is Map){
      _searchedTransactionList = [];
      final content = response.body['content'];
      final list = content is Map ? content['data'] : content is List ? content : null;
      if (list is List) {
        for (final channel in list) {
          if (channel is! Map) continue;
          try {
            _searchedTransactionList!.add(
              SubscriptionTransactionModel.fromJson(Map<String, dynamic>.from(channel)),
            );
          } catch (_) {}
        }
      }
    }else{
      _searchedTransactionList = [];
      ApiChecker.checkApi(response);
    }

    _isSearchComplete = true;
    update();
  }


  Future<ResponseModel> cancelSubscription({required String packageId}) async {
    try {
      Response response = await subscriptionRepo.cancelSubscription(packageId: packageId);
      if(response.statusCode == 200) {
        await Get.find<UserProfileController>().getProviderInfo(reload: true);
        final message = response.body is Map
            ? response.body['message']?.toString()
            : null;
        return ResponseModel(true, message ?? 'successfully_updated'.tr);
      }
      return ResponseModel(false, response.statusText ?? 'something_went_wrong'.tr);
    } catch (_) {
      return ResponseModel(false, 'something_went_wrong'.tr);
    }
  }


  Future<bool> openTrialEndBottomSheet() async {

    SubscriptionInfo ? subscriptionInfo = Get.find<UserProfileController>().providerModel?.content?.subscriptionInfo;
    int remainingDay =  DateConverter.countDays(endDate : DateTime.tryParse( subscriptionInfo?.subscribedPackageDetails?.packageEndDate ?? ""));
    bool isFreeTrial = subscriptionInfo?.subscribedPackageDetails?.trialDuration != null && subscriptionInfo?.subscribedPackageDetails?.trialDuration != 0;
    bool isPaid = subscriptionInfo?.subscribedPackageDetails?.isPaid == 0 ? false : true;

    if(subscriptionInfo?.status == "subscription_base" && ((remainingDay <=0  ||  (isFreeTrial  &&  remainingDay <=0)) || (!isPaid && !isFreeTrial))){
      Future.delayed(const Duration(milliseconds: 200), () {
        showModalBottomSheet(
          context: Get.context!, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (con) => TrialEndBottomSheet(isFreeTrail: isFreeTrial, isPaid: isPaid,),
        );
      });
      return false;
    } else {
      return true;
    }
  }

  Future<void> changeBusinessPlan({required String packageId, required  String paymentMethod, required String packageStatus}) async {
    _isLoading = true;
    update();

    try {
      Map<String, String> body = {
        "payment_platform" : "app",
        "package_id" : packageId,
        "payment_method": paymentMethod,
        "callback": AppConstants.baseUrl,
      };

      Response response = await subscriptionRepo.renewOrShiftSubscription(body, packageStatus: packageStatus);

      if(response.statusCode == 200 && packageStatus == "commission"){
        Get.back();
        Get.back();
        final message = response.body is Map ? response.body['message']?.toString() : null;
        showCustomSnackBar(message ?? 'successfully_updated'.tr,  type: ToasterMessageType.success);
        await Get.find<UserProfileController>().getProviderInfo(reload: true);
        await getSubscriptionPackageList(reload: true);
      }
      else if(response.statusCode == 200 && response.body is Map && response.body['content'] != null) {
        Get.back();
        Get.back();
        DigitalPaymentHelper.launchFromUrl(
          paymentUrl: response.body['content'].toString(),
          fromPage: 'business_plan',
        );
      }else{
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
    } finally {
      _isLoading = false;
      update();
    }
  }

  updateSelectedPackageIndex ({int? index, bool shouldUpdate = false}){

    if(index !=null){
      _selectedPackageIndex = index;
    }else{
      bool flag = false;
      _packageSubscriptionModel?.subscriptionPackages?.forEach((element){
        if( element.id == Get.find<UserProfileController>().providerModel?.content?.subscriptionInfo?.subscribedPackageDetails?.subscriptionPackageId){
          flag = true;
          _selectedPackageIndex =  _packageSubscriptionModel?.subscriptionPackages!.indexOf(element) ?? 0;
        }
      });

      if(!flag){
        _selectedPackageIndex = 0;
      }
    }

    if(shouldUpdate){
      update();
    }
  }

  void updateDigitalPaymentMethodIndex (int index, {bool shouldUpdate = true}) {
    _selectedDigitalPaymentMethodIndex = index;
    if(shouldUpdate){
      update();
    }
  }

  void showSuffixIcon(context,String text){
    if(text.isNotEmpty){
      _isActiveSuffixIcon = true;
    }else if(text.isEmpty){
      _isActiveSuffixIcon = false;
      searchController.clear();
      _isSearchComplete = false;
    }
    update();
  }

  void clearSearchController({bool shouldUpdate = true, bool clearDate = true, bool clearTextController = true} ){

    if(clearTextController){
      _isSearchComplete = false;
      _isActiveSuffixIcon = false;
      searchController.clear();
      _searchedTransactionList = [];
    }

    if(clearDate){
      dateTimeRange = null;
    }
    if(shouldUpdate){
      update();
    }
  }





}