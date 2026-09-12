import 'package:demandium_provider/helper/booking_sound_service.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BookingDetailsController extends GetxController implements GetxService{
  final BookingDetailsRepo bookingDetailsRepo;
  BookingDetailsController({required this.bookingDetailsRepo});

  final List<String> statusTypeList = [
    "accepted",
    "ongoing",
    "completed",
    "canceled",
  ];

  String dropDownValue = '';
  String subBookingDropDownValue = '';

  ScrollController completedServiceImagesScrollController  = ScrollController();

  String _otp = '';
  String get otp => _otp;

  bool _isAcceptButtonLoading = false;
  bool get isAcceptButtonLoading => _isAcceptButtonLoading;

  bool _isIgnoreButtonLoading = false;
  bool get isIgnoreButtonLoading => _isIgnoreButtonLoading;

  bool _isStatusUpdateLoading = false;
  bool get isStatusUpdateLoading => _isStatusUpdateLoading;

  bool _showPhotoEvidenceField = false;
  bool get showPhotoEvidenceField => _showPhotoEvidenceField;

  bool _isWrongOtpSubmitted = false;
  bool get isWrongOtpSubmitted => _isWrongOtpSubmitted;

  List<XFile> _photoEvidence = [];
  List<XFile> get pickedPhotoEvidence => _photoEvidence;

  bool _hideResendButton = false;
  bool get hideResendButton => _hideResendButton;


  BookingDetailsModel? _bookingDetails;
  BookingDetailsModel? get bookingDetails => _bookingDetails;

  BookingDetailsModel? _subBookingDetails;
  BookingDetailsModel? get subBookingDetails => _subBookingDetails;

  double _bottomSheetHeight = 0;
  double get bottomSheetHeight => _bottomSheetHeight;

  var bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;

  final DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final TimeOfDay _selectedTimeOfDay = TimeOfDay.now();
  TimeOfDay get selectedTimeOfDay => _selectedTimeOfDay;

  UserProfileController? userProfile;
  XFile? image;

  @override
  void onInit() {
    super.onInit();
    userProfile = Get.find<UserProfileController>();
    if(Get.find<SplashController>().configModel.content?.providerCanCancelBooking == 0 ){
      statusTypeList.remove('canceled');
    }

  }
  pickImage() async {

    XFile? pickedImg = await ImagePicker().pickImage(source: ImageSource.gallery);

    if(pickedImg != null){
      image = pickedImg;
      update();
    }
  }

  Future<void> getBookingDetails(String bookingID,{bool reload = true, bool initEditBooking = true}) async {

    Response response = await bookingDetailsRepo.getBookingDetails(bookingID);

    if(response.statusCode == 200 ){
      _bookingDetails = BookingDetailsModel.fromJson(response.body);

      if(initEditBooking){
        Get.find<BookingEditController>().getServiceListBasedOnSubcategory(subCategoryId : bookingDetails?.content?.subcategoryId ?? "");
        Get.find<BookingEditController>().initializedControllerValue(_bookingDetails?.content);
      }
     dropDownValue = bookingDetails?.content?.bookingStatus ?? "";
      if(response.body["response_code"] == "default_204"){
        Get.find<BookingRequestController>().removeBookingItemFromList(bookingID, bookingStatus: "", shouldUpdate: true);
      }
    }  else{
     ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> getBookingSubDetails(String bookingID,{bool reload = true}) async {

    Response response = await bookingDetailsRepo.getSubBookingDetails(bookingID);

    if(response.statusCode == 200 ){
      _subBookingDetails = BookingDetailsModel.fromJson(response.body);
      Get.find<BookingEditController>().initializedControllerValue(_subBookingDetails?.content);
      subBookingDropDownValue = _subBookingDetails?.content?.bookingStatus ?? "";
    } else{
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> acceptBookingRequest(String bookingId) async {
    _isAcceptButtonLoading = true;
    update();

    await userProfile?.getProviderInfo(reload: true);
    final walletBalance = userProfile?.walletBalance ?? 0;

    BookingDetailsContent? bookingContent = _bookingDetails?.content?.id == bookingId
        ? _bookingDetails?.content
        : _subBookingDetails?.content?.id == bookingId
            ? _subBookingDetails?.content
            : null;

    if (bookingContent == null) {
      Response detailsResponse = await bookingDetailsRepo.getBookingDetails(bookingId);
      if (detailsResponse.statusCode == 200) {
        bookingContent = BookingDetailsModel.fromJson(detailsResponse.body).content;
      }
    }

    final tdsPercent = Get.find<SplashController>().customerConfigModel.content?.tds ?? 1;
    final requiredWallet = bookingContent != null
        ? BookingHelper.getWalletDeductionRequired(bookingContent, tdsPercent: tdsPercent)
        : double.tryParse(userProfile?.providerCharge ?? '0') ?? 0;

    if (requiredWallet <= 0 || walletBalance >= requiredWallet) {
      Response response = await bookingDetailsRepo.acceptBookingRequest(bookingId);
      if (response.statusCode == 200 && response.body['response_code'] == "status_update_success_200") {
        await BookingSoundService.stopAlert(bookingId: bookingId);
        await getBookingDetails(bookingId, reload: false);
        showCustomSnackBar(response.body["message"], type: ToasterMessageType.success
        );
        Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
      }
      else {
        ApiChecker.checkApi(response);
      }
    }else{
      showCustomSnackBar('Your wallet balance is low. Recharge wallet to accept booking', type: ToasterMessageType.error);
    }
    _isAcceptButtonLoading = false;
    update();
  }

  Future<void> ignoreBookingRequest(String bookingId) async {
    _isIgnoreButtonLoading = true;
    update();
    Response response = await bookingDetailsRepo.ignoreBookingRequest(bookingId);
    if(response.statusCode==200 ) {
      await BookingSoundService.stopAlert(bookingId: bookingId);
      showCustomSnackBar(response.body["message"],  type: ToasterMessageType.success);
      Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
    }
    else{
      ApiChecker.checkApi(response);
    }
    _isIgnoreButtonLoading = false;
    update();
  }

  Future<void> cancelSubBooking({required String bookingId, required String subBookingId}) async {
    _isIgnoreButtonLoading = true;
    update();
    Response response = await bookingDetailsRepo.cancelSubBooking(subBookingId);
    if(response.statusCode==200 ) {
      await getBookingDetails(bookingId, reload: true);
      Get.back();
      showCustomSnackBar(response.body["message"],  type: ToasterMessageType.success);
    }
    else{
      ApiChecker.checkApi(response);
    }
    _isIgnoreButtonLoading = false;
    update();
  }


   Future<void> changeBookingStatus(String bookingId,{String? bookingStatus, bool isBack = false, required  bool isSubBooking}) async {
    _isStatusUpdateLoading = true;
    update();

    List<MultipartBody> multiParts = [];
    for(XFile file in _photoEvidence) {
      multiParts.add(MultipartBody('evidence_photos[]', file));
    }
    if(bookingStatus != null && bookingStatus == "accepted"  && (isSubBooking ? subBookingDropDownValue : dropDownValue) == 'completed'){
      showCustomSnackBar('first complete ongoing'.tr, type : ToasterMessageType.info);
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && (isSubBooking ? subBookingDropDownValue : dropDownValue) == 'canceled'){
      showCustomSnackBar('service_ongoing_can_not_cancel_booking'.tr, type : ToasterMessageType.info);
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && (isSubBooking ? subBookingDropDownValue : dropDownValue) == 'accepted'){
      showCustomSnackBar('service_is_already_ongoing'.tr, type : ToasterMessageType.info);
    }else {
      final targetStatus = isSubBooking ? subBookingDropDownValue : dropDownValue;
      final requiresOtp = (targetStatus == 'ongoing' && bookingStatus == 'accepted')
          || (targetStatus == 'completed' && bookingStatus == 'ongoing');

      if (requiresOtp && otp.isEmpty) {
        showCustomSnackBar('OTP is required'.tr, type : ToasterMessageType.info);
      } else {
      Response response = await bookingDetailsRepo.changeBookingStatus( bookingId, isSubBooking ? subBookingDropDownValue : dropDownValue, otp ,multiParts, isSubBooking);
      if(response.statusCode==200 && response.body["response_code"]=="status_update_success_200"){
        _otp = '';

        if(isSubBooking){
          await getBookingSubDetails(bookingId,reload: false);
         getBookingDetails(_bookingDetails?.content?.id ?? "",reload: false);
        }else{
          await getBookingDetails(bookingId,reload: false);
          Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
        }

        if(isBack){
          Get.back();
        }
        showCustomSnackBar(response.body['message'].toString().capitalizeFirst,  type: ToasterMessageType.success);
      }
      else if(response.statusCode==200 && response.body["response_code"] == "default_403"){
        if((dropDownValue == "ongoing" || dropDownValue == "completed") && otp.isNotEmpty){
          _isWrongOtpSubmitted  = true;
        }
      }else{
        ApiChecker.checkApi(response);
      }
      }
    }
    _isStatusUpdateLoading = false;
    update();
  }

  Future<bool> sendBookingOTPNotification(String? bookingId, {bool shouldUpdate = true, bool resend = false}) async {
    if(shouldUpdate){
      _hideResendButton = true;
      update();
    }
    Response response = await bookingDetailsRepo.sendBookingOTPNotification(bookingId);
    bool isSuccess;
    if(response.statusCode == 200) {
      isSuccess = true;
    }else {
      ApiChecker.checkApi(response);
      isSuccess = false;
    }
    _hideResendButton = false;
    update();
    return isSuccess;
  }

  void updateServicePageCurrentState(BookingDetailsTabControllerState bookingDetailsTabControllerState, {bool shouldUpdate = true}){
    bookingPageCurrentState = bookingDetailsTabControllerState;
    if(shouldUpdate){
      update();
    }
  }


  void showHideExpandView(double bottomHeight, {bool shouldUpdate = true}){
    _bottomSheetHeight = bottomHeight;

    if(shouldUpdate){
      update();
    }
  }

  void changeBookingStatusDropDownValue(String status, bool isSubBooking){
    if(isSubBooking){
      subBookingDropDownValue = status;
    }else{
      dropDownValue = status;

    }

    update();
  }

  void changePhotoEvidenceStatus({bool isUpdate = true , bool status = false}){
    _showPhotoEvidenceField = status;
    if(isUpdate) {
      update();
    }
  }

  Future<void> pickPhotoEvidence({required bool isRemove, required bool isCamera}) async {
    if(isRemove) {
      _photoEvidence = [];
      _showPhotoEvidenceField = false;
    }else {
      XFile? xFile = await ImagePicker().pickImage(
          source: isCamera ? ImageSource.camera : ImageSource.gallery,
          imageQuality: 50);
      if(xFile != null) {
        _photoEvidence.add(xFile);
        if(Get.isBottomSheetOpen!){
          Get.back();
        }
        changePhotoEvidenceStatus(isUpdate: false, status: true);
      }
      update();
    }
  }

  void removePhotoEvidence(int index) {
    _photoEvidence.removeAt(index);
    update();
  }

  void setOtp(String otp) {
    _otp = otp;
    resetWrongOtpValue(shouldUpdate: false);
    if(otp != '') {
      update();
    }
  }

  void resetWrongOtpValue({bool shouldUpdate = true}){
    _isWrongOtpSubmitted = false;

    if(shouldUpdate){
      update();
    }
  }

  void resetBookingDetailsValue({bool shouldUpdate = false, bool resetBookingDetails = false}){
    _photoEvidence = [];
    _showPhotoEvidenceField = false;
    bookingPageCurrentState = BookingDetailsTabControllerState.bookingDetails;
    _subBookingDetails = null;
    if(resetBookingDetails){
      _bookingDetails = null;
    }
  }

  bool isShowChattingButton(BookingDetailsContent? bookingDetails, TabController? tabController){
    return ((bookingDetails != null) && (bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing" )
        && ((bookingDetails.serviceman !=null || bookingDetails.subBooking?.serviceman !=null) || (bookingDetails.customer != null || bookingDetails.subBooking?.customer != null)));
  }

  List<PopupMenuModel> getPopupMenuList({required String status}){
     if( status == "accepted" ){
      return [
        PopupMenuModel(title:  "download_invoice", icon: Icons.file_download_outlined),
        PopupMenuModel(title:  "cancel", icon: Icons.cancel_outlined),
      ];
    } else if(status == "ongoing" || status == "completed" || status == "canceled"){
       return [
         PopupMenuModel(title:  "booking_details", icon: Icons.remove_red_eye_sharp),
         PopupMenuModel(title:  "download_invoice", icon: Icons.file_download_outlined),
       ];
     }
    return [];
  }
}