import 'dart:convert';
import 'dart:math';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';

class WithdrawRequestScreen extends StatefulWidget {
  final double? amount;

   const WithdrawRequestScreen({super.key, this.amount = 0.0});
  @override
  State<WithdrawRequestScreen> createState() => _WithdrawRequestScreenState();
}

class _WithdrawRequestScreenState extends State<WithdrawRequestScreen> {
  final TextEditingController _inputAmountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String _selectedMethodId='';
  String _selectedMethodName ='';
  List<MethodField>? _fieldList;
  List<MethodField>? _gridFieldList;
  Map<String, TextEditingController> _textControllers =  {};
  final Map<String, FocusNode> _textControllersFocus =  {};
  Map<String, TextEditingController> _gridTextController =  {};
  final Map<String, FocusNode> _gridTextControllerFocus =  {};
  final FocusNode _inputAmountFocusNode = FocusNode();

  void setFocus() {
    _inputAmountFocusNode.requestFocus();
    Get.back();
  }

  Future<void> selectPaymentMethodField (String id, String name, TransactionController transactionMoneyController) async{

    _selectedMethodId = id;
    _selectedMethodName = name;
    _gridFieldList = [];
    _fieldList = [];

    for (var method in transactionMoneyController.withdrawModel!.withdrawalMethods!.firstWhere((method) =>
    method.id.toString() == id).methodFields!) {
      _gridFieldList!.addIf(method.inputName!.toLowerCase().contains('cvv') || method.inputType!.toLowerCase() == 'date', method);
    }

    for (var method in transactionMoneyController.withdrawModel!.withdrawalMethods!.firstWhere((method) =>
    method.id.toString() == id).methodFields!) {
      _fieldList!.addIf(!method.inputName!.toLowerCase().contains('cvv') && method.inputType != 'date', method);
    }
    _textControllers = _textControllers =  {};
    _gridTextController = _gridTextController =  {};

    for (var method in _fieldList!) {
      _textControllers[method.inputName!] = TextEditingController();
      _textControllersFocus[method.inputName!] = FocusNode();
    }
    for (var method in _gridFieldList!) {
      _gridTextController[method.inputName!] = TextEditingController();
      _gridTextControllerFocus[method.inputName!] = FocusNode();
    }

    transactionMoneyController.update();
  }

  void loadData() async {

    await Get.find<TransactionController>().getWithdrawMethods(isReload: true);
    _selectedMethodId = Get.find<TransactionController>().defaultPaymentMethodId!;
    _selectedMethodName = Get.find<TransactionController>().defaultPaymentMethodName!;
    selectPaymentMethodField(_selectedMethodId,_selectedMethodName, Get.find<TransactionController>());
  }
  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _inputAmountController.dispose();
    _noteController.dispose();
    _inputAmountFocusNode.dispose();
    _textControllers.forEach((key, textController) {
      textController.dispose();
    });
    _gridTextController.forEach((key, textController) {
      textController.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'withdraw_request'.tr),
      body: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {
          return SingleChildScrollView(
            child: Column( children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
                  color: Theme.of(context).cardColor,
                ),
                padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall,3),
                child: Form(
                  key: transactionMoneyController.formKey,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                    Text("business_information".tr,
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.8), fontSize: Dimensions.fontSizeLarge),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge,),

                    TextFieldTitle(title:'select_withdraw_method'.tr,
                      requiredMark: true,
                      fontSize: Dimensions.fontSizeExtraSmall,
                      isPadding: false,
                    ),

                    Container(width: Get.width, height: 40,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Theme.of(context).hintColor)),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(

                          borderRadius: BorderRadius.circular(5),

                          menuMaxHeight: Get.height * 0.5,

                          dropdownColor: Theme.of(context).cardColor,
                          hint: Text(_selectedMethodName!=''?_selectedMethodName:
                            'select_a_method'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha:0.8),
                            ),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down),
                          items: transactionMoneyController.withdrawModel?.withdrawalMethods!.map((WithdrawalMethod withdraw) {
                            return DropdownMenuItem(
                              alignment: AlignmentDirectional.center,
                              value: withdraw,
                              child: withdraw.isActive==1?
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    withdraw.methodName ?? 'no method'.tr,
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                                  ),
                                  if(withdraw.isDefault==1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: 3),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(color: Theme.of(context).primaryColorLight)
                                    ),
                                    child: Text("default".tr,
                                      style: robotoRegular.copyWith(color: Theme.of(context).primaryColorLight,
                                        fontSize: Dimensions.fontSizeSmall),
                                    ),
                                  )
                                ],
                              ):const SizedBox(),
                            );
                          }).toList(),
                          isExpanded: true,
                          underline: const SizedBox(),
                          onChanged: (WithdrawalMethod? withdraw) {
                            _selectedMethodName = withdraw!.methodName.toString();
                            _selectedMethodId = withdraw.id.toString();
                            selectPaymentMethodField(withdraw.id.toString(),withdraw.methodName.toString(), transactionMoneyController);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                    if(_fieldList != null && _fieldList!.isNotEmpty) ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _fieldList!.length,
                      padding: const EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeExtraSmall, horizontal: 0,
                      ),

                      itemBuilder: (context, index) => FieldItemView(
                        methodField:_fieldList![index],
                        textControllers: _textControllers,
                        focusNodes: _textControllersFocus,
                      ),
                    ),

                    if(_gridFieldList != null && _gridFieldList!.isNotEmpty)

                      GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: _gridFieldList!.length,
                        itemBuilder: (context, index) => FieldItemView(
                          methodField: _gridFieldList![index],
                          textControllers: _gridTextController,
                          focusNodes: _gridTextControllerFocus,
                        ),
                      ),

                    const SizedBox(height: Dimensions.paddingSizeDefault,),

                    CustomTextFormField(
                      inputType: TextInputType.text,
                      controller: _noteController,
                      hintText: "write_note_your_here".tr,
                      capitalization: TextCapitalization.words,
                      maxLines: 2,
                      maxLength: 255,
                    ),


                    InputBoxView(
                      inputAmountController: _inputAmountController,
                      focusNode: _inputAmountFocusNode,
                      amount: widget.amount,
                    ),

                  ],),
                ),
              ),


              const SizedBox(height: Dimensions.paddingSizeExtraLarge*4,),

            ],),
          );
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GetBuilder<TransactionController>(
        builder: (transactionMoneyController) {

          return   Container(
            height: 70,
            color: Theme.of(context).cardColor,
            child: Center(
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                  border: Border.all(color: Theme.of(context).primaryColorLight.withValues(alpha:.5)),
                  color: Theme.of(context).cardColor,
                ),
                child: Transform.rotate(
                  angle: Get.find<LocalizationController>().isLtr ? pi * 2 : pi, // in radians
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: SliderButton(
                      width:   Get.width - 20,
                      dismissible: false,
                      action: () async {
                        double amount;
                        double minimumWithdrawAmount= Get.find<SplashController>().configModel.content?.minimumWithdrawAmount??0;
                        double maximumWithdrawAmount= Get.find<SplashController>().configModel.content?.maximumWithdrawAmount??0;
                        if(_inputAmountController.text.isEmpty){
                          showCustomSnackBar('please_input_amount'.tr, type: ToasterMessageType.info);
                        }else{
                          String balance =  _inputAmountController.text;
                          balance = balance.replaceAll(PriceConverter.getCurrency(), '');
                          if(balance.contains(',')){
                            balance = balance.replaceAll(',', '');
                          }
                          if(balance.contains(' ')){
                            balance = balance.replaceAll(' ', '');
                          }
                          amount = double.parse(balance);

                          if(amount < minimumWithdrawAmount) {
                            showCustomSnackBar('${'withdraw_amount_grater_than'.tr} ${PriceConverter.convertPrice(minimumWithdrawAmount)}',type: ToasterMessageType.info);
                          }else if(amount > maximumWithdrawAmount){
                            showCustomSnackBar("${'maximum_withdraw_amount_is'.tr} ${PriceConverter.convertPrice(maximumWithdrawAmount)}", type: ToasterMessageType.info);
                          }
                          else if(amount < maximumWithdrawAmount&&amount>widget.amount!){
                            showCustomSnackBar('insufficient_balance'.tr, type: ToasterMessageType.info);
                          }
                          else {
                            if(transactionMoneyController.formKey.currentState!.validate()){
                              String? message;
                              WithdrawalMethod withdrawMethod = transactionMoneyController.withdrawModel!.withdrawalMethods!.
                              firstWhere((method) => _selectedMethodId == method.id.toString());

                              String validationKey = '';
                              List<Map<String,String>> methodFieldValue = [];
                              Map<String,String> value ={};

                              for (var method in withdrawMethod.methodFields!) {
                                if(method.inputType == 'email' ||method.inputType == 'date') {
                                  validationKey = method.inputType!;
                                }
                              }

                              _textControllers.forEach((key, textController) {
                                value.addAll({key:textController.text});

                                if((validationKey == key) && !GetUtils.isEmail(textController.text)) {
                                  message = 'please_provide_valid_email'.tr;
                                }else if((validationKey == key) && textController.text.contains('-')) {
                                  message = 'please_provide_valid_date'.tr;
                                }
                                if(textController.text.isEmpty && message == null) {
                                  message = 'please fill ${key.replaceAll('_', ' ')} field';
                                }
                              });

                              _gridTextController.forEach((key, textController) {
                                value.addAll({key:textController.text});

                                if(validationKey == 'date' && textController.text.contains('-')) {
                                  message = 'please_provide_valid_date'.tr;
                                }
                                if(textController.text.isEmpty && message == null) {
                                  message = 'Please fill ${key.replaceAll('_', ' ')} field';
                                }
                              });
                              if(message != null) {
                                showCustomSnackBar(message);
                                message = null;
                              }
                              else{
                                showCustomDialog(child: const CustomLoader());
                                Map<String, String> withdrawalMethodField = {};

                                for (var method in withdrawMethod.methodFields!) {
                                  withdrawalMethodField.addAll({'${method.inputName}' : '${method.placeholder}'});
                                }
                                methodFieldValue.add(value);

                                Map<String, String> withdrawRequestBody = {};
                                withdrawRequestBody = {
                                  'amount' : '$amount',
                                  'withdrawal_method_id' : '${withdrawMethod.id}',
                                  'withdrawal_method_fields' : base64Url.encode(utf8.encode(jsonEncode(methodFieldValue))),
                                  'note': _noteController.text
                                };
                                await Get.find<TransactionController>().withDrawRequest(placeBody: withdrawRequestBody);
                              }
                            }
                          }
                        }
                      },

                      label: Transform.rotate(
                        angle: Get.find<LocalizationController>().isLtr ? pi * 2 : pi,
                        child: Text('send_withdraw_request'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                              color: Theme.of(context).primaryColor
                          ),
                        ),
                      ),
                      alignLabel: Alignment.center,
                      dismissThresholds: 0.5,
                      icon: Center(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(Images.arrowButton),
                      )),
                      radius: 10,
                      boxShadow: const BoxShadow(blurRadius: 0.0),
                      buttonColor: Theme.of(context).primaryColor,
                      backgroundColor: Theme.of(context).cardColor,
                      baseColor: Theme.of(context).primaryColorLight.withValues(alpha:Get.isDarkMode?0.7:1),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      )
    );
  }
}





