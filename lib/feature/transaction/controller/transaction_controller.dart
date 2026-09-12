
import 'dart:convert';

import 'package:demandium_provider/common/model/api_response_model.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';
import '../../profile/view/wallet_history/model/wallet_history_tran_model.dart';


class TransactionController extends GetxController implements GetxService{

  final TransactionRepo transactionRepo;
  TransactionController({required this.transactionRepo});

  int? _pageSize;
  int _offset = 1;

  int get offset => _offset;
  int? get pageSize => _pageSize;

  bool _isLoading= false;
  bool get isLoading => _isLoading;

  bool? _paginationLoading = false;
  bool? get paginationLoading => _paginationLoading;

  List<TransactionData>? _transactionsList =[];
  List<TransactionData>? get transactionsList => _transactionsList;

  String? _defaultPaymentMethodId;
  String? _defaultPaymentMethodName;

  String? get  defaultPaymentMethodId => _defaultPaymentMethodId;
  String? get  defaultPaymentMethodName => _defaultPaymentMethodName;

  WithdrawModel? _withdrawModel;
  WithdrawModel? get withdrawModel => _withdrawModel;

  List<WithdrawalMethod>? _withdrawalMethods;
  List<WithdrawalMethod>? get withdrawalMethods => _withdrawalMethods;

  String? _selectAmount;
  String? get selectAmount => _selectAmount;
  int _transactionTypeIndex = -1;
  int get transactionTypeIndex => _transactionTypeIndex;

  final ScrollController scrollController = ScrollController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  List<WalletTransactionHistory> walletTransactions = [];

  Future<void> fetchWalletHistory() async {
    try {
      _isLoading = true;
      update();

      Response response = await transactionRepo.getWalletTransHistory();

      if (response.statusCode == 200) {
        final decoded = _walletHistoryListFrom(response.body);
        walletTransactions
          ..clear()
          ..addAll(decoded);
      } else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      debugPrint('Error fetching wallet history: $e');
    } finally {
      _isLoading = false;
      update();
    }
  }

  List<WalletTransactionHistory> _walletHistoryListFrom(dynamic body) {
    dynamic raw = body;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        return [];
      }
    }
    List<dynamic> list = [];
    if (raw is List) {
      list = raw;
    } else if (raw is Map) {
      final content = raw['content'];
      if (content is List) {
        list = content;
      } else if (content is Map && content['data'] is List) {
        list = content['data'];
      } else if (raw['data'] is List) {
        list = raw['data'];
      }
    }

    final result = <WalletTransactionHistory>[];
    for (final item in list) {
      try {
        if (item is Map) {
          result.add(WalletTransactionHistory.fromJson(Map<String, dynamic>.from(item)));
        }
      } catch (_) {}
    }
    return result;
  }

  @override
  void onInit() {

    super.onInit();
    scrollController.addListener(() {
      if(scrollController.position.maxScrollExtent == scrollController.position.pixels) {
        if(_offset < _pageSize! ) {
          getWithdrawRequestList(offset+1,true, shouldUpdate: false);
        }
      }
    });
  }

  bool _isTranToWalLoading = false;
  bool get isTranToWallLoading => _isTranToWalLoading;
  TextEditingController tranToWallController = TextEditingController();

  transferToWallet() async{
    _isTranToWalLoading = true;
    update();
    try{
      Response response = await transactionRepo.transferToRechargeWallet(amount: tranToWallController.text.toString());
      if(response.statusCode==200){
        final responseData = response.body;
        String message = responseData['message'] ?? "Success";
        showCustomSnackBar(message, type: ToasterMessageType.success);
      }
      _isTranToWalLoading = false;
      update();
    }catch(e){
      _isTranToWalLoading = false;
      update();
      showCustomSnackBar("Transferring.. ${e.toString()}".tr,type: ToasterMessageType.error);
    }
  }

  Future<void> getWithdrawRequestList(int offset,bool isFormPagination, {bool shouldUpdate = true}) async {
    _offset = offset;

      if(!isFormPagination){
        _transactionsList = [];
        _isLoading = true;
      }else{
        _paginationLoading = true;
      }
    Response response = await transactionRepo.getTransactionsList(offset);
    if(response.statusCode==200){
      _pageSize =response.body['content']['withdraw_requests']['last_page'];
     List<dynamic> transactionList = response.body['content']['withdraw_requests']['data'];
     for (var element in transactionList) {
         transactionsList!.add(TransactionData.fromJson(element));
     }
    }
    else if(response.statusCode == 401){
      ApiChecker.checkApi(response);
    }
    _paginationLoading = false;
    _isLoading = false;
    update();
  }


  Future<void> withDrawRequest({Map<String, String>? placeBody})async{
    _isLoading = true;
    update();
    Response response = await transactionRepo.withdrawRequest(placeBody: placeBody);

    if(response.statusCode == 200 && response.body["response_code"] == 'default_200' ){
      await Get.find<UserProfileController>().getProviderInfo(reload: true);

      Get.back();
      Get.back();
      showCustomSnackBar('withdraw_request_send_successful'.tr,  type: ToasterMessageType.success);
    } else if (response.statusCode == 400){
      Get.back();
      showCustomSnackBar(response.body['errors'][0]['message']);
    }else{
      Get.back();
      showCustomSnackBar(response.statusText);

    }
    _isLoading = false;
    update();
  }


  Future<void> getWithdrawMethods({bool isReload = false}) async{
    if(_withdrawModel == null || isReload) {
      Response response = await transactionRepo.getWithdrawMethods();
      ResponseModelApi responseApi = ResponseModelApi.fromJson(response.body);

      if(responseApi.responseCode == 'default_200' && responseApi.content != null) {
        _withdrawModel = WithdrawModel.fromJson(response.body);

        _withdrawModel?.withdrawalMethods?.forEach((element) {
          if(element.isDefault==1){
            _defaultPaymentMethodId = element.id;
            _defaultPaymentMethodName = element.methodName;
          }
        });
      }else{
        _withdrawModel = WithdrawModel(withdrawalMethods: [],);
        ApiChecker.checkApi(response);
      }
    }
    update();
  }

  Future<void> adjustTransaction() async{
    _isLoading = true;
    update();
    Response response = await transactionRepo.adjustTransaction();

    if(response.statusCode == 200){
     await  Get.find<UserProfileController>().getProviderInfo(reload: true);
     showCustomSnackBar(response.body['message'],  type: ToasterMessageType.success);
    }else{
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }



  void setIndex(int index , String amount) {
    _transactionTypeIndex = index;
    _selectAmount = amount;
    update();
  }

  void selectAmountSet(String value) {
    _selectAmount = value;
    update(['inputAmountListController']);
  }
}