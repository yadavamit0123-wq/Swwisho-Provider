import 'package:demandium_provider/helper/booking_list_parser.dart';
import 'package:demandium_provider/helper/booking_sound_service.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class BookingRequestController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService {

  final BookingRequestRepo bookingRequestRepo;
  BookingRequestController({required this.bookingRequestRepo});


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _selectedIndex = 0;
  int get currentIndex =>_selectedIndex;

  int _apiHitCount = 0;

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  List <BookingRequestModel>? _bookingRequestList;
  List <BookingRequestModel>? get bookingRequestList=> _bookingRequestList;

  ServiceType selectedServiceType = ServiceType.all;

  BookingCount? _bookingCount;
  BookingCount? get bookingCount => _bookingCount;

  AutoScrollController? menuScrollController;
  TabController? tabController;


  List<String> bookingRequestStatusList =["all","pending","accepted", "ongoing","completed","canceled"];
  String get bookingStatus => bookingRequestStatusList[_selectedIndex];

  final ScrollController scrollController = ScrollController();


  @override
  void onInit(){
    super.onInit();
    tabController = TabController(vsync: this, length: 6);
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < (_pageSize ?? 0) ) {
          getBookingRequestList(bookingRequestStatusList[_selectedIndex],offset+1, paginationLoading: true);
        }
      }

    });
  }


  Future<void> getBookingRequestList(String requestType,int offset, {bool reload = false, int index = 0, bool isFirst = false,bool paginationLoading = false}) async {
    _offset = offset;
    _apiHitCount ++;
    if(reload){
      _bookingRequestList = null;
    }
    if(paginationLoading){
      _isLoading = true;
    }

    if(!isFirst){
      update();
    }
    Response response = await bookingRequestRepo.getBookingRequestData(requestType.toLowerCase(), offset, selectedServiceType);

    if(response.statusCode == 200 && response.body is Map){
      try {
      final counts = BookingListParser.extractBookingCounts(response.body);
      if (counts != null) {
        _bookingCount = BookingCount.fromJson(counts);
      }

      final bookingList = BookingListParser.extractBookingRows(response.body);
      _pageSize = BookingListParser.extractLastPage(response.body, fallback: _pageSize ?? 1);

      if(_offset == 1){
        _bookingRequestList = [];
      }
      _bookingRequestList ??= [];
      for (var bookingRequest in bookingList) {
        try {
          if (bookingRequest is Map) {
            _bookingRequestList!.add(BookingRequestModel.fromJson(Map<String, dynamic>.from(bookingRequest)));
          }
        } catch (_) {}
      }

      if (requestType.toLowerCase() == 'pending') {
        _bookingRequestList!.removeWhere((booking) {
          final status = (booking.bookingStatus ?? '').toLowerCase().trim();
          if (status.isEmpty) return false;
          return status == 'canceled' ||
              status == 'cancelled' ||
              status == 'completed' ||
              status == 'accepted' ||
              status == 'ongoing';
        });
        BookingSoundService.onPendingListUpdated(
          _bookingRequestList?.map((booking) => booking.id ?? '').where((id) => id.isNotEmpty).toList() ?? [],
        );
      }
      } catch (_) {
        _bookingRequestList ??= [];
      }
    }
    else{
     ApiChecker.checkApi(response);
    }
    _apiHitCount--;
    _isLoading = false;

    if(_apiHitCount==0){
      update();
    }
  }

  Future<void> syncPendingAlerts() async {
    try {
      final response = await bookingRequestRepo.getBookingRequestData('pending', 1, selectedServiceType);
      if (response.statusCode != 200 || response.body is! Map) return;
      final bookingList = BookingListParser.extractBookingRows(response.body);
      final pending = <BookingRequestModel>[];
      for (final item in bookingList) {
        if (item is! Map) continue;
        try {
          final booking = BookingRequestModel.fromJson(Map<String, dynamic>.from(item));
          final status = (booking.bookingStatus ?? '').toLowerCase();
          if (status.isEmpty || status == 'pending') {
            pending.add(booking);
          }
        } catch (_) {}
      }
      BookingSoundService.onPendingListUpdated(
        pending.map((booking) => booking.id ?? '').where((id) => id.isNotEmpty).toList(),
      );
      if (bookingStatus.toLowerCase() == 'pending') {
        _bookingRequestList = pending;
        update();
      }
    } catch (_) {}
  }


  void updateBookingRequestIndex(int index){
    _selectedIndex = index;
    tabController?.index = index;
    update();
  }

  removeBookingItemFromList(String bookingId,  {bool shouldUpdate = false, required String bookingStatus}){

    _bookingRequestList?.removeWhere((element) => element.id?.toString() == bookingId.toString());
    if(shouldUpdate){
      update();
    }
  }

  void updateSelectedServiceType({ServiceType? type}){
    if(type!=null){
      selectedServiceType = type;
      update();
      getBookingRequestList(bookingStatus, 1, reload: true);
    }else{
      selectedServiceType = ServiceType.all;
    }
  }

  List<PopupMenuModel> getPopupMenuList({String status = "", bool isRepeatBooking = false, RepeatBooking? ongoingRepeatBooking}){
    if(status == "pending"){
      return [
        PopupMenuModel(title: "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: "accept", icon: Icons.check),
        PopupMenuModel(title: "ignore", icon: Icons.close),
      ];
    } else if(status == "accepted" || status == "ongoing" ){
      return [
        PopupMenuModel(title: isRepeatBooking ? "full_booking_details" : "booking_details", icon: Icons.remove_red_eye_sharp),
        if(isRepeatBooking && ongoingRepeatBooking !=null)  PopupMenuModel(title: ongoingRepeatBooking.bookingStatus == "ongoing" ?  "ongoing_booking_details" : "upcoming_booking_details" , icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: isRepeatBooking ? "download_full_invoice" : "download_invoice", icon: Icons.file_download_outlined),
        if(isRepeatBooking && ongoingRepeatBooking !=null) PopupMenuModel(title:   ongoingRepeatBooking.bookingStatus == "ongoing" ? "download_ongoing_invoice" : "download_upcoming_invoice", icon: Icons.file_download_outlined),
      ];
    }
    else if( status == "completed" || status == "canceled"){
      return [
        PopupMenuModel(title: isRepeatBooking ? "full_booking_details" : "booking_details", icon: Icons.remove_red_eye_sharp),
        PopupMenuModel(title: isRepeatBooking ? "download_full_invoice" : "download_invoice", icon: Icons.file_download_outlined),
      ];
    }
    return [];
  }

}