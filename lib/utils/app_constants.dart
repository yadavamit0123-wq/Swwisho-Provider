import 'package:demandium_provider/common/model/language_model.dart';
import 'package:demandium_provider/utils/images.dart';

class AppConstants {
  static const String appName = 'Swwisho Provider';
  static String appVersion = '1.0.0';
  static const String appUser = 'provider';
  static const String baseUrl = 'https://swwisho.com';
  static const double minimumWalletRecharge = 1500;
  static const String topic = 'provider';
  static const bool avoidMaintenanceMode = false;

  static const String localizationKey = 'X-localization';
  static Map<String, String> configHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer null',
  };

  static const String configUri = '/api/v1/provider/config';
  static const String customerConfigUri = '/api/v1/customer/config';
  static const String registerUri = '/api/v1/provider/auth/registration';
  static const String loginUri = '/api/v1/provider/auth/login';
  static const String providerRemove = '/api/v1/provider/remove-account';
  static const String sendOtpForVerification = '/api/v1/provider/auth/send-otp';
  static const String firebaseOtpVerify = '/api/v1/provider/auth/firebase-auth-verify';
  static const String sendOtpForForgetPassword = '/api/v1/provider/auth/forgot-password/send-otp';
  static const String verifyOtpForVerificationScreen = '/api/v1/provider/auth/otp-verification';
  static const String verifyOtpForForgetPasswordScreen = '/api/v1/provider/auth/forgot-password/otp-verification';
  static const String resetPasswordUri = '/api/v1/provider/auth/reset-password';
  static const String tokenUrl = '/api/v1/provider/update/fcm-token';
  static const String zoneUrl = '/api/v1/provider/config/zone-list';
  static const String changeLanguage = '/api/v1/provider/change-language';
  static const String providerProfileUri = '/api/v1/provider/info';
  static const String providerProfileUpdateUrl = '/api/v1/provider/update/profile';
  static const String statusChange = '/api/v1/provider/update/status';
  static const String bookingListUrl = '/api/v1/provider/booking';
  static const String dashboardUri = '/api/v1/provider/dashboard';
  static const String paymentUri = '/api/v1/provider/config/payment-methods';
  static const String bookingDetailsUrl = '/api/v1/provider/booking/';
  static const String subBookingDetailsUrl = '/api/v1/provider/booking/repeat/sub-booking/';
  static const String acceptBookingRequestUrl = '/api/v1/provider/booking/request/accept';
  static const String ignoreBookingRequestUrl = '/api/v1/provider/booking/request/ignore';
  static const String cancelSubBookingUrl = '/api/v1/provider/booking/repeat/sub-booking/cancel/';
  static const String changeScheduleUrl = '/api/v1/provider/booking/schedule/update';
  static const String changeBookingStatus = '/api/v1/provider/booking/status/update';
  static const String changeSubBookingStatus = '/api/v1/provider/booking/repeat/sub-booking/status/update';
  static const String bookingOTPNotificationUri = '/api/v1/provider/booking/otp/resend';
  static const String getBookingPriceList = '/api/v1/provider/booking/price-list';
  static const String changeServiceLocation = '/api/v1/provider/booking/service-location/update';
  static const String removeCartServiceFromServer = '/api/v1/provider/booking/cart-service/remove';
  static const String updateRegularBooking = '/api/v1/provider/booking/update';
  static const String updateRepeatBooking = '/api/v1/provider/booking/repeat/update';
  static const String serviceCategoryUrl = '/api/v1/provider/category';
  static const String serviceSubcategoryUrl = '/api/v1/provider/category/childes';
  static const String serviceListBasedOnSubCategory = '/api/v1/provider/service/sub-category';
  static const String changeSubscriptionStatusUrl = '/api/v1/provider/sub-category/subscription/update';
  static const String serviceDetailsUrl = '/api/v1/provider/service/detail';
  static const String serviceFaqUrl = '/api/v1/provider/service/faq';
  static const String notificationUrl = '/api/v1/provider/notification';
  static const String withdrawRequestUrl = '/api/v1/provider/withdraw';
  static const String transferToWallet = '/api/v1/provider/withdraw/transfer-to-wallet';
  static const String withdrawMethodRequest = '/api/v1/provider/withdraw/methods';
  static const String adjustTransaction = '/api/v1/provider/transaction/adjust';
  static const String walletHisTransaction = '/api/v1/provider/transaction/wallet';
  static const String bankDetailsUrl = '/api/v1/provider/bank/details';
  static const String updateBankDetailsUrl = '/api/v1/provider/bank/update';
  static const String subscriptionListUrl = '/api/v1/provider/subscription/sub-category/list';
  static const String packageSubscriptionUri = '/api/v1/provider/subscription/package/list';
  static const String subscriptionDetailsUri = '/api/v1/provider/subscription/details';
  static const String changeSubscriptionStatus = '/api/v1/provider/subscription/package/';
  static const String subscriptionTransactionListUri = '/api/v1/provider/subscription/transaction/list';
  static const String subscriptionTransactionInvoice = '/booking/invoice/subscription/';
  static const String createChannel = '/api/v1/provider/chat/create-channel';
  static const String getChannelListUrl = '/api/v1/provider/chat/channel-list';
  static const String searchChannelListUrl = '/api/v1/provider/chat/search-channel-list';
  static const String getConversationUrl = '/api/v1/provider/chat/conversation';
  static const String sendMessageUrl = '/api/v1/provider/chat/send-message';
  static const String getCustomerPostList = '/api/v1/provider/custom-post/list';
  static const String bidCustomerPost = '/api/v1/provider/custom-post/bid';
  static const String declineCustomerPost = '/api/v1/provider/custom-post/decline';
  static const String withdrawBidRequest = '/api/v1/provider/custom-post/bid/withdraw';
  static const String getProviderOfferList = '/api/v1/provider/custom-post/bid/list';
  static const String getPostDetails = '/api/v1/provider/custom-post/details';
  static const String getSuggestedServiceList = '/api/v1/provider/service/suggestion/list';
  static const String submitNewServiceRequest = '/api/v1/provider/service/suggestion/submit';
  static const String getProviderReviewList = '/api/v1/provider/review/provider';
  static const String getServiceReviewList = '/api/v1/provider/review/service';
  static const String reviewReply = '/api/v1/provider/review/reply';
  static const String getBookingReportList = '/api/v1/provider/report/booking';
  static const String getBusinessOverviewList = '/api/v1/provider/report/business/overview';
  static const String getBusinessEarningList = '/api/v1/provider/report/business/earning';
  static const String getBusinessExpenseList = '/api/v1/provider/report/business/expense';
  static const String getTransactionReportList = '/api/v1/provider/report/transaction';
  static const String getBusinessBookingSettings = '/api/v1/provider/business-settings/booking';
  static const String updateBusinessBookingSettings = '/api/v1/provider/business-settings/booking/update';
  static const String getServiceAvailabilitySettings = '/api/v1/provider/business-settings/availability';
  static const String updateServiceAvailabilitySettings = '/api/v1/provider/business-settings/availability/update';
  static const String addNewServicemanUri = '/api/v1/provider/serviceman';
  static const String servicemanListUri = '/api/v1/provider/serviceman';
  static const String servicemanDetailsUri = '/api/v1/provider/serviceman/details';
  static const String servicemanAssignUri = '/api/v1/provider/serviceman/assign';
  static const String servicemanUpdateStatus = '/api/v1/provider/serviceman/status/update';
  static const String servicemanDeleteUri = '/api/v1/provider/serviceman/delete';
  static const String submitNewAdvertisement = '/api/v1/provider/advertisement/store';
  static const String editAdvertisement = '/api/v1/provider/advertisement/update';
  static const String getAdvertisementList = '/api/v1/provider/advertisement/list';
  static const String getAdvertisementDetails = '/api/v1/provider/advertisement/details';
  static const String deleteAdvertisement = '/api/v1/provider/advertisement/delete';
  static const String changeAdvertisementStatus = '/api/v1/provider/advertisement/status';
  static const String reSubmitAdvertisement = '/api/v1/provider/advertisement/resubmit';
  static const String geocodeUri = '/api/v1/provider/config/geocode-api';
  static const String searchLocationUri = '/api/v1/provider/config/place-api-autocomplete';
  static const String placeDetailsUri = '/api/v1/provider/config/place-api-details';
  static const String pages = '/api/v1/provider/config/pages';
  static const String regularBookingInvoiceUrl = '/booking/invoice/regular/';
  static const String fullRepeatBookingInvoiceUrl = '/booking/invoice/repeat/';
  static const String singleRepeatBookingInvoiceUrl = '/booking/invoice/repeat/single/';

  static const String theme = 'provider_theme';
  static const String token = 'provider_token';
  static const String countryCode = 'provider_country_code';
  static const String languageCode = 'provider_language_code';
  static const String userPassword = 'provider_user_password';
  static const String userAddress = 'provider_user_address';
  static const String userNumber = 'provider_user_number';
  static const String notification = 'provider_notification';
  static const String notificationCount = 'provider_notification_count';
  static const String initialLanguage = 'provider_initial_language';
  static const String isRememberActive = 'provider_is_remember_active';

  static const double limitOfPickedImageSizeInMB = 2;
  static const double limitOfPickedVideoSizeInMB = 50;
  static const double maxSizeOfASingleFile = 2;
  static const double maxLimitOfFileSentINConversation = 10;
  static const double maxLimitOfTotalFileSent = 5;
  static const int limitOfPickedIdentityImageNumber = 2;

  static const List<String> identityTypeList = ['passport', 'driving_license', 'nid'];
  static const List<String> categoryTypeList = ['main', 'sub'];

  static List<LanguageModel> languages = [
    LanguageModel(imageUrl: Images.us, languageName: 'English', countryCode: 'US', languageCode: 'en'),
    LanguageModel(imageUrl: Images.india, languageName: 'Hindi', countryCode: 'IN', languageCode: 'hi'),
    LanguageModel(imageUrl: Images.bn, languageName: 'Bangla', countryCode: 'BD', languageCode: 'bn'),
    LanguageModel(imageUrl: Images.ar, languageName: 'Arabic', countryCode: 'SA', languageCode: 'ar'),
  ];
}
