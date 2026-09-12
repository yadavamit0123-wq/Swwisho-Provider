import 'package:demandium_provider/feature/service_details/model/service_details_model.dart';

class ServiceSubCategoryModel {
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  int? isActive;
  String? createdAt;
  String? updatedAt;
  int? isSubscribed;
  List<ServiceModel>? services;
  int? servicesCount;

  ServiceSubCategoryModel(
      {String? id,
        String? parentId,
        String? name,
        String? image,
        String? imageFullPath,
        int? position,
        String? description,
        int? isActive,
        String? createdAt,
        String? updatedAt,
        int? isSubscribed,
        List<ServiceModel>? services,
        int? servicesCount,
      }) {
    if (id != null) {
      id = id;
    }
    if (parentId != null) {
      parentId = parentId;
    }
    if (name != null) {
      name = name;
    }
    if (image != null) {
      image = image;
    }
    if (imageFullPath != null) {
      imageFullPath = imageFullPath;
    }
    if (position != null) {
      position = position;
    }
    if (description != null) {
      description = description;
    }
    if (isActive != null) {
      isActive = isActive;
    }
    if (createdAt != null) {
      createdAt = createdAt;
    }
    if (updatedAt != null) {
      updatedAt = updatedAt;
    }
    if (isSubscribed != null) {
      isSubscribed = isSubscribed;
    }
    if (services != null) {
      services = services;
    }
    if (servicesCount != null) {
      servicesCount = servicesCount;
    }
  }

  ServiceSubCategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    parentId = json['parent_id']?.toString();
    name = json['name']?.toString();
    image = json['image']?.toString();
    imageFullPath = json['image_full_path']?.toString();
    position = int.tryParse(json['position']?.toString() ?? '');
    description = json['description']?.toString();
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    isSubscribed = int.tryParse(json['is_subscribed']?.toString() ?? '');
    if (json['services'] is List) {
      services = <ServiceModel>[];
      for (final v in json['services']) {
        try {
          if (v is Map) {
            services!.add(ServiceModel.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    servicesCount = int.tryParse(json['services_count']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['image'] = image;
    data['image_full_path'] = imageFullPath;
    data['position'] = position;
    data['description'] = description;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['is_subscribed'] = isSubscribed;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['services_count'] = servicesCount;
    return data;
  }
}
