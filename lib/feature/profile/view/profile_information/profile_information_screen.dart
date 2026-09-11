import 'dart:io';

import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:geolocator/geolocator.dart';

class ProfileInformationScreen extends StatefulWidget {
  const ProfileInformationScreen({super.key});

  @override
  State<ProfileInformationScreen> createState() => _ProfileInformationScreenState();
}

class _ProfileInformationScreenState extends State<ProfileInformationScreen> {
  final FocusNode _companyNameFocus = FocusNode();
  final FocusNode _companyPhoneFocus = FocusNode();
  final FocusNode _companyEmailFocus = FocusNode();
  final FocusNode _companyAddressFocus = FocusNode();
  final FocusNode _contactPersonNameFocus = FocusNode();
  final FocusNode _contactPersonPhoneFocus = FocusNode();
  final FocusNode _contactPersonEmailFocus = FocusNode();
  final FocusNode _panFocus = FocusNode();
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _loadProfileData();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final userController = Get.find<UserProfileController>();
    await userController.getProviderInfo(reload: true);
    await userController.getZoneList();

    if (userController.selectedZoneName.isEmpty && userController.myZone.isNotEmpty) {
      userController.setNewZoneValue(
        userController.myZone,
        userController.myZoneId ?? userController.selectedZoneID,
      );
    }

    final providerInfo = userController.providerModel?.content?.providerInfo;
    if (providerInfo != null) {
      Get.find<LocationController>().setPickedLocation(
        address: ServiceAddress(
          address: providerInfo.companyAddress,
          lat: providerInfo.coordinates?.latitude,
          lon: providerInfo.coordinates?.longitude,
        ),
        shouldUpdate: false,
      );
      _addressController.text = providerInfo.companyAddress ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(title: 'profile_information'.tr),
      body: GetBuilder<UserProfileController>(
        builder: (userController) {
          if (userController.providerModel == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Form(
              key: userController.profileInformationFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogoSection(userController),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    inputType: TextInputType.text,
                    controller: userController.companyNameController,
                    title: 'company/individual_name'.tr,
                    hintText: 'company_name_hint'.tr,
                    focusNode: _companyNameFocus,
                    nextFocus: _companyPhoneFocus,
                    capitalization: TextCapitalization.words,
                    onValidate: (value) => (value == null || value.isEmpty) ? 'company_name_hint'.tr : null,
                    onChanged: (_) {
                      if (userController.keepPersonalInfoAsCompanyInfo) {
                        userController.togglePersonalInfoAsCompanyInfo();
                        userController.togglePersonalInfoAsCompanyInfo();
                      }
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    onCountryChanged: (CountryCode countryCode) {
                      userController.countryDialCode = countryCode.dialCode!;
                    },
                    countryDialCode: userController.countryDialCode,
                    hintText: 'ex : 123456789'.tr,
                    controller: userController.companyPhoneController,
                    inputType: TextInputType.phone,
                    focusNode: _companyPhoneFocus,
                    nextFocus: _companyEmailFocus,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'phone_number_hint'.tr;
                      }
                      return FormValidationHelper().isValidPhone(userController.countryDialCode + value);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    inputType: TextInputType.emailAddress,
                    controller: userController.companyEmailController,
                    title: 'email'.tr,
                    hintText: 'enter_company_email_address'.tr,
                    focusNode: _companyEmailFocus,
                    nextFocus: _companyAddressFocus,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'empty_email_hint'.tr;
                      }
                      return FormValidationHelper().isValidEmail(value);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  GetBuilder<LocationController>(
                    builder: (locationController) {
                      final addressText = locationController.pickAddress.address?.isNotEmpty == true
                          ? locationController.pickAddress.address!
                          : userController.providerModel?.content?.providerInfo?.companyAddress ?? '';
                      if (_addressController.text != addressText) {
                        _addressController.text = addressText;
                      }

                      return GestureDetector(
                        onTap: () => _checkPermission(() => Get.to(() => const PickMapScreen())),
                        child: CustomTextField(
                          inputType: TextInputType.text,
                          controller: _addressController,
                          hintText: 'address_hint'.tr,
                          title: 'address'.tr,
                          focusNode: _companyAddressFocus,
                          isEnabled: locationController.pickAddress.address?.isNotEmpty == true,
                          suffixIconUrl: Images.pickPointLocation,
                          onSuffixTap: () => Get.to(() => const PickMapScreen()),
                          onValidate: (value) {
                            final address = locationController.pickAddress.address ??
                                userController.providerModel?.content?.providerInfo?.companyAddress;
                            return (address == null || address.isEmpty) ? 'enter_address'.tr : null;
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  TextFieldTitle(title: 'select_zone'.tr, requiredMark: true, isPadding: false),
                  _buildZoneDropdown(userController),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    inputType: TextInputType.text,
                    controller: userController.panNumberController,
                    title: 'Pan Number',
                    hintText: 'Pan Number',
                    focusNode: _panFocus,
                    nextFocus: _contactPersonNameFocus,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  _buildPanImageSection(userController),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      InkWell(
                        onTap: userController.togglePersonalInfoAsCompanyInfo,
                        child: Text('same_as_general_info'.tr, style: robotoRegular),
                      ),
                      Checkbox(
                        value: userController.keepPersonalInfoAsCompanyInfo,
                        onChanged: (_) => userController.togglePersonalInfoAsCompanyInfo(),
                      ),
                    ],
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    inputType: TextInputType.text,
                    controller: userController.personalNameController,
                    title: 'contact_person_name'.tr,
                    hintText: 'enter_contact_person_name'.tr,
                    focusNode: _contactPersonNameFocus,
                    nextFocus: _contactPersonPhoneFocus,
                    onValidate: (value) => (value == null || value.isEmpty) ? 'enter_contact_person_name'.tr : null,
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    onCountryChanged: (CountryCode countryCode) {
                      userController.countryDialCode = countryCode.dialCode!;
                    },
                    countryDialCode: userController.countryDialCode,
                    hintText: 'ex : 123456789'.tr,
                    controller: userController.personalPhoneController,
                    inputType: TextInputType.phone,
                    focusNode: _contactPersonPhoneFocus,
                    nextFocus: _contactPersonEmailFocus,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'phone_number_hint'.tr;
                      }
                      return FormValidationHelper().isValidPhone(userController.countryDialCode + value);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  CustomTextField(
                    inputType: TextInputType.emailAddress,
                    controller: userController.personalEmailController,
                    title: 'email'.tr,
                    hintText: 'enter_contact_person_email_address'.tr,
                    focusNode: _contactPersonEmailFocus,
                    inputAction: TextInputAction.done,
                    onValidate: (value) {
                      if (value == null || value.isEmpty) {
                        return 'empty_email_hint'.tr;
                      }
                      return FormValidationHelper().isValidEmail(value);
                    },
                  ),
                  const SizedBox(height: Dimensions.paddingSizeExtraLarge),
                  CustomButton(
                    btnTxt: 'update'.tr,
                    isLoading: userController.isLoading,
                    onPressed: () async {
                      if (!userController.profileInformationFormKey.currentState!.validate()) {
                        return;
                      }
                      userController.onProfileChangeValidationCheck();
                      if (!userController.isZoneValid) {
                        return;
                      }

                      final locationController = Get.find<LocationController>();
                      final address = locationController.pickAddress.address ??
                          userController.providerModel?.content?.providerInfo?.companyAddress ??
                          '';

                      final response = await userController.updateProfile(address: address);
                      if (response.isSuccess == true) {
                        showCustomSnackBar(response.message, type: ToasterMessageType.success);
                        Get.back();
                      } else {
                        showCustomSnackBar(response.message);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogoSection(UserProfileController userController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(title: 'SP Image'.tr, requiredMark: true),
        Row(
          children: [
            userController.pickedFile != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(userController.pickedFile!.path),
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                      ),
                      Positioned(
                        top: -10,
                        right: -10,
                        child: IconButton(
                          onPressed: userController.resetImage,
                          icon: const Icon(Icons.highlight_remove_rounded, color: Colors.red, size: 25),
                        ),
                      ),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImage(
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      image: userController.providerModel?.content?.providerInfo?.logoFullPath ?? '',
                      placeholder: Images.userPlaceHolder,
                    ),
                  ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            CustomButton(
              btnTxt: 'upload_file'.tr,
              width: 120,
              height: 40,
              onPressed: userController.pickImage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPanImageSection(UserProfileController userController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFieldTitle(title: 'Pan image'.tr),
        Row(
          children: [
            userController.pickedPanImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(userController.pickedPanImage!.path),
                      fit: BoxFit.cover,
                      height: 100,
                      width: 100,
                    ),
                  )
                : userController.panImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CustomImage(
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          image: userController.panImageUrl!,
                        ),
                      )
                    : DottedBorderBox(
                        height: 100,
                        width: 100,
                        onTap: userController.pickPanImage,
                      ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            CustomButton(
              btnTxt: 'upload_file'.tr,
              width: 120,
              height: 40,
              onPressed: userController.pickPanImage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildZoneDropdown(UserProfileController userController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: Get.width,
          height: 40,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: userController.isZoneValid
                    ? Theme.of(context).hintColor
                    : Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ZoneData>(
              isExpanded: true,
              menuMaxHeight: Get.height * .40,
              dropdownColor: Theme.of(context).cardColor,
              value: userController.zoneList.firstWhereOrNull(
                (zone) => zone.id == userController.selectedZoneID,
              ),
              hint: Text(
                userController.selectedZoneName.isEmpty ? 'select_your_zone'.tr : userController.selectedZoneName,
                style: robotoRegular.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                ),
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: userController.zoneList.map((zoneData) {
                return DropdownMenuItem(
                  value: zoneData,
                  child: Text(zoneData.name ?? '', style: robotoRegular),
                );
              }).toList(),
              onChanged: (ZoneData? zoneData) {
                if (zoneData != null) {
                  userController.setNewZoneValue(zoneData.name!, zoneData.id!);
                  userController.onProfileChangeValidationCheck();
                }
              },
            ),
          ),
        ),
        if (!userController.isZoneValid)
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              'fill_required_field'.tr,
              style: robotoRegular.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
          ),
      ],
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else {
      onTap();
    }
  }
}
