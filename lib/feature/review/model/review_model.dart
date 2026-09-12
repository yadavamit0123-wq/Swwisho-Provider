import 'package:demandium_provider/feature/booking_details/model/bookings_details_model.dart';

class Review {
  String? id;
  int? readableId;
  String? bookingId;
  String? serviceId;
  String? providerId;
  double? reviewRating;
  String? reviewComment;
  String? bookingDate;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  Customer? customer;
  Booking? booking;
  Provider? provider;
  BookingDetailsService? service;
  ReviewReply? reviewReply;
  Review(
      {this.id,
        this.readableId,
        this.bookingId,
        this.serviceId,
        this.providerId,
        this.reviewRating,
        this.reviewComment,
        this.bookingDate,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.customer,
        this.booking,
        this.provider,
        this.service,
        this.reviewReply
      });

  Review.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    readableId = int.tryParse(json['readable_id']?.toString() ?? '');
    bookingId = json['booking_id']?.toString();
    serviceId = json['service_id']?.toString();
    providerId = json['provider_id']?.toString();
    reviewRating = double.tryParse(json['review_rating']?.toString() ?? '');
    reviewComment = json['review_comment']?.toString();
    bookingDate = json['booking_date']?.toString();
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    try {
      if (json['customer'] is Map) {
        customer = Customer.fromJson(Map<String, dynamic>.from(json['customer']));
      }
    } catch (_) {}
    try {
      if (json['booking'] is Map) {
        booking = Booking.fromJson(Map<String, dynamic>.from(json['booking']));
      }
    } catch (_) {}
    try {
      if (json['provider'] is Map) {
        provider = Provider.fromJson(Map<String, dynamic>.from(json['provider']));
      }
    } catch (_) {}
    try {
      if (json['service'] is Map) {
        service = BookingDetailsService.fromJson(Map<String, dynamic>.from(json['service']));
      }
    } catch (_) {}
    try {
      if (json['review_reply'] is Map) {
        reviewReply = ReviewReply.fromJson(Map<String, dynamic>.from(json['review_reply']));
      }
    } catch (_) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['booking_id'] = bookingId;
    data['service_id'] = serviceId;
    data['provider_id'] = providerId;
    data['review_rating'] = reviewRating;
    data['review_comment'] = reviewComment;
    data['booking_date'] = bookingDate;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (booking != null) {
      data['booking'] = booking!.toJson();
    }
    if (provider != null) {
      data['provider'] = provider!.toJson();
    }
    if (service != null) {
      data['service'] = service!.toJson();
    }
    if (reviewReply != null) {
      data['review_reply'] = reviewReply!.toJson();
    }
    return data;
  }
}

class Rating {
  int? ratingCount;
  int? reviewCount;
  double? averageRating;
  List<RatingGroupCount>? ratingGroupCount;

  Rating({this.ratingCount, this.averageRating, this.ratingGroupCount});

  Rating.fromJson(Map<String, dynamic> json) {
    ratingCount = int.tryParse(json['rating_count'].toString());
    reviewCount = int.tryParse(json['review_count'].toString());
    averageRating = double.tryParse(json['average_rating'].toString());
    if (json['rating_group_count'] is List) {
      ratingGroupCount = <RatingGroupCount>[];
      for (final v in json['rating_group_count']) {
        try {
          if (v is Map) {
            ratingGroupCount!.add(RatingGroupCount.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rating_count'] = ratingCount;
    data['average_rating'] = averageRating;
    if (ratingGroupCount != null) {
      data['rating_group_count'] =
          ratingGroupCount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RatingGroupCount {
  double? reviewRating;
  double? total;

  RatingGroupCount({this.reviewRating, this.total});

  RatingGroupCount.fromJson(Map<String, dynamic> json) {
    reviewRating = double.tryParse(json['review_rating']?.toString() ?? '');
    total = double.tryParse(json['total']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['review_rating'] = reviewRating;
    data['total'] = total;
    return data;
  }
}

class Booking {
  String? id;
  int? readableId;
  String? customerId;
  String? providerId;
  String? zoneId;
  String? bookingStatus;
  int? isPaid;
  String? paymentMethod;
  String? transactionId;
  String? serviceSchedule;
  String? serviceAddressId;
  String? createdAt;
  String? updatedAt;
  String? categoryId;
  String? subCategoryId;
  String? servicemanId;
  int? isChecked;
  List<ServiceDetails>? detail;

  Booking(
      {this.id,
        this.readableId,
        this.customerId,
        this.providerId,
        this.zoneId,
        this.bookingStatus,
        this.isPaid,
        this.paymentMethod,
        this.transactionId,
        this.serviceSchedule,
        this.serviceAddressId,
        this.createdAt,
        this.updatedAt,
        this.categoryId,
        this.subCategoryId,
        this.servicemanId,
        this.isChecked,
        this.detail});

  Booking.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    readableId = int.tryParse(json['readable_id']?.toString() ?? '');
    customerId = json['customer_id']?.toString();
    providerId = json['provider_id']?.toString();
    zoneId = json['zone_id']?.toString();
    bookingStatus = json['booking_status']?.toString();
    isPaid = int.tryParse(json['is_paid']?.toString() ?? '');
    paymentMethod = json['payment_method']?.toString();
    transactionId = json['transaction_id']?.toString();
    serviceSchedule = json['service_schedule']?.toString();
    serviceAddressId = json['service_address_id']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    categoryId = json['category_id']?.toString();
    subCategoryId = json['sub_category_id']?.toString();
    servicemanId = json['serviceman_id']?.toString();
    isChecked = int.tryParse(json['is_checked']?.toString() ?? '');
    if (json['detail'] is List) {
      detail = <ServiceDetails>[];
      for (final v in json['detail']) {
        try {
          if (v is Map) {
            detail!.add(ServiceDetails.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['customer_id'] = customerId;
    data['provider_id'] = providerId;
    data['zone_id'] = zoneId;
    data['booking_status'] = bookingStatus;
    data['is_paid'] = isPaid;
    data['payment_method'] = paymentMethod;
    data['transaction_id'] = transactionId;
    data['service_schedule'] = serviceSchedule;
    data['service_address_id'] = serviceAddressId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['serviceman_id'] = servicemanId;
    data['is_checked'] = isChecked;
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceDetails {
  int? id;
  String? bookingId;
  String? serviceId;
  String? serviceName;
  String? variantKey;
  double? serviceCost;
  int? quantity;
  String? createdAt;
  String? updatedAt;

  ServiceDetails(
      {this.id,
        this.bookingId,
        this.serviceId,
        this.serviceName,
        this.variantKey,
        this.serviceCost,
        this.quantity,
        this.createdAt,
        this.updatedAt,
      });

  ServiceDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    variantKey = json['variant_key'];
    serviceCost = double.tryParse(json['service_cost'].toString());
    quantity = json['quantity'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['variant_key'] = variantKey;
    data['service_cost'] = serviceCost;
    data['quantity'] = quantity;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Provider {
  String? id;
  String? userId;
  String? companyName;
  String? companyPhone;
  String? companyAddress;
  String? companyEmail;
  String? logo;
  String? contactPersonName;
  String? contactPersonPhone;
  String? contactPersonEmail;
  int? orderCount;
  int? serviceManCount;
  int? serviceCapacityPerDay;
  int? ratingCount;
  double? avgRating;
  int? commissionStatus;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? isApproved;
  String? zoneId;

  Provider(
      {this.id,
        this.userId,
        this.companyName,
        this.companyPhone,
        this.companyAddress,
        this.companyEmail,
        this.logo,
        this.contactPersonName,
        this.contactPersonPhone,
        this.contactPersonEmail,
        this.orderCount,
        this.serviceManCount,
        this.serviceCapacityPerDay,
        this.ratingCount,
        this.avgRating,
        this.commissionStatus,
        this.isActive,
        this.createdAt,
        this.updatedAt,
        this.isApproved,
        this.zoneId});

  Provider.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    companyName = json['company_name'];
    companyPhone = json['company_phone'];
    companyAddress = json['company_address'];
    companyEmail = json['company_email'];
    logo = json['logo'];
    contactPersonName = json['contact_person_name'];
    contactPersonPhone = json['contact_person_phone'];
    contactPersonEmail = json['contact_person_email'];
    orderCount = json['order_count'];
    serviceManCount = json['service_man_count'];
    serviceCapacityPerDay = json['service_capacity_per_day'];
    ratingCount = json['rating_count'];
    avgRating = double.tryParse(json['avg_rating'].toString());
    commissionStatus = json['commission_status'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    isApproved = json['is_approved'];
    zoneId = json['zone_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['company_name'] = companyName;
    data['company_phone'] = companyPhone;
    data['company_address'] = companyAddress;
    data['company_email'] = companyEmail;
    data['logo'] = logo;
    data['contact_person_name'] = contactPersonName;
    data['contact_person_phone'] = contactPersonPhone;
    data['contact_person_email'] = contactPersonEmail;
    data['order_count'] = orderCount;
    data['service_man_count'] = serviceManCount;
    data['service_capacity_per_day'] = serviceCapacityPerDay;
    data['rating_count'] = ratingCount;
    data['avg_rating'] = avgRating;
    data['commission_status'] = commissionStatus;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_approved'] = isApproved;
    data['zone_id'] = zoneId;
    return data;
  }
}

class BookingDetails {
  int? id;
  String? bookingId;
  String? serviceId;
  String? serviceName;
  String? variantKey;
  double? serviceCost;
  int? quantity;
  double? discountAmount;
  double? taxAmount;
  double? totalCost;
  String? createdAt;
  String? updatedAt;
  double? campaignDiscountAmount;
  double? overallCouponDiscountAmount;

  BookingDetails(
      {this.id,
        this.bookingId,
        this.serviceId,
        this.serviceName,
        this.variantKey,
        this.serviceCost,
        this.quantity,
        this.discountAmount,
        this.taxAmount,
        this.totalCost,
        this.createdAt,
        this.updatedAt,
        this.campaignDiscountAmount,
        this.overallCouponDiscountAmount});

  BookingDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bookingId = json['booking_id'];
    serviceId = json['service_id'];
    serviceName = json['service_name'];
    variantKey = json['variant_key'];
    serviceCost = double.tryParse(json['service_cost'].toString());
    quantity = json['quantity'];
    discountAmount = double.tryParse(json['discount_amount'].toString());
    taxAmount = double.tryParse(json['tax_amount'].toString());
    totalCost = double.tryParse(json['total_cost'].toString());
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    campaignDiscountAmount = double.tryParse(json['campaign_discount_amount'].toString());
    overallCouponDiscountAmount = double.tryParse(json['overall_coupon_discount_amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['booking_id'] = bookingId;
    data['service_id'] = serviceId;
    data['service_name'] = serviceName;
    data['variant_key'] = variantKey;
    data['service_cost'] = serviceCost;
    data['quantity'] = quantity;
    data['discount_amount'] = discountAmount;
    data['tax_amount'] = taxAmount;
    data['total_cost'] = totalCost;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['campaign_discount_amount'] = campaignDiscountAmount;
    data['overall_coupon_discount_amount'] = overallCouponDiscountAmount;
    return data;
  }
}

class ReviewReply {
  String? id;
  int? readableId;
  String? userId;
  String? reply;
  String? createdAt;
  String? updatedAt;

  ReviewReply(
      {this.id,
        this.readableId,
        this.userId,
        this.reply,
        this.createdAt,
        this.updatedAt});

  ReviewReply.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    readableId = int.tryParse(json['readable_id']?.toString() ?? '');
    userId = json['user_id']?.toString();
    reply = json['reply']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['readable_id'] = readableId;
    data['user_id'] = userId;
    data['reply'] = reply;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}


