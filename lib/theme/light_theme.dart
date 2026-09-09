import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  fontFamily: 'Roboto',
  primaryColor: const Color(0xFF0461A5),
  primaryColorLight: const Color(0xFF0461A5),
  primaryColorDark: const Color(0xFF10324A),
  scaffoldBackgroundColor: const Color(0xFFF7F9FC),
  cardColor: const Color(0xFFFFFFFF),

  shadowColor: const Color(0xFFD1D5DB),
  canvasColor: const Color(0xFFFFFFFF),

  secondaryHeaderColor: const Color(0xFF8797AB),
  disabledColor: const Color(0xFF9E9E9E),
  brightness: Brightness.light,
  hintColor: const Color(0xFF838383),
  focusColor: const Color(0xFFFEFEFE),
  hoverColor: const Color(0xFF033969),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0461A5),
    onPrimary: Color(0xffeef1ef),
    onSecondary: Color(0xff2A45D3),
    secondary: Color(0xff3979E1),
    tertiary: Color(0xffF58F2A),
    onTertiary: Color(0xFFffda6d),
    onSecondaryContainer: Color(0xFF3E9665),
  ).copyWith(
      surface: const Color(0xFFF7F9FC)
  ).copyWith(
      error: const Color(0xFFFF6767)
  ),

  timePickerTheme: const TimePickerThemeData(
      hourMinuteTextColor: Color(0xFF10324a)
  ),
  datePickerTheme: const DatePickerThemeData(
  ),

  dividerTheme: const DividerThemeData(
    thickness: 0.5
  ),


);