import 'package:demandium_provider/common/model/customer_config_model.dart';

class ConfigModel {
  String? responseCode;
  String? message;
  ConfigContent? content;

  ConfigModel({this.responseCode, this.message, this.content});

  ConfigModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content = json['content'] != null ? ConfigContent.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class ConfigContent {
  String? businessName;
  String? logo;
  String? logoFullPath;
  String? favicon;
  String? faviconFullPath;
  String? countryCode;
  String? businessAddress;
  String? businessPhone;
  String? businessEmail;
  String? currencyDecimalPoint;
  String? currencySymbolPosition;
  String? currencySymbol;
  String? timeFormat;
  String? footerText;
  String? appEnvironment;
  String? additionalChargeLabelName;
  String? defaultCommission;

  int? paginationLimit;
  int? providerSelfRegistration;
  int? biddingStatus;
  int? digitalPayment;
  int? commissionBasePlan;
  int? subscriptionBasePlan;
  int? subscriptionFreeTrail;
  int? subscriptionDeadlineWarning;
  int? providerCanCancelBooking;
  int? providerCanEditBooking;
  int? providerSlfDelete;
  int? maxCashInHandLimit;
  int? suspendOnCashInHandLimit;
  int? bidOfferVisibilityForProvider;
  int? showPhoneNumber;
  int? bookingOtpVerification;
  int? bookingImageVerification;
  int? sendOtpTimer;

  double? minimumWithdrawAmount;
  double? maximumWithdrawAmount;

  ConfigDefaultLocation? defaultLocation;
  List<DigitalPaymentMethod>? paymentMethodList;
  MinimumVersion? minimumVersion;
  MaintenanceMode? maintenanceMode;
  List<Language>? languageList;

  ConfigContent({
    this.businessName,
    this.logo,
    this.logoFullPath,
    this.favicon,
    this.faviconFullPath,
    this.countryCode,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.currencyDecimalPoint,
    this.currencySymbolPosition,
    this.currencySymbol,
    this.timeFormat,
    this.footerText,
    this.appEnvironment,
    this.additionalChargeLabelName,
    this.defaultCommission,
    this.paginationLimit,
    this.providerSelfRegistration,
    this.biddingStatus,
    this.digitalPayment,
    this.commissionBasePlan,
    this.subscriptionBasePlan,
    this.subscriptionFreeTrail,
    this.subscriptionDeadlineWarning,
    this.providerCanCancelBooking,
    this.providerCanEditBooking,
    this.providerSlfDelete,
    this.maxCashInHandLimit,
    this.suspendOnCashInHandLimit,
    this.bidOfferVisibilityForProvider,
    this.showPhoneNumber,
    this.bookingOtpVerification,
    this.bookingImageVerification,
    this.sendOtpTimer,
    this.minimumWithdrawAmount,
    this.maximumWithdrawAmount,
    this.defaultLocation,
    this.paymentMethodList,
    this.minimumVersion,
    this.maintenanceMode,
    this.languageList,
  });

  ConfigContent.fromJson(Map<String, dynamic> json) {
    businessName = json['business_name'];
    logo = json['logo'];
    logoFullPath = json['logo_full_path'];
    favicon = json['favicon'];
    faviconFullPath = json['favicon_full_path'];
    countryCode = json['country_code'];
    businessAddress = json['business_address'];
    businessPhone = json['business_phone'];
    businessEmail = json['business_email'];
    currencyDecimalPoint = json['currency_decimal_point'];
    currencySymbolPosition = json['currency_symbol_position'];
    currencySymbol = json['currency_symbol'];
    timeFormat = json['time_format'];
    footerText = json['footer_text'];
    appEnvironment = json['app_environment'];
    additionalChargeLabelName = json['additional_charge_label_name'];
    defaultCommission = json['default_commission']?.toString();

    paginationLimit = int.tryParse(json['pagination_limit']?.toString() ?? '');
    providerSelfRegistration = int.tryParse(json['provider_self_registration']?.toString() ?? '');
    biddingStatus = int.tryParse(json['bidding_status']?.toString() ?? '');
    digitalPayment = int.tryParse(json['digital_payment']?.toString() ?? '');
    commissionBasePlan = int.tryParse(json['commission_base_plan']?.toString() ?? '');
    subscriptionBasePlan = int.tryParse(json['subscription_base_plan']?.toString() ?? '');
    subscriptionFreeTrail = int.tryParse(json['subscription_free_trial']?.toString() ?? '');
    subscriptionDeadlineWarning = int.tryParse(json['subscription_deadline_warning']?.toString() ?? '');
    providerCanCancelBooking = int.tryParse(json['provider_can_cancel_booking']?.toString() ?? '');
    providerCanEditBooking = int.tryParse(json['provider_can_edit_booking']?.toString() ?? '');
    providerSlfDelete = int.tryParse(json['provider_self_delete']?.toString() ?? '');
    maxCashInHandLimit = int.tryParse(json['max_cash_in_hand_limit']?.toString() ?? '');
    suspendOnCashInHandLimit = int.tryParse(json['suspend_on_cash_in_hand_limit']?.toString() ?? '');
    bidOfferVisibilityForProvider = int.tryParse(json['bid_offer_visibility_for_provider']?.toString() ?? '');
    showPhoneNumber = int.tryParse(json['show_phone_number']?.toString() ?? '');
    bookingOtpVerification = int.tryParse(json['booking_otp_verification']?.toString() ?? '');
    bookingImageVerification = int.tryParse(json['booking_image_verification']?.toString() ?? '');
    sendOtpTimer = int.tryParse(json['send_otp_timer']?.toString() ?? '') ??
        int.tryParse(json['otp_resend_time']?.toString() ?? '');

    minimumWithdrawAmount = double.tryParse(json['minimum_withdraw_amount']?.toString() ?? '');
    maximumWithdrawAmount = double.tryParse(json['maximum_withdraw_amount']?.toString() ?? '');

    defaultLocation = json['default_location'] != null
        ? ConfigDefaultLocation.fromJson(json['default_location'])
        : null;

    if (json['payment_gateways'] != null) {
      paymentMethodList = <DigitalPaymentMethod>[];
      json['payment_gateways'].forEach((v) {
        paymentMethodList!.add(DigitalPaymentMethod.fromJson(v));
      });
    }

    minimumVersion = json['min_versions'] != null ? MinimumVersion.fromJson(json['min_versions']) : null;
    maintenanceMode = json['maintenance'] != null ? MaintenanceMode.fromJson(json['maintenance']) : null;

    if (json['system_language'] != null) {
      languageList = <Language>[];
      json['system_language'].forEach((v) {
        languageList!.add(Language.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['business_name'] = businessName;
    data['logo'] = logo;
    data['logo_full_path'] = logoFullPath;
    data['favicon'] = favicon;
    data['favicon_full_path'] = faviconFullPath;
    data['country_code'] = countryCode;
    data['business_address'] = businessAddress;
    data['business_phone'] = businessPhone;
    data['business_email'] = businessEmail;
    data['currency_decimal_point'] = currencyDecimalPoint;
    data['currency_symbol_position'] = currencySymbolPosition;
    data['currency_symbol'] = currencySymbol;
    data['time_format'] = timeFormat;
    data['footer_text'] = footerText;
    data['app_environment'] = appEnvironment;
    data['additional_charge_label_name'] = additionalChargeLabelName;
    data['default_commission'] = defaultCommission;
    data['pagination_limit'] = paginationLimit;
    data['provider_self_registration'] = providerSelfRegistration;
    data['bidding_status'] = biddingStatus;
    data['digital_payment'] = digitalPayment;
    data['commission_base_plan'] = commissionBasePlan;
    data['subscription_base_plan'] = subscriptionBasePlan;
    data['subscription_free_trial'] = subscriptionFreeTrail;
    data['subscription_deadline_warning'] = subscriptionDeadlineWarning;
    data['provider_can_cancel_booking'] = providerCanCancelBooking;
    data['provider_can_edit_booking'] = providerCanEditBooking;
    data['provider_self_delete'] = providerSlfDelete;
    data['max_cash_in_hand_limit'] = maxCashInHandLimit;
    data['suspend_on_cash_in_hand_limit'] = suspendOnCashInHandLimit;
    data['bid_offer_visibility_for_provider'] = bidOfferVisibilityForProvider;
    data['show_phone_number'] = showPhoneNumber;
    data['booking_otp_verification'] = bookingOtpVerification;
    data['booking_image_verification'] = bookingImageVerification;
    data['send_otp_timer'] = sendOtpTimer;
    data['minimum_withdraw_amount'] = minimumWithdrawAmount;
    data['maximum_withdraw_amount'] = maximumWithdrawAmount;
    if (defaultLocation != null) {
      data['default_location'] = defaultLocation!.toJson();
    }
    if (paymentMethodList != null) {
      data['payment_gateways'] = paymentMethodList!.map((v) => v.toJson()).toList();
    }
    if (minimumVersion != null) {
      data['min_versions'] = minimumVersion!.toJson();
    }
    if (maintenanceMode != null) {
      data['maintenance'] = maintenanceMode!.toJson();
    }
    if (languageList != null) {
      data['system_language'] = languageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ConfigDefaultLocation {
  ConfigLocationPoint? defaultLocation;

  ConfigDefaultLocation({this.defaultLocation});

  ConfigDefaultLocation.fromJson(Map<String, dynamic> json) {
    defaultLocation = json['default_location'] != null
        ? ConfigLocationPoint.fromJson(json['default_location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (defaultLocation != null) {
      data['default_location'] = defaultLocation!.toJson();
    }
    return data;
  }
}

class ConfigLocationPoint {
  double? lat;
  double? lon;

  ConfigLocationPoint({this.lat, this.lon});

  ConfigLocationPoint.fromJson(Map<String, dynamic> json) {
    lat = double.tryParse(json['lat']?.toString() ?? json['latitude']?.toString() ?? '');
    lon = double.tryParse(json['lon']?.toString() ?? json['longitude']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}
