import 'package:demandium_provider/feature/splash/controller/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorResources {

  static Color getRightBubbleColor() {
    return  Theme.of(Get.context!).primaryColor;
  }
  static Color getLeftBubbleColor() {
    return Get.isDarkMode ? const Color(0xA2B7B7BB): Theme.of(Get.context!).colorScheme.secondary.withValues(alpha:0.1);
  }
  static const Map<String, Color> buttonBackgroundColorMap ={
    'pending': Color(0x3f85c6f6),
    'accepted': Color(0x5e97c6f6),
    'ongoing': Color(0x629ac5f8),
    'completed': Color(0x4a83b691),
    'settled': Color(0x6e93b347),
    'canceled': Color(0x51F38484),
    'approved': Color(0x47568C67),
    'expired' : Color(0x8C7C3B3B),
    'running' : Color(0x4d7984da),
    'denied':  Color(0x666e3737),
    'paused': Color(0x524caff8),
    'resumed' : Color(0x6f2f5e41),
    'resume' : Color(0x8e387c54),
    'subscription_purchase' : Color(0x3cecc98d),
    'subscription_renew' : Color(0x1d6bf5a2),
    'subscription_shift' : Color(0x452599ee),
    'subscription_refund' : Color(0x1dc97eee),
  };

  static const Map<String, Color> buttonTextColorMap ={
    'pending': Color(0xff0461A5),
    'accepted': Color(0xff2B95FF),
    'ongoing': Color(0xff2B95FF),
    'completed': Color(0xff0ea852),
    'settled': Color(0xf57b9826),
    'canceled': Color(0xffFF3737),
    'approved': Color(0xff16B559),
    'expired' : Color(0xff9ca8af),
    'running' : Color(0xff707ec6),
    'denied':  Color(0xffFF3737),
    'paused': Color(0xff0461A5),
    'resumed' : Color(0xff16B559),
    'resume' : Color(0xff16B559),
    'subscription_purchase' : Color(0xffe7680a),
    'subscription_renew' : Color(0xff16B559),
    'subscription_shift' : Color(0xff0461A5),
    'subscription_refund' : Color(0xffba4af8),
  };
}
List<BoxShadow>? shadow = Get.isDarkMode? null:[
  BoxShadow(
  offset: const Offset(0, 1),
  blurRadius: 2,
  color: Colors.black.withValues(alpha:0.15),
)];

List<BoxShadow>? lightShadow = [
  const BoxShadow(
    offset: Offset(0, 1),
    blurRadius: 3,
    spreadRadius: 1,
    color: Color(0x20D6D8E6),
  )];

List<BoxShadow>? cardShadowOnlyBottom = Get.find<ThemeController>().darkTheme? [const BoxShadow()] : [ BoxShadow(
  color: Colors.black.withValues(alpha:0.05),
  offset: Offset(0, 3), // Subtle offset downward
  blurRadius: 5,       // Lightly soften the shadow
  spreadRadius: 0,
)];

List<BoxShadow>? cardShadow = Get.find<ThemeController>().darkTheme? [const BoxShadow()]:[BoxShadow(
  offset: const Offset(0, 1),
  blurRadius: 6,
  spreadRadius: 1,
  color: Colors.black.withValues(alpha:0.05),
)];
