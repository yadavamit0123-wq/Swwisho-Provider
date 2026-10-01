

import 'package:demandium_provider/utils/core_export.dart';

class AdvertisementDetailsModel {
  String? responseCode;
  String? message;
  AdvertisementData? advertisementData;

  AdvertisementDetailsModel({this.responseCode, this.message, this.advertisementData,});


  AdvertisementDetailsModel.fromJson(Map<String, dynamic> json) {
    responseCode = json['response_code']?.toString();
    message = json['message']?.toString();
    final content = json['content'];
    if (content is Map) {
      try {
        advertisementData = AdvertisementData.fromJson(Map<String, dynamic>.from(content));
      } catch (_) {}
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['response_code'] = responseCode;
    data['message'] = message;
    if (advertisementData != null) {
      data['content'] = advertisementData!.toJson();
    }
    return data;
  }
}