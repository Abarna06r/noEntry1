import 'package:flutter/material.dart';

class ThemeProvider {
  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);
}
