import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:demandium_provider/common/widgets/demo_reset_dialog_widget.dart';
import 'package:demandium_provider/helper/booking_sound_service.dart';
import 'package:demandium_provider/feature/notifications/repository/local_notification_inbox.dart';
import 'package:demandium_provider/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class NotificationHelper {
  /// Fresh sound channel so old silent/broken channels from previous APKs are not reused.
  static const String soundChannelId = 'demandium_sound_v3';
  static const String silentChannelId = 'demandiumWithoutsound';

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    // Not awaited on purpose: FCM listeners below must register even if local
    // notification init fails for any reason on a device.
    try {
      flutterLocalNotificationsPlugin.initialize(initializationsSettings, onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) async {
      try{
        if(notificationResponse!.payload!=null && notificationResponse.payload!=''){
          NotificationBody notificationBody = NotificationBody.fromJson(jsonDecode(notificationResponse.payload!));
          if (kDebugMode) {
            print("Type: ${notificationBody.notificationType}");
          }
          if(notificationBody.notificationType=="chatting"){

            if(Get.currentRoute.contains(RouteHelper.chatScreen)){
              Get.back();
              Get.back();

            } else if(Get.currentRoute.contains(RouteHelper.chatInbox)){
              Get.back();

            }

            Get.toNamed(RouteHelper.getChatScreenRoute(
              notificationBody.channelId??"",
              notificationBody.userType == "supper-admin" ? "admin" : notificationBody.userName??"",
              notificationBody.userProfileImage??"",
              notificationBody.userPhone??"",
              notificationBody.userType??"",
              fromNotification: "fromNotification",
            ));

          }
          else if(notificationBody.notificationType=='bidding'){
            Get.to(()=>const CustomerRequestListScreen());
          }
          else if(notificationBody.notificationType=='booking' && notificationBody.bookingId != null && notificationBody.bookingId != ''){
            BookingSoundService.playBookingAlert(notificationBody.bookingId!);

            if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType == "single"){
              Get.toNamed(RouteHelper.getBookingDetailsRoute( subBookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType != "single"){
              Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else{
              Get.toNamed(RouteHelper.getBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }
          } else if(notificationBody.notificationType=='privacy_policy' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(page: "privacy-policy"));
          }else if(notificationBody.notificationType=='terms_and_conditions' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(page: "terms-and-condition"));
          }else if(notificationBody.notificationType == 'withdraw'){
            Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: "fromNotification"));
          }
          else if(notificationBody.notificationType == 'admin_pay'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'service_request'){
            Get.to(()=> const SuggestedServiceListScreen());
          }
          else if(notificationBody.notificationType == 'maintenance'){
            Get.toNamed(RouteHelper.getSplashRoute());
          }
          else if(notificationBody.notificationType == 'suspend'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'logout'){
            Get.find<AuthController>().clearSharedData();
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }

          else if(notificationBody.notificationType == 'advertisement'){
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: "fromNotification"));
          }
          else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));

          }
        }
      }catch (e) {
        if (kDebugMode) {
          print("");
        }
          }
          return;
        }).catchError((_) => null);
    } catch (_) {}

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      if (kDebugMode) {
        print("onMessage: Notification Type => ${message.data["type"]}/ Title => ${message.data['title']} ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
        print("Notification Body => ${message.data.toString()}");
      }

      final type = message.data['type']?.toString();
      bool pushEnabled = true;
      if (Get.isRegistered<NotificationSetupController>()) {
        pushEnabled = Get.find<NotificationSetupController>().isPushEnabledFor(type);
      }
      try {
        await LocalNotificationInbox.saveFromRemote(message);
      } catch (_) {}


      if(message.data['type']=='bidding'){
        if(message.data['post_id']!="" &&  message.data['post_id']!=null){
          Get.find<SplashController>().updateCustomBookingButtonStatus();
          Get.find<SplashController>().updateCustomBookingRedDotButtonStatus(status: true, shouldUpdate: true);
          Get.find<PostController>().getPostDetailsForNotification(message.data['post_id']);
          Get.find<DashboardController>().getDashboardData(reload: true);
        }else{
          if (pushEnabled) {
            NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
          }
        }
      }

      else if(message.data['type']=='chatting'){

        if((message.data['channel_id']!="" && message.data['channel_id']!=null)){

          if(Get.currentRoute.contains(RouteHelper.chatScreen) && (message.data['channel_id'] == Get.find<ConversationController>().channelId) ){
            Get.find<ConversationController>().getConversation(message.data['channel_id'], 1);
          }else if(Get.currentRoute.contains(RouteHelper.chatInbox)
              || Get.currentRoute.contains(RouteHelper.chatScreen)){

            if (pushEnabled) {
              NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
            }
            if(message.data['user_type'] == 'customer'){
              Get.find<ConversationController>().getChannelList(1);
            }else{
              Get.find<ConversationController>().getChannelList(1, type: "serviceman");
            }
          }else{
            if (pushEnabled) {
              NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
            }
          }

        } else{
          if (pushEnabled) {
            NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
          }
        }
      }
      
      else if(message.data['type']=='general'){
        if (pushEnabled) {
          NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        }
        Get.find<NotificationController>().getNotifications(1, saveNotificationCount: false);
      }
      else if(message.data['type'] == 'logout'){
        NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        Get.find<AuthController>().clearSharedData();
        Get.offAllNamed(RouteHelper.getInitialRoute());
        showCustomSnackBar(message.data['title'], duration: 4);
      }
      else if(message.data['type'] == 'maintenance'){
        Get.find<SplashController>().getConfigData();
      }
      else if(message.data['type'] == 'demo_reset') {
        if(Get.find<SplashController>().configModel.content?.appEnvironment == "demo"){
          Get.dialog(const DemoResetDialogWidget(), barrierDismissible: false);
        }
      }
      else if(BookingSoundService.isBookingNotification(message.data['type']?.toString()) ||
          (BookingSoundService.extractBookingId(message.data) ?? '').isNotEmpty) {
        final bookingId = BookingSoundService.extractBookingId(message.data) ?? '';
        if (pushEnabled) {
          if (bookingId.isNotEmpty) {
            BookingSoundService.playBookingAlert(bookingId);
          } else {
            AudioPlayer().play(AssetSource(AppAudios.requestSound));
          }
          NotificationHelper.showNotification(message, false, flutterLocalNotificationsPlugin, forceSound: true);
        }
        if (Get.isRegistered<BookingRequestController>()) {
          Get.find<BookingRequestController>().getBookingRequestList('pending', 1, reload: true);
        }
      }
      else{
        if (pushEnabled) {
          NotificationHelper.showNotification(message, false,flutterLocalNotificationsPlugin);
        }
      }
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      try{
        if(message!=null && message.data.isNotEmpty) {
          NotificationBody notificationBody = convertNotification(message.data);
          if(notificationBody.notificationType=="chatting"){

            if(Get.currentRoute.contains(RouteHelper.chatScreen)){
              Get.back();
              Get.back();
            } else if(Get.currentRoute.contains(RouteHelper.chatInbox)){
              Get.back();
            }
            Get.toNamed(RouteHelper.getChatScreenRoute(
              notificationBody.channelId??"",
              notificationBody.userType == "supper-admin" ? "admin" : notificationBody.userName??"",
              notificationBody.userProfileImage??"",
              notificationBody.userPhone??"",
              notificationBody.userType??"",
              fromNotification: "fromNotification"
            ));
          }
          else if(notificationBody.notificationType=='bidding' ){
            Get.to(()=>const CustomerRequestListScreen());
          }

          else if(notificationBody.notificationType =='booking' && notificationBody.bookingId!=null && notificationBody.bookingId!=''){
            BookingSoundService.playBookingAlert(notificationBody.bookingId!);

            if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType == "single"){
              Get.toNamed(RouteHelper.getBookingDetailsRoute( subBookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else if(notificationBody.bookingType == "repeat" && notificationBody.repeatBookingType != "single"){
              Get.toNamed(RouteHelper.getRepeatBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }else{
              Get.toNamed(RouteHelper.getBookingDetailsRoute( bookingId : notificationBody.bookingId, fromPage : "fromNotification"));
            }
          }
          else if(notificationBody.notificationType=='privacy_policy' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(page: "privacy-policy"));
          }
          else if(notificationBody.notificationType=='terms_and_conditions' && notificationBody.title!=null && notificationBody.title!=''){
            Get.toNamed(RouteHelper.getHtmlRoute(page: "terms-and-condition"));
          }
          else if(notificationBody.notificationType == 'service_request'){
            Get.to(()=> const SuggestedServiceListScreen());
          }
          else if(notificationBody.notificationType == 'suspend'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'withdraw'){
            Get.toNamed(RouteHelper.getTransactionListRoute(fromPage: "fromNotification"));
          }
          else if(notificationBody.notificationType == 'admin_pay'){
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(notificationBody.notificationType == 'maintenance'){
            Get.toNamed(RouteHelper.getSplashRoute());
          }
          else if(message.data['type'] == 'logout'){
            Get.find<AuthController>().clearSharedData();
            Get.offAllNamed(RouteHelper.getInitialRoute());
          }
          else if(message.data['type'] == 'advertisement'){
            Get.toNamed(RouteHelper.getAdvertisementDetailsScreen(advertisementId: notificationBody.advertisementId, fromNotification: "fromNotification"));
          }
          else{
            Get.toNamed(RouteHelper.getNotificationRoute(fromPage: "notification"));
          }
        }
      }catch (e) {
        if (kDebugMode) {
          print("");
        }
      }
    });

    // Channel + permission setup runs last so a failure here can never block
    // the FCM listeners registered above.
    try {
      await _ensureAndroidChannels(flutterLocalNotificationsPlugin);
    } catch (_) {}
    try {
      await _requestAndroidNotificationPermission(flutterLocalNotificationsPlugin);
    } catch (_) {}
  }

  static Future<void> _ensureAndroidChannels(FlutterLocalNotificationsPlugin fln) async {
    if (!GetPlatform.isAndroid) return;
    final androidPlugin = fln.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        soundChannelId,
        'Swwisho Notifications',
        description: 'Booking and general alerts with sound',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      ),
    );

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        silentChannelId,
        'Swwisho without sound',
        description: 'Notifications without sound',
        importance: Importance.max,
        playSound: false,
      ),
    );
  }

  static Future<void> _requestAndroidNotificationPermission(
    FlutterLocalNotificationsPlugin fln,
  ) async {
    if (!GetPlatform.isAndroid) return;
    try {
      final androidPlugin = fln.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } catch (_) {}
  }

  static bool _isNotificationSoundEnabled() {
    try {
      if (Get.isRegistered<AuthController>()) {
        return Get.find<AuthController>().isNotificationActive();
      }
    } catch (_) {}
    return true;
  }

  static Future<void> showNotification(
    RemoteMessage message,
    bool data,
    FlutterLocalNotificationsPlugin fln, {
    bool forceSound = false,
  }) async {
    try {
      await LocalNotificationInbox.saveFromRemote(message);
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().getNotifications(1, saveNotificationCount: false);
      }
    } catch (_) {}
    if(!GetPlatform.isIOS) {
      String? title;
      String? body;
      String? image;
      String playLoad = jsonEncode(message.data);

      title = message.data['title']?.toString() ?? message.notification?.title;
      body = message.data['body']?.toString() ?? message.notification?.body ?? '';
      image = (message.data['image'] != null && message.data['image'].toString().isNotEmpty)
          ? message.data['image'].toString().startsWith('http') ? message.data['image'].toString()
          : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

      final safeTitle = (title == null || title.isEmpty) ? AppConstants.appName : title;

      if(image != null && image.isNotEmpty) {
        try{
          await showBigPictureNotificationHiddenLargeIcon(safeTitle, body ?? '', playLoad, image, fln, forceSound: forceSound);
        }catch(e) {
          await showBigTextNotification(title :safeTitle, body: body ?? '',payload: playLoad, fln : fln, forceSound: forceSound);
        }
      }else {
        await showBigTextNotification(title :safeTitle, body: body ?? '',payload: playLoad, fln : fln, forceSound: forceSound);
      }
    }
  }

  static Future<void> showBigTextNotification({required String title, required String body, required String payload, required FlutterLocalNotificationsPlugin fln, bool forceSound = false}) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );

    final useSound = forceSound || _isNotificationSoundEnabled();

    if(!useSound){
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        silentChannelId,"${AppConstants.appName} without sound", channelDescription:"description",
        playSound: false,
        importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,

      );
      int randomNumber = Random().nextInt(100000);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(randomNumber, title, body, platformChannelSpecifics, payload: payload);
    }
    else {
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        soundChannelId, 'Swwisho Notifications', channelDescription:"Booking and general alerts with sound",
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        styleInformation: bigTextStyleInformation, priority: Priority.max,
        enableVibration: true,
      );
      int randomNumber = Random().nextInt(100000);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(randomNumber, title, body, platformChannelSpecifics, payload: payload);
    }

  }
  static Future<void> showBigPictureNotificationHiddenLargeIcon(String title, String body, String payload, String image, FlutterLocalNotificationsPlugin fln, {bool forceSound = false}) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );

    final useSound = forceSound || _isNotificationSoundEnabled();

    if(!useSound){
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        silentChannelId,"${AppConstants.appName} without sound", channelDescription:"description",
        playSound: false,
          largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max,
          styleInformation: bigPictureStyleInformation, importance: Importance.max,
      );
      int randomNumber = Random().nextInt(100000);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(randomNumber, title, body, platformChannelSpecifics, payload: payload);

    }else{
      AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        soundChannelId, 'Swwisho Notifications', channelDescription:"Booking and general alerts with sound",
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max,
        styleInformation: bigPictureStyleInformation, importance: Importance.max,
        enableVibration: true,
      );
      int randomNumber = Random().nextInt(100000);
      NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
      await fln.show(randomNumber, title, body, platformChannelSpecifics, payload: payload);
    }
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static NotificationBody convertNotification(Map<String, dynamic> data){
    return NotificationBody.fromJson(data);

  }
}

@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (_) {}

  // Same proven approach as pre-live APK: play alert sound immediately.
  try {
    await AudioPlayer().play(AssetSource(AppAudios.requestSound));
  } catch (_) {}

  // Also show a local tray notification with sound (helps when FCM uses silent channel).
  try {
    final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
    await fln.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    await NotificationHelper._ensureAndroidChannels(fln);

    final title = message.data['title']?.toString()
        ?? message.notification?.title
        ?? AppConstants.appName;
    final body = message.data['body']?.toString()
        ?? message.notification?.body
        ?? '';

    await NotificationHelper.showBigTextNotification(
      title: title,
      body: body,
      payload: jsonEncode(message.data.isNotEmpty ? message.data : {'title': title, 'body': body}),
      fln: fln,
      forceSound: true,
    );

    try {
      await LocalNotificationInbox.saveFromRemote(message);
    } catch (_) {}

    final bookingId = BookingSoundService.extractBookingId(message.data) ?? '';
    if (bookingId.isNotEmpty) {
      await BookingSoundService.playBookingAlert(bookingId);
    }
  } catch (e) {
    if (kDebugMode) {
      print('myBackgroundMessageHandler local notification error: $e');
    }
  }

  if (kDebugMode) {
    print("----------------> onBackground: ${message.notification?.title}/${message.notification?.body}/${message.notification?.titleLocKey}");
  }
}
