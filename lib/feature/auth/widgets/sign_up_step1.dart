import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:demandium_provider/utils/core_export.dart';


class SignUpStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignUpStep1({super.key, required this.formKey});

  @override
  State<SignUpStep1> createState() => _SignUpStep1State();
}

class _SignUpStep1State extends State<SignUpStep1> {
  final FocusNode _companyNameFocus= FocusNode();
  final FocusNode _companyPhoneFocus = FocusNode();
  final FocusNode _companyEmailFocus = FocusNode();
  final FocusNode _companyAddressFocus = FocusNode();

  final FocusNode _contactPersonNameFocus= FocusNode();
  final FocusNode _contactPersonPhoneFocus = FocusNode();
  final FocusNode _contactPersonEmailFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: GetBuilder<SignUpController>(builder: (signUpController) {
          return Form(
            key: widget.formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
                    color: Theme.of(context).cardColor
                  ),
                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                  margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,Dimensions.paddingSizeDefault, Dimensions.paddingSizeSmall,3),

                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                    Text("basic_information".tr,
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.8), fontSize: Dimensions.fontSizeLarge),
                    ),


                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),
                    CustomTextField(
                      inputType: TextInputType.text,
                      controller: signUpController.companyNameController,
                      title: "company/individual_name".tr,
                      hintText: "company_name_hint".tr,
                      focusNode: _companyNameFocus,
                      nextFocus: _companyPhoneFocus,
                      capitalization: TextCapitalization.words,
                      onValidate: (value){
                        return (value ==null || value.isEmpty) ? "company_name_hint".tr : null;
                      },
                      onChanged: (value){
                        signUpController.autoSaveContactPersonInfoAsGeneralInfo();
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    CustomTextField(
                      onCountryChanged: (CountryCode countryCode){
                        signUpController.countryDialCode = countryCode.dialCode!;
                      },
                      countryDialCode: signUpController.countryDialCode,
                      hintText: 'ex : 123456789'.tr,
                      controller: signUpController.companyPhoneController,
                      inputType: TextInputType.phone,
                      focusNode: _companyPhoneFocus,
                      nextFocus: _companyEmailFocus,
                      onValidate: (value){
                        if(value == null || value.isEmpty){
                          return 'phone_number_hint'.tr;
                        }else{
                          return FormValidationHelper().isValidPhone(signUpController.countryDialCode+(value));
                        }
                      },
                      onChanged: (value){
                        signUpController.autoSaveContactPersonInfoAsGeneralInfo();
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),

                    CustomTextField(
                      inputType: TextInputType.text,
                      controller: signUpController.companyEmailController,
                      title: "email".tr,
                      hintText:'enter_company_email_address'.tr,
                      focusNode: _companyEmailFocus,
                      nextFocus: _companyAddressFocus,
                      onValidate: (value){
                        if(value == null || value.isEmpty){
                          return 'empty_email_hint'.tr;
                        }else{
                          return FormValidationHelper().isValidEmail(value);
                        }
                      },
                      onChanged: (value){
                        signUpController.autoSaveContactPersonInfoAsGeneralInfo();
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),


                    GetBuilder<LocationController>(builder: (locationController){
                      return GestureDetector(
                        onTap: (){
                          _checkPermission(() {
                            Get.to(()=>const PickMapScreen());
                          });
                        },
                        child: CustomTextField(
                          inputType: TextInputType.text,
                          controller: signUpController.companyAddressController,
                          hintText: "address_hint".tr,
                          title: "address".tr,
                          focusNode: _companyAddressFocus,
                          capitalization: TextCapitalization.sentences,
                          inputAction: TextInputAction.done,
                          isEnabled : Get.find<LocationController>().pickAddress.address != "" ? true : false,
                          suffixIcon: Images.pickPointLocation,
                          onPressedSuffix: (){
                            Get.to(()=>const PickMapScreen());
                          },
                          onValidate: (value){
                            return (value ==null || value.isEmpty) ? "enter_address".tr  : null;
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: Dimensions.paddingSizeDefault),

                    TextFieldTitle(title: "SP Image".tr, requiredMark: true),
                    Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                           SizedBox(
                             width: MediaQuery.of(context).size.width * 0.4,
                             child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

                               signUpController.profileImageFile!=null ?
                               Stack(
                                 children: [
                                   ClipRRect(borderRadius: BorderRadius.circular(10),
                                     child: Image.file(File(signUpController.profileImageFile!.path),
                                         fit: BoxFit.cover, height: 100, width: 100
                                     ),
                                   ),

                                   Positioned(top: -10, right: -10,
                                       child: IconButton(onPressed: ()=>signUpController.pickProfileImage(true),
                                           icon: const Icon(Icons.highlight_remove_rounded,color: Colors.red,size: 25)
                                       )
                                   ),
                                 ],
                               ) : DottedBorderBox(
                                 height: 100,
                                 width: 100,
                                 showErrorBorder: !signUpController.isLogoValid,
                                 onTap: ()=> signUpController.pickProfileImage(false),
                               ),



                             ],),
                           ),

                            Expanded(
                              child: Text("image_validation_text_1".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                                maxLines: 5,
                              ),
                            ),
                          ],
                        ),
                        !signUpController.isLogoValid ?
                        Padding(padding: const EdgeInsets.only(top: Dimensions.paddingSizeExtraSmall),
                          child: Text("provide_image_logo".tr,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(color: Theme.of(context).colorScheme.error, fontSize: Dimensions.fontSizeSmall),
                          ),
                        ) : const SizedBox()
                      ],
                    ),

                  ],),
                ),


                Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  child: Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      InkWell(
                        onTap: ()=> signUpController.togglePersonalInfoAsCompanyInfo(),
                        child: Text(
                          "same_as_general_info".tr,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      SizedBox(
                        width: 20.0,
                        child: Checkbox(
                          checkColor: Colors.white,
                          activeColor: Theme.of(context).primaryColor,
                          value: signUpController.keepPersonalInfoAsCompanyInfo,
                          onChanged: (bool? isChecked) => signUpController.togglePersonalInfoAsCompanyInfo(),
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow,
                      color: Theme.of(context).cardColor
                  ),
                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeLarge),
                  margin: const EdgeInsets.fromLTRB(Dimensions.paddingSizeSmall,3,Dimensions.paddingSizeSmall,Dimensions.paddingSizeSmall),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      "contact_person_info_title".tr,
                      style: robotoBold.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha:0.8), fontSize: Dimensions.fontSizeLarge),
                    ),

                    const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                    CustomTextField(
                      inputType: TextInputType.text,
                      controller: signUpController.contactPersonNameController,
                      title: "contact_person_name".tr,
                      hintText: "enter_contact_person_name".tr,
                      capitalization: TextCapitalization.words,
                      focusNode: _contactPersonNameFocus,
                      nextFocus: _contactPersonPhoneFocus,
                      onValidate: (value){
                        return (value ==null || value.isEmpty) ? "enter_contact_person_name".tr : null;
                      },

                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge),


                    CustomTextField(
                      onCountryChanged: (CountryCode countryCode){
                        signUpController.countryDialCode = countryCode.dialCode!;
                      },
                      countryDialCode: signUpController.countryDialCode,
                      hintText: 'ex : 123456789'.tr,
                      controller: signUpController.contactPersonPhoneController,
                      inputType: TextInputType.phone,
                      focusNode: _contactPersonPhoneFocus,
                      nextFocus: _contactPersonEmailFocus,
                      onValidate: (value){

                        if(value == null || value.isEmpty){
                          return 'phone_number_hint'.tr;
                        }else{
                          return FormValidationHelper().isValidPhone(signUpController.countryDialCode+(value));
                        }

                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge),


                    CustomTextField(
                      inputType: TextInputType.emailAddress,
                      controller: signUpController.contactPersonEmailController,
                      title: "email".tr,
                      hintText: "enter_contact_person_email_address".tr,
                      focusNode: _contactPersonEmailFocus,
                      inputAction: TextInputAction.done,
                      onValidate: (value){
                        if(value == null || value.isEmpty){
                          return 'empty_email_hint'.tr;
                        }else{
                          return FormValidationHelper().isValidEmail(value);
                        }
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeLarge)
                  ],),
                ),


                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type : ToasterMessageType.info);
    }else if(permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog(), barrierDismissible: true);
    }else {
      onTap();
    }
  }

}
