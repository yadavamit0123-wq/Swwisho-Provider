class NotificationModel {
  String? responseCode;
  String? message;
  Content? content;


  NotificationModel({this.responseCode, this.message, this.content});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    if (json['content'] is Map) {
      content = Content.fromJson(Map<String, dynamic>.from(json['content']));
    }
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
  int? currentPage;
  List<Data>? data;
  String? firstPageUrl;
  int? from;
  int? lastPage;
  String? lastPageUrl;
  List<Links>? links;
  String? nextPageUrl;
  String? path;

  String? prevPageUrl;
  int? to;
  int? total;

  Content(
      {this.currentPage,
        this.data,
        this.firstPageUrl,
        this.from,
        this.lastPage,
        this.lastPageUrl,
        this.links,
        this.nextPageUrl,
        this.path,
        this.prevPageUrl,
        this.to,
        this.total});

  Content.fromJson(Map<String, dynamic> json) {
    currentPage = int.tryParse(json['current_page']?.toString() ?? '');
    if (json['data'] is List) {
      data = <Data>[];
      for (final v in json['data']) {
        try {
          if (v is Map) {
            data!.add(Data.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    firstPageUrl = json['first_page_url']?.toString();
    from = int.tryParse(json['from']?.toString() ?? '');
    lastPage = int.tryParse(json['last_page']?.toString() ?? '');
    lastPageUrl = json['last_page_url']?.toString();
    if (json['links'] is List) {
      links = <Links>[];
      for (final v in json['links']) {
        try {
          if (v is Map) {
            links!.add(Links.fromJson(Map<String, dynamic>.from(v)));
          }
        } catch (_) {}
      }
    }
    nextPageUrl = json['next_page_url']?.toString();
    path = json['path']?.toString();
    prevPageUrl = json['prev_page_url']?.toString();
    to = int.tryParse(json['to']?.toString() ?? '');
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
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['next_page_url'] = nextPageUrl;
    data['path'] = path;
    data['prev_page_url'] = prevPageUrl;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class Links {
  String? url;
  String? label;
  bool? active;

  Links({this.url, this.label, this.active});

  Links.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label'];
    active = json['active'];
  }

  Map<String, dynamic> toJson(){
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

class Errors {
  String? errorCode;
  String? message;

  Errors({this.errorCode, this.message});

  Errors.fromJson(Map<String, dynamic> json) {
    errorCode = json['error_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error_code'] = errorCode;
    data['message'] = message;
    return data;
  }
}

class Data{
  String? id;
  String? title;
  String? description;
  String? coverImage;
  String? coverImageFullPath;
  String? zoneIds;
  List<String>? toUsers;
  int? isActive;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.id,
        this.title,
        this.description,
        this.coverImage,
        this.coverImageFullPath,
        this.zoneIds,
        this.toUsers,
        this.isActive,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    title = json['title']?.toString();
    description = json['description']?.toString();
    coverImage = json['cover_image']?.toString();
    coverImageFullPath = json['cover_image_full_path']?.toString();
    if (json['to_users'] is List) {
      toUsers = json['to_users'].map<String>((e) => e.toString()).toList();
    }
    isActive = int.tryParse(json['is_active']?.toString() ?? '');
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['cover_image'] = coverImage;
    data['cover_image_full_path'] = coverImageFullPath;
    data['zone_ids'] = zoneIds;
    data['to_users'] = toUsers;
    data['is_active'] = isActive;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}