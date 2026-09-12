class WalletTransactionHistory {
  final String id;
  final String? refTrxId;
  final String? bookingId;
  final String trxType;
  final String debit;
  final String credit;
  final String balance;
  final String fromUserId;
  final String toUserId;
  final String createdAt;
  final String updatedAt;
  final String? fromUserAccount;
  final String? toUserAccount;
  final String? referenceNote;
  final int isGuest;
  final String? bookingRepeatId;
  final Booking? booking;

  WalletTransactionHistory({
    required this.id,
    this.refTrxId,
    this.bookingId,
    required this.trxType,
    required this.debit,
    required this.credit,
    required this.balance,
    required this.fromUserId,
    required this.toUserId,
    required this.createdAt,
    required this.updatedAt,
    this.fromUserAccount,
    this.toUserAccount,
    this.referenceNote,
    required this.isGuest,
    this.bookingRepeatId,
    this.booking,
  });

  factory WalletTransactionHistory.fromJson(Map<String, dynamic> json) {
    Booking? booking;
    try {
      if (json['booking'] is Map) {
        booking = Booking.fromJson(Map<String, dynamic>.from(json['booking']));
      }
    } catch (_) {}
    return WalletTransactionHistory(
      id: json['id']?.toString() ?? '',
      refTrxId: json['ref_trx_id']?.toString(),
      bookingId: json['booking_id']?.toString(),
      trxType: json['trx_type']?.toString() ?? '',
      debit: json['debit']?.toString() ?? '0',
      credit: json['credit']?.toString() ?? '0',
      balance: json['balance']?.toString() ?? '0',
      fromUserId: json['from_user_id']?.toString() ?? '',
      toUserId: json['to_user_id']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      fromUserAccount: json['from_user_account']?.toString(),
      toUserAccount: json['to_user_account']?.toString(),
      referenceNote: json['reference_note']?.toString(),
      isGuest: int.tryParse(json['is_guest']?.toString() ?? '') ?? 0,
      bookingRepeatId: json['booking_repeat_id']?.toString(),
      booking: booking,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ref_trx_id': refTrxId,
      'booking_id': bookingId,
      'trx_type': trxType,
      'debit': debit,
      'credit': credit,
      'balance': balance,
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'from_user_account': fromUserAccount,
      'to_user_account': toUserAccount,
      'reference_note': referenceNote,
      'is_guest': isGuest,
      'booking_repeat_id': bookingRepeatId,
      'booking': booking?.toJson(),
    };
  }
}

class Booking {
  final String id;
  final int readableId;
  final String customerId;
  final String providerId;
  final String zoneId;
  final String bookingStatus;
  final int isPaid;
  final String paymentMethod;
  final String transactionId;
  final double totalBookingAmount;
  final double totalTaxAmount;
  final double totalDiscountAmount;
  final String serviceSchedule;
  final String serviceAddressId;
  final String createdAt;
  final String updatedAt;
  final String categoryId;
  final String subCategoryId;
  final String? servicemanId;
  final double totalCampaignDiscountAmount;
  final double totalCouponDiscountAmount;
  final String? couponCode;
  final int isChecked;
  final double additionalCharge;
  final double additionalTaxAmount;
  final double additionalDiscountAmount;
  final double additionalCampaignDiscountAmount;
  final String removedCouponAmount;
  final List<EvidencePhoto>? evidencePhotos;
  final String bookingOtp;
  final int isGuest;
  final int isVerified;
  final double extraFee;
  final double totalReferralDiscountAmount;
  final int isRepeated;
  final String? assignedBy;
  final String serviceLocation;
  final String serviceAddressLocation;
  final Charge charge;
  final List<String>? evidencePhotosFullPath;

  Booking({
    required this.id,
    required this.readableId,
    required this.customerId,
    required this.providerId,
    required this.zoneId,
    required this.bookingStatus,
    required this.isPaid,
    required this.paymentMethod,
    required this.transactionId,
    required this.totalBookingAmount,
    required this.totalTaxAmount,
    required this.totalDiscountAmount,
    required this.serviceSchedule,
    required this.serviceAddressId,
    required this.createdAt,
    required this.updatedAt,
    required this.categoryId,
    required this.subCategoryId,
    this.servicemanId,
    required this.totalCampaignDiscountAmount,
    required this.totalCouponDiscountAmount,
    this.couponCode,
    required this.isChecked,
    required this.additionalCharge,
    required this.additionalTaxAmount,
    required this.additionalDiscountAmount,
    required this.additionalCampaignDiscountAmount,
    required this.removedCouponAmount,
    required this.evidencePhotos,
    required this.bookingOtp,
    required this.isGuest,
    required this.isVerified,
    required this.extraFee,
    required this.totalReferralDiscountAmount,
    required this.isRepeated,
    this.assignedBy,
    required this.serviceLocation,
    required this.serviceAddressLocation,
    required this.charge,
    this.evidencePhotosFullPath,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      readableId: json['readable_id'],
      customerId: json['customer_id'],
      providerId: json['provider_id'],
      zoneId: json['zone_id'],
      bookingStatus: json['booking_status'],
      isPaid: json['is_paid'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      totalBookingAmount: (json['total_booking_amount'] as num).toDouble(),
      totalTaxAmount: (json['total_tax_amount'] as num).toDouble(),
      totalDiscountAmount: (json['total_discount_amount'] as num).toDouble(),
      serviceSchedule: json['service_schedule'],
      serviceAddressId: json['service_address_id'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      categoryId: json['category_id'],
      subCategoryId: json['sub_category_id'],
      servicemanId: json['serviceman_id'],
      totalCampaignDiscountAmount: (json['total_campaign_discount_amount'] as num).toDouble(),
      totalCouponDiscountAmount: (json['total_coupon_discount_amount'] as num).toDouble(),
      couponCode: json['coupon_code'],
      isChecked: json['is_checked'],
      additionalCharge: (json['additional_charge'] as num).toDouble(),
      additionalTaxAmount: (json['additional_tax_amount'] as num).toDouble(),
      additionalDiscountAmount: (json['additional_discount_amount'] as num).toDouble(),
      additionalCampaignDiscountAmount: (json['additional_campaign_discount_amount'] as num).toDouble(),
      removedCouponAmount: json['removed_coupon_amount'],
      evidencePhotos: json['evidence_photos'] == null ? null :(json['evidence_photos'] as List<dynamic>)
          .map((e) => EvidencePhoto.fromJson(e))
          .toList(),
      bookingOtp: json['booking_otp'],
      isGuest: json['is_guest'],
      isVerified: json['is_verified'],
      extraFee: (json['extra_fee'] as num).toDouble(),
      totalReferralDiscountAmount: (json['total_referral_discount_amount'] as num).toDouble(),
      isRepeated: json['is_repeated'],
      assignedBy: json['assigned_by'],
      serviceLocation: json['service_location'],
      serviceAddressLocation: json['service_address_location'],
      charge: Charge.fromJson(json['charge']),
      evidencePhotosFullPath: json['evidence_photos_full_path'] == null ? null : (json['evidence_photos_full_path'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'readable_id': readableId,
      'customer_id': customerId,
      'provider_id': providerId,
      'zone_id': zoneId,
      'booking_status': bookingStatus,
      'is_paid': isPaid,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'total_booking_amount': totalBookingAmount,
      'total_tax_amount': totalTaxAmount,
      'total_discount_amount': totalDiscountAmount,
      'service_schedule': serviceSchedule,
      'service_address_id': serviceAddressId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'category_id': categoryId,
      'sub_category_id': subCategoryId,
      'serviceman_id': servicemanId,
      'total_campaign_discount_amount': totalCampaignDiscountAmount,
      'total_coupon_discount_amount': totalCouponDiscountAmount,
      'coupon_code': couponCode,
      'is_checked': isChecked,
      'additional_charge': additionalCharge,
      'additional_tax_amount': additionalTaxAmount,
      'additional_discount_amount': additionalDiscountAmount,
      'additional_campaign_discount_amount': additionalCampaignDiscountAmount,
      'removed_coupon_amount': removedCouponAmount,
      'evidence_photos': evidencePhotos?.map((e) => e.toJson()).toList(),
      'booking_otp': bookingOtp,
      'is_guest': isGuest,
      'is_verified': isVerified,
      'extra_fee': extraFee,
      'total_referral_discount_amount': totalReferralDiscountAmount,
      'is_repeated': isRepeated,
      'assigned_by': assignedBy,
      'service_location': serviceLocation,
      'service_address_location': serviceAddressLocation,
      'charge': charge.toJson(),
      'evidence_photos_full_path': evidencePhotosFullPath?.map((e) => e.toString(),).toList(),
    };
  }
}

class EvidencePhoto {
  final String image;
  final String storage;

  EvidencePhoto({required this.image, required this.storage});

  factory EvidencePhoto.fromJson(Map<String, dynamic> json) {
    return EvidencePhoto(
      image: json['image'],
      storage: json['storage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'storage': storage,
    };
  }
}

class Charge {
  final double paymentCharge;
  final double commission;
  final double gst;
  final double tds;
  final double charge;

  Charge({
    required this.paymentCharge,
    required this.commission,
    required this.gst,
    required this.tds,
    required this.charge,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      paymentCharge: (json['payment_charge'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      gst: (json['gst'] as num).toDouble(),
      tds: (json['tds'] as num).toDouble(),
      charge: (json['charge'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_charge': paymentCharge,
      'commission': commission,
      'gst': gst,
      'tds': tds,
      'charge': charge,
    };
  }
}
