import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class NotificationSetupController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService{
  final NotificationSetupRepo notificationSetupRepo;
  NotificationSetupController({required this.notificationSetupRepo});

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  bool _isActiveSuffixIcon = false;
  bool get isActiveSuffixIcon => _isActiveSuffixIcon;

  bool _isSearchComplete = true;
  bool get isSearchComplete => _isSearchComplete;

  var searchController = TextEditingController();

  List<NotificationSetup>? _providerNotificationSetupList;
  List<NotificationSetup>? get providerNotificationSetupList => _providerNotificationSetupList;

  List<NotificationSetup>? _searchedProviderNotificationSetupList;
  List<NotificationSetup>? get searchedProviderNotificationSetupList => _searchedProviderNotificationSetupList;

  List<NotificationSetup>? _servicemanNotificationSetupList;
  List<NotificationSetup>? get servicemanNotificationSetupList => _servicemanNotificationSetupList;

  List<NotificationSetup>? _searchedServicemanNotificationSetupList;
  List<NotificationSetup>? get searchedServicemanNotificationSetupList => _searchedServicemanNotificationSetupList;

  TabController? tabController;
  @override
  void onInit(){
    super.onInit();
    tabController = TabController(vsync: this, length: 1);
  }



  List<dynamic> _notificationListFrom(dynamic content) {
    if (content is List) return content;
    if (content is Map && content['data'] is List) return content['data'];
    return [];
  }

  Future<void> getNotificationSetupList({ required String type}) async {
    try {
    Response response = await notificationSetupRepo.getNotificationSetupList(type: type);

    if(response.statusCode == 200){
      final list = _notificationListFrom(response.body['content']);

      if(type =="provider"){
        _providerNotificationSetupList = [];
        for (var element in list) {
          try {
            if (element is Map) {
              _providerNotificationSetupList!.add(NotificationSetup.fromJson(Map<String, dynamic>.from(element)));
            }
          } catch (_) {}
        }
      }else{
        _servicemanNotificationSetupList = [];
        for (var element in list) {
          try {
            if (element is Map) {
              _servicemanNotificationSetupList!.add(NotificationSetup.fromJson(Map<String, dynamic>.from(element)));
            }
          } catch (_) {}
        }
      }
    }
    } catch (_) {
      if (type == "provider") {
        _providerNotificationSetupList ??= [];
      } else {
        _servicemanNotificationSetupList ??= [];
      }
    }
    update();
  }


  Future<void> updateNotificationSetup({ required dynamic body, bool reload = true}) async {

   if(reload){
     _isLoading = true;
     update();
   }
    Response response = await notificationSetupRepo.updateNotificationSetup(body: body);

    if(response.statusCode == 200){
      showCustomSnackBar(response.body["message"],  type: ToasterMessageType.success);
    }else{
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }


  Map<String, Map<String, Map<String, String>>> getNotificationObject(List<NotificationSetup>? list){
    Map<String, Map<String, Map<String, String>>> body = {'notifications': {}};
    list?.forEach((element) {
      String? id = element.id;
      var notificationsMap = <String, String>{};

      if (element.value?.notification != null) {
        notificationsMap['notification'] = "${element.providerNotifications?.value?.notification ?? element.value?.notification!}";
      }
      if (element.value?.sms != null) {
        notificationsMap['sms'] = "${element.providerNotifications?.value?.sms ?? element.value?.sms!}";
      }
      if (element.value?.email != null) {
        notificationsMap['email'] = "${element.providerNotifications?.value?.email ?? element.value?.email!}";
      }

      if (notificationsMap.isNotEmpty) {
        body['notifications']?[id!] = notificationsMap;
      }
    });
    return body;

  }



  void searchItems({required String query}) {

    _searchedProviderNotificationSetupList = [];
    _searchedProviderNotificationSetupList = _providerNotificationSetupList?.where((item) {
      final titleLower = item.title?.toLowerCase() ?? "";
      final subtitleLower = item.subTitle?.toLowerCase() ?? "";
      final key = item.key?.toLowerCase().replaceAll("_", " ") ?? "";
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || subtitleLower.contains(searchLower) || key.contains(searchLower);
    }).toList();

    _searchedServicemanNotificationSetupList = [];
    _searchedServicemanNotificationSetupList = _servicemanNotificationSetupList?.where((item) {
      final titleLower = item.title?.toLowerCase() ?? "";
      final subtitleLower = item.subTitle?.toLowerCase() ?? "";
      final key = item.key?.toLowerCase().replaceAll("_", " ") ?? "";
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || subtitleLower.contains(searchLower) || key.contains(searchLower);
    }).toList();
  }


  toggleCheckbox({required String userType, required type, required int value, required index}){
    if(userType == "provider"){

      if(!_isActiveSuffixIcon){
        if(type=="notification"){
          _providerNotificationSetupList?[index].providerNotifications?.value?.notification = (value == 1) ? 0 : 1;
        }else if(type=="sms"){
          _providerNotificationSetupList?[index].providerNotifications?.value?.sms = (value == 1) ? 0 : 1;
        }else if(type=="email"){
          _providerNotificationSetupList?[index].providerNotifications?.value?.email = (value == 1) ? 0 : 1;
        }
      }else{
        if(type=="notification"){
          _searchedProviderNotificationSetupList?[index].providerNotifications?.value?.notification = (value == 1) ? 0 : 1;
        }else if(type=="sms"){
          _searchedProviderNotificationSetupList?[index].providerNotifications?.value?.sms = (value == 1) ? 0 : 1;
        }else if(type=="email"){
          _searchedProviderNotificationSetupList?[index].providerNotifications?.value?.email = (value == 1) ? 0 : 1;
        }
      }

    }else{
      if(!_isActiveSuffixIcon){
        if(type=="notification"){
          servicemanNotificationSetupList?[index].providerNotifications?.value?.notification = (value == 1) ? 0 : 1;
        }else if(type=="sms"){
          _servicemanNotificationSetupList?[index].providerNotifications?.value?.sms = (value == 1) ? 0 : 1;
        }else if(type=="email"){
          _servicemanNotificationSetupList?[index].providerNotifications?.value?.email = (value == 1) ? 0 : 1;
        }
      }else{
        if(type=="notification"){
          _searchedServicemanNotificationSetupList?[index].providerNotifications?.value?.notification = (value == 1) ? 0 : 1;
        }else if(type=="sms"){
          _searchedServicemanNotificationSetupList?[index].providerNotifications?.value?.sms = (value == 1) ? 0 : 1;
        }else if(type=="email"){
          _searchedServicemanNotificationSetupList?[index].providerNotifications?.value?.email = (value == 1) ? 0 : 1;
        }
      }
    }

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
    _isActiveSuffixIcon = false;
    if(shouldUpdate){
      update();
    }else{
      tabController?.index = 0;
    }
  }


}