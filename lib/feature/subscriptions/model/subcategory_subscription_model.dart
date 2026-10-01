import 'package:demandium_provider/feature/category/model/sub_category_model.dart';

class MySubscriptionModel {
  String? responseCode;
  String? message;
  SubscriptionModelContent? content;

  MySubscriptionModel(
      {this.responseCode, this.message, this.content});

  MySubscriptionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code'];
    message = json['message'];
    content =
    json['content'] != null ? SubscriptionModelContent.fromJson(json['content']) : null;
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

class SubscriptionModelContent {
  int? currentPage;
  List<SubscriptionModelData>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  String? nextPageUrl;
  String? path;
  String? perPage;
  String? prevPageUrl;
  int? to;
  int? total;

  SubscriptionModelContent(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.nextPageUrl,
        this.path,
        this.perPage,
        this.prevPageUrl,
        this.to,
        this.total,
      });

  SubscriptionModelContent.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '');
    if (json['data'] is List) {
      data = <SubscriptionModelData>[];
      for (final v in json['data']) {
        if (v is! Map) continue;
        try {
          data!.add(SubscriptionModelData.fromJson(Map<String, dynamic>.from(v)));
        } catch (_) {}
      }
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = int.tryParse(json['last_page']?.toString() ?? '');
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = int.tryParse(json['total']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class SubscriptionModelData {
  String? id;
  String? providerId;
  String? categoryId;
  String? subCategoryId;
  int? isSubscribed;
  String? createdAt;
  String? updatedAt;
  int? servicesCount;
  int? ongoingBookingCount;
  int? completedBookingCount;
  int? canceledBookingCount;
  ServiceSubCategoryModel ? subCategory;

  SubscriptionModelData(
      {this.id,
        this.providerId,
        this.categoryId,
        this.subCategoryId,
        this.isSubscribed,
        this.createdAt,
        this.updatedAt,
        this.subCategory,
        this.servicesCount,
        this.ongoingBookingCount,
        this.completedBookingCount,
        this.canceledBookingCount,
      });

  SubscriptionModelData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    providerId = json['provider_id']?.toString();
    categoryId = json['category_id']?.toString();
    subCategoryId = json['sub_category_id']?.toString();
    isSubscribed = int.tryParse(json['is_subscribed']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    servicesCount = int.tryParse(json['services_count']?.toString() ?? '');
    ongoingBookingCount = int.tryParse(json['ongoing_booking_count']?.toString() ?? '');
    completedBookingCount = int.tryParse(json['completed_booking_count']?.toString() ?? '');
    canceledBookingCount = int.tryParse(json['canceled_booking_count']?.toString() ?? '');

    final dynamic nestedSubCategory =
        json['sub_category'] ?? json['subcategory'] ?? json['SubCategory'];
    if (nestedSubCategory is Map) {
      try {
        subCategory = ServiceSubCategoryModel.fromJson(
          Map<String, dynamic>.from(nestedSubCategory),
        );
      } catch (_) {}
    }

    subCategory ??= _fallbackSubCategory(json);
    subCategoryId ??= subCategory?.id;
  }

  ServiceSubCategoryModel? _fallbackSubCategory(Map<String, dynamic> json) {
    final id = json['sub_category_id']?.toString() ?? json['id']?.toString();
    if (id == null || id.isEmpty) return null;
    try {
      return ServiceSubCategoryModel.fromJson({
        'id': id,
        'name': json['sub_category_name'] ?? json['name'] ?? '',
        'image_full_path': json['sub_category_image_full_path'] ??
            json['image_full_path'] ??
            json['image'],
        'services_count': json['services_count'],
        'is_subscribed': json['is_subscribed'],
      });
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['category_id'] = categoryId;
    data['sub_category_id'] = subCategoryId;
    data['is_subscribed'] = isSubscribed;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['services_count'] = servicesCount;
    data['ongoing_booking_count'] = ongoingBookingCount;
    data['completed_booking_count'] = completedBookingCount;
    data['canceled_booking_count'] = canceledBookingCount;
    if (subCategory != null) {
      data['sub_category'] = subCategory!.toJson();
    }
    return data;
  }
}