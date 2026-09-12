import 'dart:convert';
ServiceCategoryModel serviceCategoryModelFromJson(String str) => ServiceCategoryModel.fromJson(json.decode(str));
String serviceCategoryModelToJson(ServiceCategoryModel data) => json.encode(data.toJson());

class ServiceCategoryModel {
  ServiceCategoryModel({
    this.id,
    this.parentId,
    this.name,
    this.image,
    this.imageFullPath,
    this.position,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });
  String? id;
  String? parentId;
  String? name;
  String? image;
  String? imageFullPath;
  int? position;
  String? description;
  int? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) => ServiceCategoryModel(
    id: json["id"]?.toString(),
    parentId: json["parent_id"]?.toString(),
    name: json["name"]?.toString(),
    image: json["image"]?.toString(),
    imageFullPath : json["image_full_path"]?.toString(),
    position: int.tryParse(json["position"]?.toString() ?? ''),
    description: json["description"]?.toString(),
    isActive: int.tryParse(json["is_active"]?.toString() ?? ''),
    createdAt: DateTime.tryParse(json["created_at"]?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json["updated_at"]?.toString() ?? ''),
  );
  Map<String, dynamic> toJson() => {
    "id": id,
    "parent_id": parentId,
    "name": name,
    "image": image,
    "image_full_path": imageFullPath,
    "position": position,
    "description": description,
    "is_active": isActive,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
