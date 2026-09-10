class ServiceFaqModel {
  ServiceFaqContent? content;

  ServiceFaqModel({this.content});

  ServiceFaqModel.fromJson(Map<String, dynamic> json) {
    content = json['content'] != null ? ServiceFaqContent.fromJson(json['content']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class ServiceFaqContent {
  List<ServiceFAQData>? data;

  ServiceFaqContent({this.data});

  ServiceFaqContent.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ServiceFAQData>[];
      json['data'].forEach((v) {
        data!.add(ServiceFAQData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = <String, dynamic>{};
    if (data != null) {
      dataMap['data'] = data!.map((v) => v.toJson()).toList();
    }
    return dataMap;
  }
}

class ServiceFAQData {
  String? id;
  String? serviceId;
  String? question;
  String? answer;
  int? isActive;

  ServiceFAQData({this.id, this.serviceId, this.question, this.answer, this.isActive});

  ServiceFAQData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    question = json['question'];
    answer = json['answer'];
    isActive = int.tryParse(json['is_active'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['service_id'] = serviceId;
    data['question'] = question;
    data['answer'] = answer;
    data['is_active'] = isActive;
    return data;
  }
}
