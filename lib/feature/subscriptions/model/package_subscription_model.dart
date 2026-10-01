import 'package:demandium_provider/feature/profile/model/provider_model.dart';

List<String> _packageFeatureList(dynamic value) {
  if (value == null) return [];
  if (value is List) return value.map((e) => e.toString()).toList();
  return [];
}

class PackageSubscriptionModel {
  String? responseCode;
  String? message;
  List<SubscriptionPackage>? subscriptionPackages;

  PackageSubscriptionModel({this.responseCode, this.message, this.subscriptionPackages});

  PackageSubscriptionModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    subscriptionPackages = <SubscriptionPackage>[];
    final content = json['content'];
    dynamic list;
    if (content is List) {
      list = content;
    } else if (content is Map) {
      list = content['data'] ?? content['packages'];
    }
    if (list is List) {
      for (final v in list) {
        if (v is! Map) continue;
        try {
          subscriptionPackages!.add(
            SubscriptionPackage.fromJson(Map<String, dynamic>.from(v)),
          );
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (subscriptionPackages != null) {
      data['content'] = subscriptionPackages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubscriptionPackage {
  String? id;
  String? name;
  double? price;
  int? duration;
  int? isActive;
  String? description;
  String? createdAt;
  String? updatedAt;
  List<String>? featureList;
  FeatureLimit? featureLimit;

  SubscriptionPackage(
      {this.id,
        this.name,
        this.price,
        this.duration,
        this.isActive,
        this.description,
        this.createdAt,
        this.updatedAt,
        this.featureList,
        this.featureLimit
      });

  SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    name = json['name']?.toString();
    price = double.tryParse(json['price']?.toString() ?? '');
    duration = int.tryParse(json['duration']?.toString() ?? '');
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    description = json['description']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    featureList = _packageFeatureList(json['feature_list']);
    if (json['feature_limit'] is Map) {
      try {
        featureLimit = FeatureLimit.fromJson(
          Map<String, dynamic>.from(json['feature_limit'] as Map),
        );
      } catch (_) {}
    }
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
    data['feature_list'] = featureList;
    if (featureLimit != null) {
      data['feature_limit'] = featureLimit!.toJson();
    }
    return data;
  }
}
