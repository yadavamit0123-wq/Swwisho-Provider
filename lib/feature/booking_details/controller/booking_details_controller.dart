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
    try {
      Response response = await bookingDetailsRepo.getBookingDetails(bookingID);

      if(response.statusCode == 200 ){
        try {
          _bookingDetails = BookingDetailsModel.fromJson(response.body);
        } catch (_) {}

        if(initEditBooking && _bookingDetails?.content != null){
          Get.find<BookingEditController>().getServiceListBasedOnSubcategory(subCategoryId : bookingDetails?.content?.subcategoryId ?? "");
          Get.find<BookingEditController>().initializedControllerValue(_bookingDetails?.content);
        }
       dropDownValue = bookingDetails?.content?.bookingStatus ?? "";
        if(response.body is Map && response.body["response_code"] == "default_204"){
          Get.find<BookingRequestController>().removeBookingItemFromList(bookingID, bookingStatus: "", shouldUpdate: true);
        } else {
          final status = (_bookingDetails?.content?.bookingStatus ?? '').toLowerCase();
          if (status == 'canceled' || status == 'cancelled' || status == 'completed') {
            Get.find<BookingRequestController>().removeBookingItemFromList(
              bookingID,
              bookingStatus: status,
              shouldUpdate: true,
            );
          }
        }
      }  else{
       ApiChecker.checkApi(response);
      }
    } catch (_) {}
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

  bool _matchesBookingContext(BookingDetailsContent? content, String id) {
    if (content == null || id.isEmpty) return false;
    return content.id?.toString() == id ||
        content.readableId?.toString() == id;
  }

  Future<void> acceptBookingRequest(String bookingId, {String? alternateBookingId}) async {
    _isAcceptButtonLoading = true;
    update();
    try {
      final id = bookingId.toString().trim();
      if (id.isEmpty) {
        showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
        return;
      }
      final walletBalance = userProfile?.walletBalance ?? 0;
      final providerCharge = double.tryParse(userProfile?.providerCharge ?? '0') ?? 0;

      BookingDetailsContent? bookingContent = _matchesBookingContext(_bookingDetails?.content, id)
          ? _bookingDetails?.content
          : _matchesBookingContext(_subBookingDetails?.content, id)
              ? _subBookingDetails?.content
              : null;

      if (bookingContent == null) {
        try {
          final detailsResponse = await bookingDetailsRepo.getBookingDetails(id);
          if (detailsResponse.statusCode == 200 && detailsResponse.body is Map) {
            final parsed = BookingDetailsModel.fromJson(
              Map<String, dynamic>.from(detailsResponse.body as Map),
            );
            bookingContent = parsed.content;
            _bookingDetails = parsed;
          }
        } catch (_) {}
      }

      double requiredWallet = providerCharge;
      if (bookingContent != null) {
        try {
          final tdsPercent = Get.find<SplashController>().customerConfigModel.content?.tds ?? 1;
          requiredWallet = BookingHelper.getWalletDeductionRequired(bookingContent, tdsPercent: tdsPercent);
        } catch (_) {}
      }

      if (requiredWallet > walletBalance) {
        showCustomSnackBar('Your wallet balance is low. Recharge wallet to accept booking', type: ToasterMessageType.error);
      } else {
        Response response = await bookingDetailsRepo.acceptBookingRequest(
          id,
          alternateId: alternateBookingId,
        );
        if (BookingDetailsRepo.isActionSuccess(response)) {
          BookingSoundService.stopAlert(bookingId: id);
          showCustomSnackBar(
            response.body is Map
                ? (response.body['message']?.toString() ?? 'successfully_updated'.tr)
                : 'successfully_updated'.tr,
            type: ToasterMessageType.success,
          );
          if (Get.isRegistered<BookingRequestController>()) {
            Get.find<BookingRequestController>().removeBookingItemFromList(
              id,
              bookingStatus: 'accepted',
              shouldUpdate: true,
            );
            Get.find<BookingRequestController>().getBookingRequestList(
              Get.find<BookingRequestController>().bookingStatus,
              1,
              reload: true,
            );
          }
          if (Get.isRegistered<BookingDetailsController>()) {
            getBookingDetails(id, reload: false, initEditBooking: false);
          }
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().getDashboardData();
          }
        } else {
          ApiChecker.checkApi(response);
        }
      }
    } catch (_) {
      showCustomSnackBar('Failed to accept booking'.tr, type: ToasterMessageType.error);
    } finally {
      _isAcceptButtonLoading = false;
      update();
    }
  }

  Future<void> ignoreBookingRequest(String bookingId, {String? alternateBookingId}) async {
    _isIgnoreButtonLoading = true;
    update();
    try {
      final id = bookingId.toString().trim();
      if (id.isEmpty) {
        showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
        return;
      }
      Response response = await bookingDetailsRepo.ignoreBookingRequest(
        id,
        alternateId: alternateBookingId,
      );
      if (BookingDetailsRepo.isActionSuccess(response)) {
        BookingSoundService.stopAlert(bookingId: id);
        final message = response.body is Map
            ? (response.body['message']?.toString() ?? 'successfully_updated'.tr)
            : 'successfully_updated'.tr;
        showCustomSnackBar(message, type: ToasterMessageType.success);
        if (Get.isRegistered<BookingRequestController>()) {
          Get.find<BookingRequestController>().removeBookingItemFromList(
            id,
            bookingStatus: 'canceled',
            shouldUpdate: true,
          );
          Get.find<BookingRequestController>().getBookingRequestList(
            Get.find<BookingRequestController>().bookingStatus,
            1,
            reload: true,
          );
        }
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().getDashboardData();
        }
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
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


   Future<void> changeBookingStatus(String bookingId,{String? bookingStatus, String? forcedNextStatus, String? otpCode, bool isBack = false, required  bool isSubBooking}) async {
    if (otpCode != null) {
      _otp = otpCode.trim();
    }
    _isStatusUpdateLoading = true;
    update();

    try {
    List<MultipartBody> multiParts = [];
    for(XFile file in _photoEvidence) {
      multiParts.add(MultipartBody('evidence_photos[]', file));
    }
    final nextStatus = (forcedNextStatus != null && forcedNextStatus.isNotEmpty)
        ? forcedNextStatus
        : (isSubBooking ? subBookingDropDownValue : dropDownValue);
    if(bookingStatus != null && bookingStatus == "accepted"  && nextStatus == 'completed'){
      showCustomSnackBar('first complete ongoing'.tr, type : ToasterMessageType.info);
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && nextStatus == 'canceled'){
      showCustomSnackBar('service_ongoing_can_not_cancel_booking'.tr, type : ToasterMessageType.info);
    }else if(bookingStatus != null && bookingStatus == 'ongoing' && nextStatus == 'accepted'){
      showCustomSnackBar('service_is_already_ongoing'.tr, type : ToasterMessageType.info);
    }else {
      final requiresOtp = (nextStatus == 'ongoing' && bookingStatus == 'accepted')
          || (nextStatus == 'completed' && bookingStatus == 'ongoing');

      if (requiresOtp && otp.trim().isEmpty) {
        showCustomSnackBar('OTP is required'.tr, type : ToasterMessageType.info);
      } else {
      Response response = await bookingDetailsRepo.changeBookingStatus( bookingId, nextStatus, otp.trim() ,multiParts, isSubBooking);
      final code = response.body is Map ? response.body['response_code']?.toString() : '';
      if(response.statusCode==200 && code=="status_update_success_200"){
        _otp = '';

        if(isSubBooking){
          await getBookingSubDetails(bookingId,reload: false);
         getBookingDetails(_bookingDetails?.content?.id ?? "",reload: false);
        }else{
          await getBookingDetails(bookingId,reload: false);
          if (Get.isRegistered<BookingRequestController>()) {
            Get.find<BookingRequestController>().getBookingRequestList(Get.find<BookingRequestController>().bookingStatus, 1);
          }
        }

        if(isBack){
          Get.back();
        }
        final message = response.body is Map ? response.body['message']?.toString() : null;
        showCustomSnackBar((message ?? 'successfully_updated'.tr).toString().capitalizeFirst,  type: ToasterMessageType.success);
      }
      else if(response.statusCode==200 && code == "default_403"){
        if((nextStatus == "ongoing" || nextStatus == "completed") && otp.isNotEmpty){
          _isWrongOtpSubmitted  = true;
        } else {
          ApiChecker.checkApi(response);
        }
      }else{
        ApiChecker.checkApi(response);
      }
      }
    }
    } catch (_) {
      showCustomSnackBar('something_went_wrong'.tr, type: ToasterMessageType.error);
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