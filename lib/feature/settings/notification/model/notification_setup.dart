class NotificationSetup {
  String? id;
  String? userType;
  String? title;
  String? subTitle;
  String? key;
  Value? value;
  ProviderNotifications? providerNotifications;

  NotificationSetup(
      {this.id,
        this.userType,
        this.title,
        this.subTitle,
        this.key,
        this.value,
        this.providerNotifications,
      });

  NotificationSetup.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    userType = json['user_type']?.toString();
    title = json['title']?.toString();
    subTitle = json['sub_title']?.toString();
    key = json['key']?.toString();
    if (json['value'] is Map) {
      value = Value.fromJson(Map<String, dynamic>.from(json['value']));
    }
    if (json['provider_notifications'] is Map) {
      providerNotifications = ProviderNotifications.fromJson(Map<String, dynamic>.from(json['provider_notifications']));
    } else {
      providerNotifications = ProviderNotifications.fromJson({
        "value" : {
          "notification" : null,
          "sms" : null,
          "email" : null
        }
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_type'] = userType;
    data['title'] = title;
    data['sub_title'] = subTitle;
    data['key'] = key;
    if (value != null) {
      data['value'] = value!.toJson();
    }
    if (providerNotifications != null) {
      data['provider_notifications'] = providerNotifications!.toJson();
    }
    return data;
  }
}

class Value {
  int? email;
  int? notification;
  int? sms;

  Value({this.email, this.notification, this.sms});

  Value.fromJson(Map<String, dynamic> json) {
    email = json['email'] == null ? null : int.tryParse(json['email'].toString()) ?? 0;
    notification = json['notification'] == null ? null : int.tryParse(json['notification'].toString()) ?? 0;
    sms = json['sms'] == null ? null : int.tryParse(json['sms'].toString()) ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['notification'] = notification;
    data['sms'] = sms;
    return data;
  }
}

class ProviderNotifications {
  int? id;
  String? providerId;
  String? notificationSetupId;
  Value? value;

  ProviderNotifications(
      {this.id, this.providerId, this.notificationSetupId, this.value});

  ProviderNotifications.fromJson(Map<String, dynamic> json) {
    id = int.tryParse(json['id']?.toString() ?? '');
    providerId = json['provider_id']?.toString();
    notificationSetupId = json['notification_setup_id']?.toString();
    if (json['value'] is Map) {
      value = Value.fromJson(Map<String, dynamic>.from(json['value']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['provider_id'] = providerId;
    data['notification_setup_id'] = notificationSetupId;
    if (value != null) {
      data['value'] = value!.toJson();
    }
    return data;
  }
}
