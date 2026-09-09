enum SendOtpType {forgetPassword, firebase, verification}
enum SignUpPageStep {step1, step2, step3, step4, step5}
enum BusinessPlanType {commissionBase, subscriptionBase}
enum SubscriptionPaymentType {freeTrail, digital}
enum BookingDetailsTabControllerState {bookingDetails,status}
enum ServicemanTabControllerState {generalInfo,accountIno}
enum FileType{png,jpg,jpeg,csv,txt,xlx,xls,pdf}
enum ToasterMessageType {success, error, info}
enum ServiceType { all ,regular, repeat}
enum BookingEditType { regular , repeat, subBooking}
enum ServiceLocationType {customer, provider}
enum AddressLabel {home, office, others }
enum AddressType {service, billing }

enum HtmlType {
  termsAndCondition,
  aboutUs,
  privacyPolicy,
  refundPolicy,
  cancellationPolicy,
  returnPolicy
}

enum NoDataType {
  request,
  notification,
  faq,
  conversation,
  transaction,
  others,
  service,
  customPost,
  myBids,
  subscriptions,
  none,
  advertisement
}

enum TransactionType {none ,payable, withdrawAble, adjust , adjustAndPayable, adjustWithdrawAble}
enum UserAccountStatus {deletable ,haveExistingBooking, needPaymentSettled}