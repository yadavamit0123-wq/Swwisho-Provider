import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';

class BusinessSettingScreen extends StatefulWidget{
  const BusinessSettingScreen({super.key});

  @override
  State<BusinessSettingScreen> createState() => _BusinessSettingScreenState();
}

class _BusinessSettingScreenState extends State<BusinessSettingScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<BusinessSettingController>().initServiceLocationValue();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BusinessSettingController>(builder: (businessSettingController){
      return Scaffold( backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: CustomAppBar(title: "business_settings".tr),

        body:  SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(children: [
          
              Container(
                margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: Colors.blue
                      )
                  ),
                ),
                child: TabBar(
                  unselectedLabelColor:Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha:0.5),
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).primaryColorLight,
                  labelStyle:  robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                  labelPadding: EdgeInsets.zero,
                  tabs:  [
                    SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width* .5,
                      child:Center(
                        child: Text("service_availability".tr),
                      ),
                    ),
                    // SizedBox(
                    //   height: 40,
                    //   width: MediaQuery.of(context).size.width*.4,
                    //   child:  Center(
                    //     child: Text("bookings".tr),
                    //   ),
                    // ),
                  ],
                ),
              ),
          
              const Expanded(
                child: TabBarView(
                  children: [
                    ServiceAvailabilitySetup(),
                    // BookingSetupWidget(),
                  ],
                ),
              ),
            ]),
          ),
        ),
      );
    });
  }
}

class SwitchButton extends StatelessWidget {
  final String titleText;
  final String tootTipText;
  final int value;
  final Function(bool) onTap;
  final JustTheController ? tooltipController;
  final bool showOutSideBorder;
  final TextStyle ? titleTextStyle;
  const SwitchButton({super.key, required this.titleText, required this.value, required this.onTap,this.tooltipController,this.showOutSideBorder = false, this.titleTextStyle, required this.tootTipText,});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: showOutSideBorder ? Border.all(color: Theme.of(context).primaryColor) : null,
        boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [ Row(children: [

        Text( titleText.tr, style: titleTextStyle ?? robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),),
        const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

        if(tooltipController !=null)
        JustTheTooltip( backgroundColor: Colors.black87, controller: tooltipController,
          preferredDirection: AxisDirection.down, tailLength: 14, tailBaseWidth: 20,
          content: Padding( padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child:  Text(tootTipText.tr, style: robotoRegular.copyWith(color: Colors.white,)),
          ),
          child:  InkWell( onTap: ()=> tooltipController?.showTooltip(),
            child: Icon(Icons.info_outline_rounded, color: Theme.of(context).colorScheme.primary, size: 18,),
          )
        )]),

        FlutterSwitch(
          width: 40, height: 22, valueFontSize: Dimensions.fontSizeExtraSmall, showOnOff: true,
          activeText: "", inactiveText: "", activeColor: Theme.of(context).primaryColor,
          value: value == 1 ?  true : false,
          padding: 1.5,
          toggleSize: 19,
          onToggle: (value) => onTap(value),
        ),
      ],),
    );
  }
}