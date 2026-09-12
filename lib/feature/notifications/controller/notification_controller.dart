import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:demandium_provider/feature/notifications/model/notofication_model.dart';


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
        if(_offset < _pageSize! ) {
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
    }
    else {
      _paginationLoading = true;
    }
    if(response.statusCode == 200){

      allNotificationList =[];
      _totalNumberOfNotification = 0;
     try {
       final body = response.body is Map
           ? Map<String, dynamic>.from(response.body)
           : <String, dynamic>{};
       _notificationModel = NotificationModel.fromJson(body);
     } catch (_) {
       _notificationModel = NotificationModel();
     }

     _pageSize = int.tryParse(response.body is Map ? response.body['content']?['last_page']?.toString() ?? '' : '') ?? 1;

     _totalNumberOfNotification  = notificationModel?.content?.total??0;

     getNotificationCount();
     if(saveNotificationCount){
       setNotificationCount(_totalNumberOfNotification);
     }

      final items = notificationModel?.content?.data ?? [];
      for (var data in items) {
        final date = DateTime.tryParse(data.createdAt ?? '');
        final label = DateConverter.dateStringMonthYear(date);
        if(!dateList.contains(label)) {
          dateList.add(label);
        }
      }

      for (var data in items) {
        allNotificationList.add(data);
      }

      for(int i=0;i< dateList.length;i++){
       notificationList.add([]);
       for (var element in allNotificationList) {
         final date = DateTime.tryParse(element.createdAt ?? '');
         if(dateList[i]== DateConverter.dateStringMonthYear(date)){
           notificationList[i].add(element);
         }
       }
     }

    } else{
      ApiChecker.checkApi(response);
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
}