import 'dart:convert';

import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:demandium_provider/feature/profile/model/provider_model.dart';
import 'package:intl/intl.dart';
import '../../../utils/availability_controller.dart';



class UserProfileController extends GetxController implements GetxService{
  final UserRepo userRepo;
  UserProfileController({required this.userRepo});
  bool hasShownWalletDialog = false;
  final GlobalKey<FormState> profileInformationFormKey = GlobalKey<FormState>();

  TextEditingController? companyNameController,companyPhoneController,companyEmailController,
      personalNameController,personalPhoneController,personalEmailController,
      emailController, passwordController,confirmPasswordController, panNumberController;

  XFile? _pickedPanImageList;
  XFile? get pickedPanImage => _pickedPanImageList;
  final bool _isIdentityImageValid = true;
  bool get isIdentityImageValid => _isIdentityImageValid;
  String? panImageUrl;

  bool keepPersonalInfoAsCompanyInfo = false;

  bool _showOverflowDialog = false;
  bool get showOverflowDialog => _showOverflowDialog;

  bool _trialWidgetNotShow = false;
  bool get trialWidgetNotShow => _trialWidgetNotShow;

  String _providerId = '';
  String get providerId =>_providerId;

  var countryDialCode = "+880";

  String _selectedZoneID ='';
  String get selectedZoneID => _selectedZoneID;

  String _selectedZoneName ="";
  String get selectedZoneName => _selectedZoneName;

  String myZone='';
  String? myZoneId;
  double latitude = 0;
  double longitude= 0;

  List<ZoneData> zoneList=[];

  bool _isZoneValid = true;
  bool get isZoneValid => _isZoneValid;


  int _totalCompleteRequest= 0;
  int _totalCanceledRequest= 0;
  int _totalOngoingRequest= 0;
  int _totalAcceptedRequest= 0;

  int get totalCompletedRequest=> _totalCompleteRequest;
  int get totalCanceledRequest=> _totalCanceledRequest;
  int get totalOngoingRequest=> _totalOngoingRequest;
  int get totalAcceptedRequest=> _totalAcceptedRequest;
  AvailabilityController? availabilityController;

  @override
  void onInit() {
    super.onInit();
    //getProviderInfo();
    companyNameController = TextEditingController();
    companyPhoneController = TextEditingController();
    companyEmailController = TextEditingController();
    panNumberController = TextEditingController();

    personalNameController = TextEditingController();
    personalPhoneController = TextEditingController();
    personalEmailController = TextEditingController();

    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    countryDialCode = CountryCode.fromCountryCode(Get.find<SplashController>().configModel.content?.countryCode??"IN").dialCode!;
    _restoreProviderInfoFromCache();
  }

  bool get hasProfileData => _providerModel?.content?.providerInfo != null;

  void _restoreProviderInfoFromCache() {
    final cached = userRepo.getCachedProviderInfo();
    if (cached == null) return;
    try {
      _providerModel = ProviderModel.fromJson(cached);
      _applyProviderModelFields();
    } catch (_) {}
  }

  bool _loadProviderModelFromMap(Map<String, dynamic> body) {
    try {
      final parsedModel = ProviderModel.fromJson(body);
      _providerModel = parsedModel;
      return true;
    } catch (_) {
      return false;
    }
  }

  void _applyProviderModelFields() {
    if (_providerModel?.content?.providerInfo == null) return;

    try {
      _providerCharge = _providerModel?.content?.providerCharge ?? '0';
      isOnline = _providerModel?.content?.providerInfo?.isOnline == 0;
      offlineAt = _providerModel?.content?.providerInfo?.offlineAt;

      if (offlineAt == null || offlineAt!.isEmpty || offlineAt == 'null') {
        final fallbackTime = DateTime.now().subtract(const Duration(hours: 24));
        offlineAt = DateFormat('yyyy-MM-dd HH:mm:ss').format(fallbackTime);
      }

      availabilityController?.dispose();
      availabilityController = null;
      try {
        if (offlineAt != null && offlineAt!.isNotEmpty) {
          availabilityController = AvailabilityController(offlineAt: offlineAt!);
        }
      } catch (_) {
        availabilityController = null;
      }

      _newWalletAmount = resolveWalletBalance(
        _providerModel?.content?.providerInfo?.owner?.account,
      ).toString();

      final payablePercentage = getOverflowPercent(
        double.tryParse(_providerModel?.content?.providerInfo?.owner?.account?.accountPayable ?? '0') ?? 0,
        double.tryParse(_providerModel?.content?.providerInfo?.owner?.account?.accountReceivable ?? '0') ?? 0,
        (Get.find<SplashController>().configModel.content?.maxCashInHandLimit ?? 0).toDouble(),
      );
      hideOverflowDialog(payablePercentage: payablePercentage, hideDialog: false);

      companyNameController!.text = _providerModel?.content?.providerInfo?.companyName ?? '';
      final configCountryCode = Get.find<SplashController>().configModel.content?.countryCode ?? 'IN';
      countryDialCode = ValidationHelper.getValidCountryCode(_providerModel?.content?.providerInfo?.companyPhone ?? '') != ''
          ? ValidationHelper.getValidCountryCode(_providerModel?.content?.providerInfo?.companyPhone ?? '')
          : CountryCode.fromCountryCode(configCountryCode).dialCode ?? '+91';
      companyPhoneController!.text = ValidationHelper.getValidPhone(_providerModel?.content?.providerInfo?.companyPhone ?? '') != ''
          ? ValidationHelper.getValidPhone(_providerModel?.content?.providerInfo?.companyPhone ?? '')
          : _providerModel?.content?.providerInfo?.companyPhone ?? '';
      companyEmailController!.text = _providerModel?.content?.providerInfo?.companyEmail ?? '';
      panImageUrl = (_providerModel?.content?.providerInfo?.panImage != null &&
              _providerModel?.content?.providerInfo?.panImage != '')
          ? '${AppConstants.baseUrl}/storage/app/public/provider/document/${_providerModel?.content?.providerInfo?.panImage}'
          : null;
      panNumberController!.text = _providerModel?.content?.providerInfo?.panNumber ?? '';
      personalNameController!.text = _providerModel?.content?.providerInfo?.contactPersonName ?? '';
      personalPhoneController!.text = ValidationHelper.getValidPhone(_providerModel?.content?.providerInfo?.contactPersonPhone ?? '') != ''
          ? ValidationHelper.getValidPhone(_providerModel?.content?.providerInfo?.contactPersonPhone ?? '')
          : _providerModel?.content?.providerInfo?.contactPersonPhone ?? '';
      personalEmailController!.text = _providerModel?.content?.providerInfo?.contactPersonEmail ?? '';
      emailController!.text = _providerModel?.content?.providerInfo?.owner?.email ?? '';
      latitude = _providerModel?.content?.providerInfo?.coordinates?.latitude ?? 0;
      longitude = _providerModel?.content?.providerInfo?.coordinates?.longitude ?? 0;

      _totalCompleteRequest = 0;
      _totalCanceledRequest = 0;
      _totalOngoingRequest = 0;
      _totalAcceptedRequest = 0;

      final providerInfo = _providerModel!.content!.providerInfo!;
      _providerId = providerInfo.id ?? '';
      myZoneId = providerInfo.zoneId ?? '';
      _selectedZoneID = myZoneId ?? '';
      _selectedZoneName = '';

      if (zoneList.isEmpty) {
        getZoneList();
      } else {
        for (final element in zoneList) {
          if (element.id == providerInfo.zoneId) {
            myZone = element.name ?? '';
            break;
          }
        }
      }

      keepPersonalInfoAsCompanyInfo = companyNameController!.text == personalNameController!.text &&
          companyPhoneController!.text == personalPhoneController!.text &&
          companyEmailController!.text == personalEmailController!.text;

      final bookingOverview = _providerModel?.content?.bookingOverview;
      if (bookingOverview != null && bookingOverview.isNotEmpty) {
        for (final element in bookingOverview) {
          if (element.bookingStatus == 'accepted') {
            _totalAcceptedRequest = element.total ?? 0;
          } else if (element.bookingStatus == 'canceled') {
            _totalCanceledRequest = element.total ?? 0;
          } else if (element.bookingStatus == 'completed') {
            _totalCompleteRequest = element.total ?? 0;
          } else if (element.bookingStatus == 'ongoing') {
            _totalOngoingRequest = element.total ?? 0;
          }
        }
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    companyNameController!.dispose();
    companyPhoneController!.dispose();
    companyEmailController!.dispose();
    panNumberController!.dispose();
    personalNameController!.dispose();
    personalPhoneController!.dispose();
    personalEmailController!.dispose();

    emailController!.dispose();
    passwordController!.dispose();
    confirmPasswordController!.dispose();
    availabilityController?.dispose();
  }

  void pickPanImage() async {
    _pickedPanImageList = (await ImagePicker().pickImage(source: ImageSource.gallery))!;
    update();
  }

  void clearPanImage() async {
    _pickedPanImageList = null;
    update();
  }
  void togglePersonalInfoAsCompanyInfo(){
    keepPersonalInfoAsCompanyInfo =! keepPersonalInfoAsCompanyInfo;

    if(keepPersonalInfoAsCompanyInfo){
      personalNameController!.text = companyNameController!.text;
      personalPhoneController!.text = companyPhoneController!.text;
      personalEmailController!.text = companyEmailController!.text;
    }
    else{
        personalNameController!.text = _providerModel?.content?.providerInfo?.contactPersonName??"";
        personalPhoneController!.text = _providerModel?.content?.providerInfo?.contactPersonPhone??"";
        personalEmailController!.text= _providerModel?.content?.providerInfo?.contactPersonEmail??"";
    }
    update();
  }

   ProviderModel? _providerModel;
   DateTime? _lastProviderInfoSync;
   String _providerCharge = '0';
   String _newWalletAmount = '0';
   String get providerCharge => _providerCharge;
   String get newWalletAmount => _newWalletAmount;
   double get walletBalance => double.tryParse(_newWalletAmount) ?? 0;

   static double resolveWalletBalance(Account? account) {
     if (account == null) return 0;
     final newBalance = double.tryParse(account.newAccountBalance?.toString() ?? '');
     final receivedBalance = double.tryParse(account.receivedBalance?.toString() ?? '');
     if (newBalance != null && newBalance > 0) return newBalance;
     if (receivedBalance != null && receivedBalance > 0) return receivedBalance;
     return newBalance ?? receivedBalance ?? 0;
   }
   XFile? _pickedFile ;
   bool _isLoading = false;

  ProviderModel? get providerModel => _providerModel;
  XFile? get pickedFile => _pickedFile;
  bool get isLoading => _isLoading;

  bool isOnline = false;
  String? offlineAt;

  void changeStatus(bool status){
    isOnline = status;
    changeAccountStatus(status);
    update();
  }

  Future changeAccountStatus(bool status) async{
    _isLoading = true;
    update();

    Response response = await userRepo.changeStatus(status);
    if(response.statusCode == 200){
      getProviderInfo(reload: true);
      showCustomSnackBar('status update successfully!',type: ToasterMessageType.success);
    }else{
      showCustomSnackBar('status update failed!',type: ToasterMessageType.error);
    }
    _isLoading = false;
    update();
  }

  Future<void> refreshProviderInfoIfStale({Duration maxAge = const Duration(minutes: 2)}) async {
    if (_providerModel == null) {
      await getProviderInfo(reload: true);
      return;
    }
    if (_lastProviderInfoSync != null &&
        DateTime.now().difference(_lastProviderInfoSync!) < maxAge) {
      return;
    }
    await getProviderInfo(reload: true);
  }

  Future<bool> getProviderInfo({reload = false}) async {
    if (hasProfileData && !reload) {
      return true;
    }

    if (_providerModel == null) {
      _restoreProviderInfoFromCache();
    }

    if (_providerModel == null || reload) {
      if (_providerModel == null) {
        try {
          if (Get.isRegistered<LocationController>()) {
            Get.find<LocationController>().setPickedLocation(shouldUpdate: false);
          }
        } catch (_) {}
        _isLoading = true;
        update();
      }

      try {
        final response = await userRepo.getProviderInfo();
        final rawBody = response.body;
        Map<String, dynamic>? body;
        if (rawBody is Map) {
          body = Map<String, dynamic>.from(rawBody);
        } else if (rawBody is String && rawBody.trim().startsWith('{')) {
          try {
            final decoded = jsonDecode(rawBody);
            if (decoded is Map) {
              body = Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
        }

        if (response.statusCode == 200 && body != null && _loadProviderModelFromMap(body)) {
          await userRepo.cacheProviderInfo(body);
          _applyProviderModelFields();
          _lastProviderInfoSync = DateTime.now();
        } else if (_providerModel == null) {
          _restoreProviderInfoFromCache();
        }
      } catch (_) {
        if (_providerModel == null) {
          _restoreProviderInfoFromCache();
        }
      }
    }

    _isLoading = false;
    update();
    return hasProfileData;
  }

  Future<ResponseModel> updateProfile({required String address}) async {
    _isLoading = true;
    update();

    if(Get.find<LocationController>().pickAddress.address != ""){
      latitude = Get.find<LocationController>().pickPosition.latitude;
      longitude = Get.find<LocationController>().pickPosition.longitude;
    }


    Response response = await userRepo.updateProfile(
        companyNameController!.text.toString(),
        "$countryDialCode${companyPhoneController!.text.toString()}",
        address,
        latitude,
        longitude,
        companyEmailController!.text.toString(),
        personalNameController!.text.toString(),
        "$countryDialCode${ personalPhoneController!.text.toString()}",
        personalEmailController!.text.toString(),
        _selectedZoneID,
        _pickedFile,
        panNumberController!.text.toString(),
        _pickedPanImageList
    );
    if(response.statusCode==200){

      if(companyNameController!.text==personalNameController!.text
          && companyPhoneController!.text==personalPhoneController!.text
          &&companyEmailController!.text==personalEmailController!.text){
        keepPersonalInfoAsCompanyInfo = true;
      }else{
        keepPersonalInfoAsCompanyInfo = false;
      }
      _isLoading=false;
      update();
     return ResponseModel(true, response.body['message']);
    }
    else{
      _isLoading = false;
      update();
     return  ResponseModel(false, response.body['errors'][0]['message']);
    }
  }

  Future<ResponseModel> updateProfileWithPassword() async {
    _isLoading = true;
    update();

    Response response = await userRepo.updateProfileWithPassword(
      companyNameController!.text.toString(),
      companyPhoneController!.text.toString(),
      _providerModel?.content?.providerInfo?.companyAddress ?? "",
      companyEmailController!.text.toString(),
      personalNameController!.text.toString(),
      personalPhoneController!.text.toString(),
      personalEmailController!.text.toString(),
      passwordController!.text,
      confirmPasswordController!.text,
      _selectedZoneID,
      latitude,
      longitude,
      panNumberController!.text.toString(),
      _pickedPanImageList
    );

    if(response.statusCode==200){
      _isLoading=false;
      update();
      return  ResponseModel(true, response.body['message']);

    }
    else{
      _isLoading = false;
      update();
      return  ResponseModel(false, response.body['errors'][0]['message']);
    }
  }

  Future<void> getZoneList() async {
    _selectedZoneName ='';

    if(zoneList.isEmpty){
      Response? response = await userRepo.getZonesDataList();
      if (response!.statusCode == 200)
      {
        zoneList=[];

        List<dynamic>? list = response.body['content']['data'];

        if(zoneList.isEmpty){
          for (var element in list!) {
            zoneList.add(ZoneData.fromJson(element));
          }
        }

        if(zoneList.isNotEmpty && _providerModel!=null){

          for (var element in zoneList) {
            if(element.id==_providerModel!.content!.providerInfo!.zoneId!){
              myZone = element.name!;
            }
          }
        }
      }
      else {
      }
    }else{
      if(_providerModel!=null){
        for (var element in zoneList) {
          if(element.id==_providerModel!.content!.providerInfo!.zoneId!){
            myZone = element.name!;
          }
        }
      }
    }

      update();
  }

  void setNewZoneValue(String zoneName,zoneId){
    _selectedZoneName =zoneName;
    _selectedZoneID = zoneId;
    update();
  }

  void pickImage() async {
    _pickedFile = (await ImagePicker().pickImage(source: ImageSource.gallery));
    update();
  }

  void resetImage() async {
    _pickedFile = null;
  }


  double getOverflowPercent(double payable, double receivable, double maxAmount) {
     double amount = getTransactionAmountAmount(payable, receivable);

     double percentage = (amount / maxAmount) * 100;
     return percentage;
   }

  double getTransactionAmountAmount(double payable, double receivable) {
    double amount = 0;
    if(payable > receivable){
      amount = payable - receivable;
    }else{
      amount = receivable - payable;
    }
    return amount;
  }

  TransactionType getTransactionType (double payable, double receivable){
    TransactionType type =  TransactionType.none;

    if(payable == receivable){
      if(payable == 0 || receivable == 0){
        type  = TransactionType.none;
      }else{
        type = TransactionType.adjust;
      }
    } else if(payable > receivable ){
      if(receivable > 0.0){
        type = TransactionType.adjustAndPayable;
      }else{
        type = TransactionType.payable;
      }
    }else if(receivable > payable){
      if( payable> 0.0){
        type = TransactionType.adjustWithdrawAble;
      }else{
        type = TransactionType.withdrawAble;
      }
    } else{
      type  = TransactionType.none;
    }

    return type;
  }

  int numberOfShowDialog = 0;

  hideOverflowDialog({double? payablePercentage, bool hideDialog = true}){

    if(!hideDialog ){

      if(payablePercentage != null){
        if( !_showOverflowDialog && payablePercentage >= 80 && payablePercentage < 100 && numberOfShowDialog < 1){
          numberOfShowDialog ++;
          _showOverflowDialog = true;

        } else if(payablePercentage >= 100){
          numberOfShowDialog = 0;
          _showOverflowDialog = true;
        } else{
          // //numberOfShowDialog = 0;
          // _showOverflowDialog = false;
        }
      }

    }else{
      _showOverflowDialog = false;
      update();
    }
  }

  updateNumberOfTimeShowingDialog(){
    numberOfShowDialog = 0;
    _showOverflowDialog = false;
  }

  bool haveAnyAcceptedAndOngoingBooking(){
    return  (_totalAcceptedRequest + _totalOngoingRequest) > 0;
  }


  onProfileChangeValidationCheck({bool shouldUpdate = true}){
    if(selectedZoneName == ""){
      _isZoneValid = false;
    }
    if(shouldUpdate){
      update();
    }
  }

  void clearUserProfileData(){
    _providerModel = null;
    userRepo.clearCachedProviderInfo();
    update();
  }


  Future<bool> trialWidgetShow({required String route}) async {
    const Set<String> routesToHideWidget = {
      '/business-plan', 'show-dialog', '/success', '/payment',
    };
    _trialWidgetNotShow = routesToHideWidget.contains(route);

    Future.delayed(const Duration(milliseconds: 500), () {
      update();
    });
    return _trialWidgetNotShow;
  }


  bool checkAvailableFeatureInSubscriptionPlan({required String featureType}){

    bool status = _providerModel?.content?.subscriptionInfo?.status == "subscription_base"
        && !_providerModel!.content!.subscriptionInfo!.subscribedPackageDetails!.featureList!.contains(featureType) ? false : true;

    if(!status){
      showCustomSnackBar('this_feature_is_not_included_in_your_current_subscription_plan'.tr);
    }
    return status;
  }

}