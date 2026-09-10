import 'dart:convert';
import 'package:demandium_provider/api/api_client.dart';
import 'package:demandium_provider/common/model/language_model.dart';
import 'package:demandium_provider/utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:demandium_provider/feature/splash/repository/splash_repo.dart';
import 'package:demandium_provider/feature/auth/repository/auth_repo.dart';
import 'package:demandium_provider/feature/profile/repository/user_repo.dart';
import 'package:demandium_provider/feature/dashboard/repo/dashboard_repo.dart';
import 'package:demandium_provider/feature/booking_details/repo/booking_details_repo.dart';
import 'package:demandium_provider/feature/booking_requests/repo/service_request_repo.dart';
import 'package:demandium_provider/feature/conversation/repo/conversation_repo.dart';
import 'package:demandium_provider/feature/notifications/repository/notification_repo.dart';
import 'package:demandium_provider/feature/transaction/repo/transaction_repo.dart';
import 'package:demandium_provider/feature/subscriptions/repo/subscription_repo.dart';
import 'package:demandium_provider/feature/category/repo/service_repo.dart';
import 'package:demandium_provider/feature/serviceman/repo/serviceman_repo.dart';
import 'package:demandium_provider/feature/advertisement/repository/advertisement_repo.dart';
import 'package:demandium_provider/feature/custom_post/repository/post_repo.dart';
import 'package:demandium_provider/feature/review/repository/review_repo.dart';
import 'package:demandium_provider/feature/reporting/repository/report_repo.dart';
import 'package:demandium_provider/feature/location/repository/location_repo.dart';
import 'package:demandium_provider/feature/html/repository/html_repo.dart';
import 'package:demandium_provider/feature/service_details/repo/service_details_repo.dart';
import 'package:demandium_provider/feature/settings/business/repo/business_settings_repo.dart';
import 'package:demandium_provider/feature/settings/notification/repository/notification_setup_repo.dart';
import 'package:demandium_provider/feature/suggest_service/repository/suggest_service_repo.dart';
import 'package:demandium_provider/feature/profile/view/bank_information/repo/bank_info_repo.dart';

import 'package:demandium_provider/feature/splash/controller/theme_controller.dart';
import 'package:demandium_provider/feature/language/controller/localization_controller.dart';
import 'package:demandium_provider/feature/splash/controller/splash_controller.dart';
import 'package:demandium_provider/feature/auth/controller/auth_controller.dart';
import 'package:demandium_provider/feature/profile/controller/user_controller.dart';
import 'package:demandium_provider/feature/dashboard/controller/dashboard_controller.dart';
import 'package:demandium_provider/feature/booking_details/controller/booking_details_controller.dart';
import 'package:demandium_provider/feature/booking_details/controller/booking_edit_controller.dart';
import 'package:demandium_provider/feature/booking_requests/controller/booking_request_controller.dart';
import 'package:demandium_provider/feature/conversation/controller/conversation_controller.dart';
import 'package:demandium_provider/feature/notifications/controller/notification_controller.dart';
import 'package:demandium_provider/feature/transaction/controller/transaction_controller.dart';
import 'package:demandium_provider/feature/subscriptions/controller/business_subscription_controller.dart';
import 'package:demandium_provider/feature/subscriptions/controller/subcategory_subscription_controller.dart';
import 'package:demandium_provider/feature/category/controller/service_category_controller.dart';
import 'package:demandium_provider/feature/serviceman/controller/serviceman_setup_controller.dart';
import 'package:demandium_provider/feature/serviceman/controller/serviceman_details_controller.dart';
import 'package:demandium_provider/feature/advertisement/controller/advertisement_controller.dart';
import 'package:demandium_provider/feature/custom_post/controller/post_controller.dart';
import 'package:demandium_provider/feature/review/controller/review_controller.dart';
import 'package:demandium_provider/feature/reporting/controller/transaction_report_controller.dart';
import 'package:demandium_provider/feature/reporting/controller/business_report_controller.dart';
import 'package:demandium_provider/feature/reporting/controller/booking_report_controller.dart';
import 'package:demandium_provider/feature/location/controller/location_controller.dart';
import 'package:demandium_provider/feature/html/controller/webview_controller.dart';
import 'package:demandium_provider/feature/service_details/controller/service_details_controller.dart';
import 'package:demandium_provider/feature/settings/business/controller/business_setting_controller.dart';
import 'package:demandium_provider/feature/settings/notification/controller/notification_setup_controller.dart';
import 'package:demandium_provider/feature/suggest_service/controller/suggest_service_controller.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences);

  Get.put(ApiClient(
    appBaseUrl: AppConstants.baseUrl,
    sharedPreferences: sharedPreferences,
  ));

  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => UserRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => DashBoardRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => BookingRequestRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationRepo(sharedPreferences: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => TransactionRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SubscriptionRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ServicemanRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => AdvertisementRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => PostRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ReviewRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ReportRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlRepository(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceDetailsRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => BusinessSettingRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationSetupRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SuggestServiceRepo(apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => BankInfoRepo(apiClient: Get.find()), fenix: true);

  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()), fenix: true);
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()), fenix: true);
  Get.lazyPut(() => SplashController(splashRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AuthController(authRepo: Get.find()), fenix: true);
  Get.lazyPut(() => UserProfileController(userRepo: Get.find()), fenix: true);
  Get.lazyPut(() => DashboardController(dashBoardRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingDetailsController(bookingDetailsRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingEditController(bookingDetailsRepo: Get.find(), serviceRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingRequestController(bookingRequestRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ConversationController(conversationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => TransactionController(transactionRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BusinessSubscriptionController(subscriptionRepo: Get.find()), fenix: true);
  Get.lazyPut(() => SubcategorySubscriptionController(subscriptionRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceCategoryController(serviceRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServicemanSetupController(servicemanRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ServicemanDetailsController(servicemanRepo: Get.find()), fenix: true);
  Get.lazyPut(() => AdvertisementController(advertisementRepo: Get.find()), fenix: true);
  Get.lazyPut(() => PostController(postRepo: Get.find()), fenix: true);
  Get.lazyPut(() => ReviewController(reviewRepo: Get.find()), fenix: true);
  Get.lazyPut(() => TransactionReportController(reportRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BusinessReportController(reportRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BookingReportController(reportRepo: Get.find()), fenix: true);
  Get.lazyPut(() => LocationController(locationRepo: Get.find()), fenix: true);
  Get.lazyPut(() => HtmlViewController(htmlRepository: Get.find()), fenix: true);
  Get.lazyPut(() => ServiceDetailsController(serviceDetailsRepo: Get.find()), fenix: true);
  Get.lazyPut(() => BusinessSettingController(businessSettingRepo: Get.find()), fenix: true);
  Get.lazyPut(() => NotificationSetupController(notificationSetupRepo: Get.find()), fenix: true);
  Get.lazyPut(() => SuggestServiceController(suggestServiceRepo: Get.find()), fenix: true);

  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    Map<String, String> jsonValue = {};
    mappedJson.forEach((key, value) {
      jsonValue[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = jsonValue;
  }

  return languages;
}
