class ProviderModel {
  String? responseCode;
  String? message;
  Content? content;


  ProviderModel({this.responseCode, this.message, this.content});

  ProviderModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;

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

class Content {
  ProviderInfo? providerInfo;
  List<BookingOverview>? bookingOverview;
  PromotionalCostPercentage? promotionalCostPercentage;
  SubscriptionInfo ? subscriptionInfo;
  String? providerCharge;


  Content({this.providerInfo, this.bookingOverview,this.promotionalCostPercentage, this.subscriptionInfo});

  Content.fromJson(Map<String, dynamic> json) {
    providerInfo = json['provider_info'] != null
        ? ProviderInfo.fromJson(json['provider_info'])
        : null;
    if (json['booking_overview'] != null) {
      bookingOverview = <BookingOverview>[];
      json['booking_overview'].forEach((v) {
        bookingOverview!.add(BookingOverview.fromJson(v));
      });
    }
    promotionalCostPercentage = json['promotional_cost_percentage'] != null
        ? PromotionalCostPercentage.fromJson(json['promotional_cost_percentage'])
        : null;
    subscriptionInfo  = json['subscription_info'] != null
        ? SubscriptionInfo.fromJson(json['subscription_info'])
        : null;
    providerCharge = json['provider_charge'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (providerInfo != null) {
      data['provider_info'] = providerInfo!.toJson();
    }
    if (bookingOverview != null) {
      data['booking_overview'] =
          bookingOverview!.map((v) => v.toJson()).toList();
    }

    if (promotionalCostPercentage != null) {
      data['promotional_cost_percentage'] = promotionalCostPercentage!.toJson();
    }
    if (subscriptionInfo != null) {
      data['subscription_info'] = subscriptionInfo!.toJson();
    }
    if(providerCharge != null){
      data['provider_charge'] = providerCharge;
    }
    return data;
  }
}

class ProviderInfo {
  String? id;
  String? userId;
  String? companyName;
  String? panNumber;
  String? panImage;
  String? companyPhone;
  String? companyAddress;
  String? companyEmail;
  String? logo;
  String? logoFullPath;
  String? contactPersonName;
  String? contactPersonPhone;
  String? contactPersonEmail;
  String? orderCount;
  int? serviceManCount;
  int? serviceCapacityPerDay;
  int? ratingCount;
  double? avgRating;
  int? commissionStatus;
  int? isOnline;
  String? offlineAt;
  double? commissionPercentage;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? isApproved;
  String? zoneId;
  Owner? owner;
  Coordinates? coordinates;
  int? isSuspend;
  int? serviceAvailability;

  ProviderInfo(
      {this.id,
        this.userId,
        this.companyName,
        this.panNumber,
        this.panImage,
        this.companyPhone,
        this.companyAddress,
        this.companyEmail,
        this.logo,
        this.logoFullPath,
        this.contactPersonName,
        this.contactPersonPhone,
        this.contactPersonEmail,
        this.orderCount,
        this.serviceManCount,
        this.serviceCapacityPerDay,
        this.ratingCount,
        this.avgRating,
        this.commissionStatus,
        this.isOnline,
        this.offlineAt,
        this.commissionPercentage,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.isApproved,
        this.zoneId,
        this.owner,
        this.isSuspend,
        this.serviceAvailability
      });

  ProviderInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    companyName = json['company_name'];
    panNumber = json['pan_number'];
    panImage = json['pan_image'];
    companyPhone = json['company_phone'];
    companyAddress = json['company_address'];
    companyEmail = json['company_email'];
    logo = json['logo'];
    logoFullPath = json['logo_full_path'];
    contactPersonName = json['contact_person_name'];
    contactPersonPhone = json['contact_person_phone'];
    contactPersonEmail = json['contact_person_email'];
    orderCount = json['order_count']?.toString();
    serviceManCount = int.tryParse(json['service_man_count']?.toString() ?? '') ?? 0;
    serviceCapacityPerDay = int.tryParse(json['service_capacity_per_day']?.toString() ?? '') ?? 0;
    ratingCount = int.tryParse(json['rating_count']?.toString() ?? '') ?? 0;
    avgRating = double.tryParse(json['avg_rating']?.toString() ?? '');
    commissionStatus = int.tryParse(json['commission_status']?.toString() ?? '') ?? 0;
    isOnline = int.tryParse(json['is_online']?.toString() ?? '') ?? 0;
    offlineAt = json['offline_at']?.toString();
    commissionPercentage = double.tryParse(json['commission_percentage']?.toString() ?? '') ?? 0;
    isActive = int.tryParse(json['is_active']?.toString() ?? '') ?? 0;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isApproved = int.tryParse(json['is_approved']?.toString() ?? '') ?? 0;
    zoneId = json['zone_id'];
    owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
    coordinates = json['coordinates'] != null ? Coordinates.fromJson(json['coordinates']) : null;
    isSuspend =  int.tryParse(json['is_suspended'].toString());
    serviceAvailability =  int.tryParse(json['service_availability'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['company_name'] = companyName;
    data['pan_number'] = panNumber;
    data['pan_image'] = panImage;
    data['company_phone'] = companyPhone;
    data['company_address'] = companyAddress;
    data['company_email'] = companyEmail;
    data['logo'] = logo;
    data['logo_full_path'] = logoFullPath;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_phone'] = contactPersonPhone;
    data['contact_person_email'] = contactPersonEmail;
    data['order_count'] = orderCount;
    data['service_man_count'] = serviceManCount;
    data['service_capacity_per_day'] = serviceCapacityPerDay;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['commission_status'] = commissionStatus;
    data['is_online'] = isOnline;
    data['offline_at'] = offlineAt;
    data['commission_percentage'] = commissionPercentage;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_approved'] = isApproved;
    data['zone_id'] = zoneId;
    data['is_suspended'] = isSuspend;
    data['service_availability'] = serviceAvailability;
    if (owner != null) {
      data['owner'] = owner!.toJson();
    }

    if (coordinates != null) {
      data['coordinates'] = coordinates!.toJson();
    }
    return data;
  }
}

class Owner {
  String? id;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? identificationNumber;
  String? identificationType;
  List<String>? identificationImage;
  List<String>? identificationImageFullPath;
  String? gender;
  String? profileImage;
  int? isPhoneVerified;
  int? isEmailVerified;
  int? isActive;
  String? userType;
  String? createdAt;
  String? updatedAt;
  Account? account;

  Owner(
      {this.id,
        this.firstName,
        this.lastName,
        this.email,
        this.phone,
        this.identificationNumber,
        this.identificationType,
        this.identificationImage,
        this.identificationImageFullPath,
        this.gender,
        this.profileImage,
        this.isPhoneVerified,
        this.isEmailVerified,
        this.isActive,
        this.userType,
        this.createdAt,
        this.updatedAt,
        this.account});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    phone = json['phone'];
    identificationNumber = json['identification_number'];
    identificationType = json['identification_type'];
    identificationImage =  json['identification_image'] !=null ? json['identification_image'].cast<String>() : [];
    identificationImageFullPath =  json['identification_image_full_path'] !=null ? json['identification_image_full_path'].cast<String>() : [];
    gender = json['gender'];
    profileImage = json['profile_image'];
    isPhoneVerified = json['is_phone_verified'];
    isEmailVerified = json['is_email_verified'];
    isActive = json['is_active'];
    userType = json['user_type'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    account =
    json['account'] != null ? Account.fromJson(json['account']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['email'] = email;
    data['phone'] = phone;
    data['identification_number'] = identificationNumber;
    data['identification_type'] = identificationType;
    data['identification_image'] = identificationImage;
    data['identification_image_full_path'] = identificationImageFullPath;
    data['gender'] = gender;
    data['profile_image'] = profileImage;
    data['is_phone_verified'] = isPhoneVerified;
    data['is_email_verified'] = isEmailVerified;
    data['is_active'] = isActive;
    data['user_type'] = userType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (account != null) {
      data['account'] = account!.toJson();
    }
    return data;
  }
}

class Account {
  String? id;
  String? userId;
  String? balancePending;
  String? receivedBalance;
  String? accountPayable;
  String? accountReceivable;
  String? totalWithdrawn;
  String? newAccountBalance;
  String? cashCollection;
  String? createdAt;
  String? updatedAt;

  Account(
      {this.id,
        this.userId,
        this.balancePending,
        this.receivedBalance,
        this.accountPayable,
        this.accountReceivable,
        this.totalWithdrawn,
        this.newAccountBalance,
        this.cashCollection,
        this.createdAt,
        this.updatedAt});

  Account.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    balancePending = json['balance_pending'].toString();
    receivedBalance = json['received_balance'].toString();
    accountPayable = json['account_payable'].toString();
    accountReceivable = json['account_receivable'].toString();
    totalWithdrawn = json['total_withdrawn'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    newAccountBalance = json['new_account_balance']?.toString() ?? '0';
    cashCollection = json['cash_collection']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['balance_pending'] = balancePending;
    data['received_balance'] = receivedBalance;
    data['account_payable'] = accountPayable;
    data['account_receivable'] = accountReceivable;
    data['total_withdrawn'] = totalWithdrawn;
    data['new_account_balance'] = newAccountBalance;
    data['cash_collection'] = cashCollection;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class BookingOverview {
  String? bookingStatus;
  int? total;

  BookingOverview({this.bookingStatus, this.total});

  BookingOverview.fromJson(Map<String, dynamic> json) {
    bookingStatus = json['booking_status'];
    total = int.tryParse(json['total'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking_status'] = bookingStatus;
    data['total'] = total;
    return data;
  }
}

class PromotionalCostPercentage {
  String? discount;
  String? campaign;
  String? coupon;

  PromotionalCostPercentage({this.discount, this.campaign, this.coupon});

  PromotionalCostPercentage.fromJson(Map<String, dynamic> json) {
    discount = json['discount'].toString();
    campaign = json['campaign'].toString();
    coupon = json['coupon'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount'] = discount;
    data['campaign'] = campaign;
    data['coupon'] = coupon;
    return data;
  }
}

class Coordinates {
  double? latitude;
  double? longitude;

  Coordinates({this.latitude, this.longitude});

  Coordinates.fromJson(Map<String, dynamic> json) {
    latitude = double.tryParse(json['latitude'].toString());
    longitude = double.tryParse(json['longitude'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class SubscriptionInfo {
  int? totalSubscription;
  String? status;
  SubscribedPackageDetails? subscribedPackageDetails;
  RenewalPackageDetails? renewalPackageDetails;
  double? applicableVat;
  SubscriptionInfo({this.totalSubscription, this.status, this.subscribedPackageDetails, this.renewalPackageDetails, this.applicableVat});

  SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    totalSubscription = json['total_subscription'];
    status = json['status'];
    subscribedPackageDetails = json['subscribed_package_details'] !=null ? SubscribedPackageDetails.fromJson(json['subscribed_package_details']) : null;
    renewalPackageDetails = json['renewal_package_details'] !=null ? RenewalPackageDetails.fromJson(json['renewal_package_details']) : null;
    applicableVat = double.tryParse(json['applicable_vat'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_subscription'] = totalSubscription;
    data['status'] = status;
    data['subscribed_package_details'] = subscribedPackageDetails;
    return data;
  }
}

class SubscribedPackageDetails {
  String? id;
  String? providerId;
  String? subscriptionPackageId;
  String? packageSubscriberLogId;
  double? packagePrice;
  String? packageName;
  String? packageStartDate;
  String? packageEndDate;
  double? trialDuration;
  double? vatPercentage;
  double? vatAmount;
  String? paymentMethod;
  String? createdAt;
  String? updatedAt;
  List<String>? featureList;
  String? description;
  int? numberOfUses;
  double? totalAmount;
  int? isCanceled;
  int? isPaid;
  FeatureLimit? featureLimit;
  FeatureLimitLeft? featureLimitLeft;

  SubscribedPackageDetails(
      {this.id,
        this.providerId,
        this.subscriptionPackageId,
        this.packageSubscriberLogId,
        this.packagePrice,
        this.packageName,
        this.packageStartDate,
        this.packageEndDate,
        this.trialDuration,
        this.vatPercentage,
        this.vatAmount,
        this.paymentMethod,
        this.createdAt,
        this.updatedAt,
        this.featureList,
        this.description,
        this.numberOfUses,
        this.totalAmount,
        this.isCanceled,
        this.isPaid,
        this.featureLimit,
        this.featureLimitLeft,
      });

  SubscribedPackageDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    providerId = json['provider_id'];
    subscriptionPackageId = json['subscription_package_id'];
    packageSubscriberLogId = json['package_subscriber_log_id'];
    packagePrice = double.tryParse(json['package_price'].toString());
    packageName = json['package_name'];
    packageStartDate = json['package_start_date'];
    packageEndDate = json['package_end_date'];
    //packageEndDate = "2024-06-05 14:41:48";
    trialDuration = double.tryParse(json['trial_duration'].toString());
    vatPercentage = double.tryParse(json['vat_percentage'].toString());
    vatAmount = double.tryParse(json['vat_amount'].toString());
    paymentMethod = json['payment_method'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    featureList = json['feature_list'] !=null ? json['feature_list'].cast<String>() : [];
    description = json['description'];
    numberOfUses = int.tryParse(json['number_of_uses'].toString());
    isCanceled = int.tryParse(json['is_canceled'].toString());
    isPaid = int.tryParse(json['is_paid'].toString());
    totalAmount = double.tryParse(json['total_amount'].toString());
    featureLimit = json['feature_limit'] !=null ? FeatureLimit.fromJson( json['feature_limit'])  : null;
    featureLimitLeft = json['feature_limit_left'] !=null ? FeatureLimitLeft.fromJson( json['feature_limit_left'])  : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['subscription_package_id'] = subscriptionPackageId;
    data['package_subscriber_log_id'] = packageSubscriberLogId;
    data['package_price'] = packagePrice;
    data['package_name'] = packageName;
    data['package_start_date'] = packageStartDate;
    data['package_end_date'] = packageEndDate;
    data['trial_duration'] = trialDuration;
    data['vat_percentage'] = vatPercentage;
    data['vat_amount'] = vatAmount;
    data['payment_method'] = paymentMethod;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['feature_list'] = featureList;
    data['description'] = description;
    data['number_of_uses'] = numberOfUses;
    data['total_amount'] = totalAmount;
    if (featureLimit != null) {
      data['feature_limit'] = featureLimit!.toJson();
    }
    if (featureLimitLeft != null) {
      data['feature_limit_left'] = featureLimitLeft!.toJson();
    }
    return data;
  }
}

class RenewalPackageDetails {
  String? id;
  String? name;
  double? price;
  int? duration;
  int? isActive;
  String? description;
  String? createdAt;
  String? updatedAt;

  RenewalPackageDetails(
      {this.id,
        this.name,
        this.price,
        this.duration,
        this.isActive,
        this.description,
        this.createdAt,
        this.updatedAt});

  RenewalPackageDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    price = double.tryParse(json['price'].toString());
    duration = int.tryParse(json['duration'].toString());
    isActive = int.tryParse(json['is_active'].toString());
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    data['duration'] = duration;
    data['is_active'] = isActive;
    data['description'] = description;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


class FeatureLimit {
  String? booking;
  String? category;

  FeatureLimit({this.booking, this.category});

  FeatureLimit.fromJson(Map<String, dynamic> json) {
    booking = json['booking'].toString();
    category = json['category'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking'] = booking;
    data['category'] = category;
    return data;
  }
}

class FeatureLimitLeft {
  int? booking;
  int? category;

  FeatureLimitLeft({this.booking, this.category});

  FeatureLimitLeft.fromJson(Map<String, dynamic> json) {
    booking = int.tryParse( json['booking'].toString());
    category = int.tryParse(json['category'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['booking'] = booking;
    data['category'] = category;
    return data;
  }
}

