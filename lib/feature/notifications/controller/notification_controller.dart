import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:demandium_provider/feature/notifications/model/notofication_model.dart';
import 'package:demandium_provider/feature/notifications/repository/local_notification_inbox.dart';


class NotificationController extends GetxController implements GetxService{
  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  NotificationModel? _notificationModel;
  NotificationModel? get notificationModel => _notificationModel;
  List<String> dateList = [];
  List allNotificationList=[];
  List<dynamic> notificationList=[];


  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _paginationLoading = false;
  bool get paginationLoading => _paginationLoading;

  int _notificationCount = 0;
  int get unseenNotificationCount => _notificationCount;

  int _totalNumberOfNotification=0;
  int get totalNumberOfNotification => _totalNumberOfNotification;

  int? _pageSize = 1;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  ScrollController scrollController = ScrollController();

  @override
  void onInit(){
    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent/2 < scrollController.position.pixels) {
        if(_offset < (_pageSize ?? 1) ) {
          getNotifications(offset+1, reload: false);
        }
      }
    });
  }

  Future<void> getNotifications(int offset, {bool reload = true,bool saveNotificationCount=true})async{
    _offset = offset;
    try {
    Response response = await notificationRepo.getNotification(offset);

    if(reload){
      dateList =[];
      notificationList =[];
      allNotificationList =[];
      _totalNumberOfNotification = 0;
    } else {
      _paginationLoading = true;
    }

    if(response.statusCode == 200 && response.body is Map){
     try {
       _notificationModel = NotificationModel.fromJson(Map<String, dynamic>.from(response.body));
     } catch (_) {
       _notificationModel = NotificationModel();
     }
     _pageSize = notificationModel?.content?.lastPage ?? 1;
     _totalNumberOfNotification  = notificationModel?.content?.total??0;
     getNotificationCount();
     if(saveNotificationCount){
       setNotificationCount(_totalNumberOfNotification);
     }
    } else {
      _notificationModel ??= NotificationModel();
    }

      final incoming = <Data>[];
      if (offset == 1) {
        try {
          await _seedFromBookings();
          incoming.addAll(await LocalNotificationInbox.load());
        } catch (_) {}
      }
      for (final data in notificationModel?.content?.data ?? []) {
        incoming.add(data);
      }

      final seen = allNotificationList.map((e) => e.id ?? '${e.title}|${e.createdAt}').toSet();
      for (final data in incoming) {
        final key = data.id ?? '${data.title}|${data.createdAt}';
        if (seen.contains(key)) continue;
        seen.add(key);
        allNotificationList.add(data);
      }

      dateList = [];
      notificationList = [];
      for (final data in allNotificationList) {
        final label = DateConverter.dateStringMonthYear(DateTime.tryParse(data.createdAt ?? ''));
        if(!dateList.contains(label)) {
          dateList.add(label);
        }
      }
      for (int i = 0; i < dateList.length; i++) {
        notificationList.add([]);
        for (final element in allNotificationList) {
          if (dateList[i] == DateConverter.dateStringMonthYear(DateTime.tryParse(element.createdAt ?? ''))) {
            notificationList[i].add(element);
          }
        }
      }

    } catch (_) {
      _notificationModel ??= NotificationModel();
    }
    _paginationLoading = false;
    _isLoading =false;
    update();
  }

  void getNotificationCount() async {
    _notificationCount = (await notificationRepo.getNotificationCount()) ?? 0;
    if(_totalNumberOfNotification>_notificationCount){
      _notificationCount = _totalNumberOfNotification - _notificationCount;
    }else{
      _notificationCount =0;
    }
    update();
  }

  void resetNotificationCount(){
    _notificationCount = 0;
    update();
  }
  void setNotificationCount(int count){
    notificationRepo.setNotificationCount(count);
  }

  Future<void> _seedFromBookings() async {
    try {
      if (Get.isRegistered<BookingRequestRepo>()) {
        final response = await Get.find<BookingRequestRepo>().getBookingRequestData('pending', 1, ServiceType.all);
        if (response.statusCode == 200 && response.body is Map) {
          final content = response.body['content'];
          dynamic bookingsNode = content is Map ? content['bookings'] : null;
          List<dynamic> bookingList = const [];
          if (bookingsNode is Map && bookingsNode['data'] is List) {
            bookingList = bookingsNode['data'];
          } else if (bookingsNode is List) {
            bookingList = bookingsNode;
          }
          for (final item in bookingList) {
            if (item is! Map) continue;
            try {
              final booking = BookingRequestModel.fromJson(Map<String, dynamic>.from(item));
              final status = (booking.bookingStatus ?? 'pending').toLowerCase();
              if (status.isNotEmpty && status != 'pending') continue;
              await LocalNotificationInbox.addSimple(
                id: 'booking_${booking.id}',
                title: 'New booking #${booking.readableId ?? ''}',
                body: booking.subCategory?.name ?? 'You have a new booking request',
                createdAt: booking.createdAt,
              );
            } catch (_) {}
          }
        }
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<DashboardController>()) {
        for (final recent in Get.find<DashboardController>().dashboardRecentActivityList) {
          await LocalNotificationInbox.addSimple(
            id: 'recent_${recent.id}',
            title: 'Booking #${recent.readableId ?? ''}',
            body: (recent.bookingStatus ?? 'pending').toString(),
            createdAt: recent.createdAt,
          );
        }
      }
    } catch (_) {}
  }
}