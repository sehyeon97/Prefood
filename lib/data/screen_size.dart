import 'dart:ui';

import 'package:flutter/material.dart';

FlutterView _view = WidgetsBinding.instance.platformDispatcher.views.first;

class Device {
  static Size get screenSize => _view.physicalSize / _view.devicePixelRatio;
}
