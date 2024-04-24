import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:kr_otp/src/notifier.dart';
import 'package:motion_toast/motion_toast.dart';

class OtpController {
  static final shakeKey = GlobalKey<ShakeWidgetState>();

  final Future<bool> Function(String code) onCodeSubmitted;
  final int length;

  static OtpController? instance;

  factory OtpController({
    required Future<bool> Function(String code) onCodeSubmitted,
    required int length,
  }) {
    if (instance == null || instance!._isDisposed) {
      instance = OtpController._(onCodeSubmitted, length);
    }
    return instance!;
  }

  OtpController._(this.onCodeSubmitted, this.length);

  final focusedIndex = 0.obs;
  late final numbers = List.generate(length, (index) => '').obs;
  final isSahking = false.obs;

  bool _isDisposed = false;

  onKeyPadPressed(String x) {
    if (x == 'x') {
      if (numbers.value[focusedIndex.value].isEmpty) {
        numbers.value[max(focusedIndex.value - 1, 0)] = '';
        focusedIndex.value--;
        if (focusedIndex.value < 0) {
          focusedIndex.value = 0;
        }
      } else
        numbers.value[focusedIndex.value] = '';
    } else {
      numbers.value[focusedIndex.value] = x;
      if (focusedIndex.value != (length - 1)) {
        focusedIndex.value++;
      } else {
        numbers.refresh();
      }
      if (numbers.value.every(
        (e) => e.isNotEmpty && focusedIndex.value == (length - 1),
      )) {
        onCodeSubmitted.call(numbers.value.join()).then((isSuccess) async {
          if (!isSuccess) {
            showToast('Invalid activation code');
            await shake();
          }
        });
      }
    }
  }

  shake() async {
    shakeKey.currentState?.shake();
    isSahking.value = true;
    numbers.value = List.generate(6, (index) => '');
    focusedIndex.value = 0;
    await Future.delayed(Duration(seconds: 1));
    isSahking.value = false;
  }

  showToast(String message) {
    if (shakeKey.currentContext == null) return;
    MotionToast.error(
      description: Text(message),
      toastDuration: Duration(seconds: 5),
      constraints: BoxConstraints(maxHeight: 100, minHeight: 50),
      displaySideBar: false,
      animationType: AnimationType.fromTop,
      position: MotionToastPosition.top,
    ).show(shakeKey.currentContext!);
  }

  dispose() {
    focusedIndex.dispose();
    numbers.dispose();
    isSahking.dispose();
    _isDisposed = true;
  }
}
