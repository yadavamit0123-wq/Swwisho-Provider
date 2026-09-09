import 'package:demandium_provider/feature/custom_post/model/post_model.dart';
import 'package:demandium_provider/feature/dashboard/model/additional_info_count.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:demandium_provider/utils/core_export.dart';

enum EarningType{monthly, yearly}
class  DashboardController extends GetxController with GetSingleTickerProviderStateMixin implements GetxService {
  final DashBoardRepo dashBoardRepo;

  DashboardController({required this.dashBoardRepo});

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(vsync: this, length: 2);
  }

  bool _isLeapYear=false;
  get isLeapYear=> _isLeapYear;

  TabController? tabController;

  DashboardTopCards? dashboardTopCards;
  AdditionalInfoCount? additionalInfoCount;

  List<DashboardServicemanModel> dashboardServicemanList =[];
  List<DashboardRecentActivityModel> dashboardRecentActivityList=[];
  List<SubscriptionModelData> dashboardSubscriptionList=[];
  List<PostData> dashboardCustomizedPostList = [];

  bool _showNormalBooking = true;
  bool get showNormalBooking => _showNormalBooking;

  bool _showRecentActivityList = true;
  bool get showRecentActivityList => _showRecentActivityList;

  int _paymentMethodIndex = -1;


  EarningType  _showMonthlyEarnStatisticsChart = EarningType.monthly;

  int get paymentMethodIndex => _paymentMethodIndex;


  EarningType get getChartType => _showMonthlyEarnStatisticsChart;

  void changeGraph(EarningType selectedType){
    _showMonthlyEarnStatisticsChart = selectedType;
    _selectedYear = DateConverter.stringYear(DateTime.now());
    _selectedMonth =  DateFormat('MMMM').format(DateTime.now());
    update();
  }

  void changeTypeOfShowBookingStatus({required bool status, bool shouldUpdate = true}){
    _showNormalBooking = status;
    if(status){
      tabController?.index = 0;
    }
    if(shouldUpdate){
      update();
    }
  }
  void changeRecentActivityView({bool? status, bool shouldUpdate = true}){
    if(status != null){
      _showRecentActivityList = status;
    }else{
      _showRecentActivityList = !_showRecentActivityList;
    }
    if(shouldUpdate){
      update();
    }
  }

  Future<void> getDashboardData({bool reload = false}) async {

    if(reload){
      dashboardTopCards = null;
    }

    Response response = await dashBoardRepo.getDashBoardData();

    if(response.statusCode==200){
      dashboardTopCards = DashboardTopCards.fromJson(response.body['content'][0]['top_cards']);

      dashboardRecentActivityList = [];
      List<dynamic> resentList = response.body['content'][3]['recent_bookings'];
      for (var element in resentList) {
        dashboardRecentActivityList.add(DashboardRecentActivityModel.fromJson(element));
      }


      dashboardSubscriptionList=[];
      List<dynamic> subscriptionList = response.body['content'][4]['subscriptions'];
      for (var element in subscriptionList) {
        dashboardSubscriptionList.add(SubscriptionModelData.fromJson(element));
      }

      dashboardServicemanList = [];
      List<dynamic> servicemanList = response.body['content'][5]['serviceman_list'];
      for (var element in servicemanList) {
        {
        if(element['user']['is_active']==1){
          dashboardServicemanList.add(DashboardServicemanModel.fromJson(element));
        }
      }
      }
      dashboardCustomizedPostList = [];
      List<dynamic> customizedPost = response.body['content'][6]['customized_post'];
      for (var element in customizedPost) {
        dashboardCustomizedPostList.add(PostData.fromJson(element));
      }

      additionalInfoCount = AdditionalInfoCount.fromJson(response.body['content'][7]['additional_info_count']);

      if(dashboardRecentActivityList.isEmpty && dashboardCustomizedPostList.isNotEmpty){
        tabController?.index = 1;
        _showNormalBooking = false;
      }

    }
    else{
      ApiChecker.checkApi(response);
    }

    update();
  }


  void removeSubscriptionItem(String id,{bool shouldUpdate = true}){
    dashboardSubscriptionList.removeWhere((element) => element.subCategoryId == id);
    if(shouldUpdate){
      update();
    }
  }


  //Monthly Stats
  List<MonthlyStats> _monthlyStatsList =[];
  List<MonthlyStats> get monthlyStatsList=> _monthlyStatsList;

  List<double> _mStatsList = [];
  List<double> get mStatsList => _mStatsList;

  List<FlSpot> _monthlyChartList = [];
  List<FlSpot> get monthlyChartList =>_monthlyChartList;

  double _mmM =0;
  double get mmM => _mmM;

  String _selectedYear = DateConverter.stringYear(DateTime.now());
  String get selectedYear => _selectedYear;
  String _selectedMonth = DateFormat('MMMM').format(DateTime.now());
  String get selectedMonth => _selectedMonth;


  Future<void> getMonthlyBookingsDataForChart(String year,String month) async {
    _monthlyStatsList = [];
    Response response = await dashBoardRepo.getMonthlyDashBoardChartData(year,month);
    if(response.statusCode == 200) {
      _monthlyStatsList = [];
      _mStatsList = [];
      _monthlyChartList = [];
      response.body['content'][0]['earning_stats'].forEach((element){
        _monthlyStatsList.add(MonthlyStats.fromJson(element));
      });
      if(month == '2'){
        int lip=0;
        bool isLeapYear(yer) => (yer % 4 == 0) && ((yer % 100 != 0) || (yer % 400 == 0));
        bool leapYear = isLeapYear(int.tryParse(year));
        if(leapYear == true){
          _isLeapYear=true;
          lip=30;
          update();
        }else {
          lip=29;
        }
        for(int i = 0; i<lip; i++){
          _mStatsList.add(0);
        }
      }
      else if(month == '2'){
        for(int i = 0; i<30; i++){
          _mStatsList.add(0);
        }
      }else if(month == '4' || month == '6' || month == '9' || month == '11'){
        for(int i = 0; i<31; i++){
          _mStatsList.add(0);
        }
      }else if(month == '1' || month == '3' || month == '5' || month == '7' || month == '8' || month == '10' || month == '12'){
        for(int i = 0; i<32; i++){
          _mStatsList.add(0);
        }
      }
      for(int i = 0; i< _monthlyStatsList.length; i++){

         _mStatsList[_monthlyStatsList[i].day!] = double.tryParse(_monthlyStatsList[i].sums!)!.toDouble();
      }

      _monthlyChartList = _mStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();
      _mStatsList.sort();

      _mmM = _mStatsList[_mStatsList.length-1];
      update();

    }
    else {

    }
    update();
  }


  //yearly Stats
  List<YearlyStats> _yearlyStatsList =[];
  List<YearlyStats> get yearlyStatsList=> _yearlyStatsList;

  List<double> _yStatsList = [];
  List<double> get yStatsList => _yStatsList;

  List<FlSpot> _yearlyChartList = [];
  List<FlSpot> get yearlyChartList =>_yearlyChartList;

  double _mmY =0;
  double get mmY => _mmY;

  Future<void> getYearlyBookingsDataForChart(String year) async {
    _yearlyStatsList = [];
    Response response = await dashBoardRepo.getYearlyDashBoardChartData(year);
    if(response.statusCode == 200) {
      _yearlyStatsList = [];
      _yStatsList = [];
      _yearlyChartList = [];

      List<dynamic> yearlyDynamicList= response.body['content'][0]['earning_stats'];
      for (var element in yearlyDynamicList) {
        _yearlyStatsList.add(YearlyStats.fromJson(element));
      }

      for(int i =0; i<13; i++){
        _yStatsList.add(0);
      }

      for(int i = 0; i< _yearlyStatsList.length; i++){

        _yStatsList[monthMap[_yearlyStatsList[i].month]!] = double.tryParse(_yearlyStatsList[i].sums!)!.toDouble();
      }

      _yearlyChartList = _yStatsList.asMap().entries.map((e) {
        return FlSpot(e.key.toDouble(), e.value);
      }).toList();

      _yStatsList.sort();

      _mmY = _yStatsList[_yStatsList.length-1];
      update();

    }else {

    }
    update();
  }

  void changeDashboardDropdownValue(String indexValue,String value,String type){
    if(type=="Year"){
      _selectedYear=indexValue;
      if(_selectedYear !="Select" && _showMonthlyEarnStatisticsChart == EarningType.yearly){
        getYearlyBookingsDataForChart(_selectedYear);
      }
      update();
    }else if(type=="Month"){
      _selectedMonth=value;
      if(_selectedYear !="Select"){
        getMonthlyBookingsDataForChart(_selectedYear,indexValue);
      }
      update();
    }
  }

  void updateIndex (int index, {bool isUpdate = true}) {
    _paymentMethodIndex = index;
    if(isUpdate){
      update();
    }
  }


  void removeServiceman (String id , {bool isUpdate = true}){
    dashboardServicemanList.removeWhere((element) => element.id == id);
    if(isUpdate){
      update();
    }
  }

}








