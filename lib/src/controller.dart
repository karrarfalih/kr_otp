import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:kr_otp/src/notifier.dart';
import 'package:motion_toast/motion_toast.dart';

class OtpController {
  static final shakeKey = GlobalKey<ShakeWidgetState>();

  OtpController();

  final focusedIndex = 0.obs;
  late final Rx<List<String>> numbers = <String>[].obs;
  final isSahking = false.obs;
  Future<bool> Function(String code)? onCodeSubmitted;

  setConfig(int length, Future<bool> Function(String code) onCodeSubmitted) {
    numbers.value = List.generate(length, (index) => '');
    this.onCodeSubmitted = onCodeSubmitted;
  }

  onKeyPadPressed(String x) {
    final length = numbers.value.length;
    if (length == 0) return;
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
        onCodeSubmitted?.call(numbers.value.join()).then((isSuccess) async {
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
      animationType: AnimationType.slideInFromTop,
      toastAlignment: Alignment.topCenter,
    ).show(shakeKey.currentContext!);
  }

  dispose() {
    focusedIndex.dispose();
    numbers.dispose();
    isSahking.dispose();
  }
}
