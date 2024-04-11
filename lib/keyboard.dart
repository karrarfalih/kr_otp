import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kr_otp/src/controller.dart';
import 'package:vibration/vibration.dart';

class KrOtpKeyboard extends StatelessWidget {
  const KrOtpKeyboard({
    Key? key,
    this.buttonColor,
    this.buttonStyle,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.spacing = 6,
    this.runSpacing = 6,
    this.keyboardPadding,
  }) : super(key: key);

  final Color? buttonColor;
  final ButtonStyle? buttonStyle;
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? keyboardPadding;

  OtpController? get controller => OtpController.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: keyboardPadding ??
          const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 20,
          ),
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              _calcButton('1', ''),
              _calcButton('2', 'ABC'),
              _calcButton('3', 'DEF'),
            ],
          ),
          Row(
            children: <Widget>[
              _calcButton('4', 'GHI'),
              _calcButton('5', 'JKL'),
              _calcButton('6', 'MNO'),
            ],
          ),
          Row(
            children: <Widget>[
              _calcButton('7', 'PQRS'),
              _calcButton('8', 'TUV'),
              _calcButton('9', 'WXYZ'),
            ],
          ),
          Row(
            children: <Widget>[
              Spacer(),
              _calcButton('0', '+'),
              _deleteButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calcButton(String value, String letters) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: spacing / 2, vertical: runSpacing / 2),
        child: TextButton(
          onPressed: () {
            controller?.onKeyPadPressed(value);
            Vibration.hasVibrator().then((canVibrate) {
              if (canVibrate == true)
                Vibration.vibrate(duration: 5, amplitude: 100);
            });
          },
          style: buttonStyle ??
              TextButton.styleFrom(
                backgroundColor: buttonColor ?? Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                minimumSize: Size(0, 55),
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: primaryTextStyle ??
                    TextStyle(color: Colors.black, fontSize: 22),
              ),
              Text(
                letters,
                style: secondaryTextStyle ??
                    TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Timer? timer;

  Widget _deleteButton() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: spacing / 2, vertical: runSpacing / 2),
        child: GestureDetector(
          onTap: () {
            controller?.onKeyPadPressed('x');
            Vibration.hasVibrator().then((canVibrate) {
              if (canVibrate == true)
                Vibration.vibrate(duration: 5, amplitude: 100);
            });
          },
          onLongPressCancel: () => timer?.cancel(),
          onLongPressStart: (details) {
            timer = Timer.periodic(Duration(milliseconds: 120), (timer) {
              controller?.onKeyPadPressed('x');
              Vibration.hasVibrator().then((canVibrate) {
                if (canVibrate == true)
                  Vibration.vibrate(duration: 5, amplitude: 100);
              });
            });
          },
          onLongPressEnd: (_) => timer?.cancel(),
          onLongPressUp: () => timer?.cancel(),
          child: TextButton(
            onPressed: null,
            style: buttonStyle ??
                TextButton.styleFrom(
                  backgroundColor: buttonColor ?? Colors.grey.shade200,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  minimumSize: Size(0, 55),
                ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '',
                  style: primaryTextStyle ??
                      TextStyle(color: Colors.black, fontSize: 22),
                ),
                Icon(
                  CupertinoIcons.delete_left_fill,
                  color: primaryTextStyle?.color ?? Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
