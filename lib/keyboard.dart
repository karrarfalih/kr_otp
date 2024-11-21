import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kr_otp/controller.dart';
import 'package:vibration/vibration.dart';

class KrOtpKeyboard extends StatefulWidget {
  const KrOtpKeyboard({
    Key? key,
    this.buttonColor,
    this.buttonStyle,
    this.primaryTextStyle,
    this.secondaryTextStyle,
    this.spacing = 6,
    this.runSpacing = 6,
    this.keyboardPadding,
    this.onKeyPressed,
    this.focusNode,
  }) : super(key: key);

  final Color? buttonColor;
  final ButtonStyle? buttonStyle;
  final TextStyle? primaryTextStyle;
  final TextStyle? secondaryTextStyle;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? keyboardPadding;
  final Function(String)? onKeyPressed;
  final FocusNode? focusNode;

  @override
  State<KrOtpKeyboard> createState() => _KrOtpKeyboardState();
}

class _KrOtpKeyboardState extends State<KrOtpKeyboard> {
  OtpController? get controller => OtpController.instance;
  late final focusNode = widget.focusNode ?? FocusNode();

  @override
  void dispose() {
    if (widget.focusNode == null) focusNode.dispose();
    super.dispose();
  }

  static Timer? timer;

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (x) {
        String value = '';
        if (x is KeyDownEvent) {
          switch (x.logicalKey) {
            case LogicalKeyboardKey.backspace:
              value = 'x';
            case LogicalKeyboardKey.digit0:
              value = '0';
            case LogicalKeyboardKey.digit1:
              value = '1';
            case LogicalKeyboardKey.digit2:
              value = '2';
            case LogicalKeyboardKey.digit3:
              value = '3';
            case LogicalKeyboardKey.digit4:
              value = '4';
            case LogicalKeyboardKey.digit5:
              value = '5';
            case LogicalKeyboardKey.digit6:
              value = '6';
            case LogicalKeyboardKey.digit7:
              value = '7';
            case LogicalKeyboardKey.digit8:
              value = '8';
            case LogicalKeyboardKey.digit9:
              value = '9';
            default:
              return;
          }
        }
        if (widget.onKeyPressed != null) {
          widget.onKeyPressed!(value);
        } else {
          controller?.onKeyPadPressed(value);
        }
      },
      child: Container(
        padding: widget.keyboardPadding ??
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
      ),
    );
  }

  Widget _calcButton(String value, String letters) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.spacing / 2, vertical: widget.runSpacing / 2),
        child: TextButton(
          onPressed: () {
            if (widget.onKeyPressed != null) {
              widget.onKeyPressed!(value);
            } else {
              controller?.onKeyPadPressed(value);
            }
            Vibration.hasVibrator().then((canVibrate) {
              if (canVibrate == true)
                Vibration.vibrate(duration: 5, amplitude: 100);
            });
          },
          style: widget.buttonStyle ??
              TextButton.styleFrom(
                backgroundColor: widget.buttonColor ?? Colors.grey.shade200,
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
                style: widget.primaryTextStyle ??
                    TextStyle(color: Colors.black, fontSize: 22),
              ),
              Text(
                letters,
                style: widget.secondaryTextStyle ??
                    TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deleteButton() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: widget.spacing / 2, vertical: widget.runSpacing / 2),
        child: GestureDetector(
          onTap: () {
            if (widget.onKeyPressed != null) {
              widget.onKeyPressed!('x');
            } else {
              controller?.onKeyPadPressed('x');
            }
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
            style: widget.buttonStyle ??
                TextButton.styleFrom(
                  backgroundColor: widget.buttonColor ?? Colors.grey.shade200,
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
                  style: widget.primaryTextStyle ??
                      TextStyle(color: Colors.black, fontSize: 22),
                ),
                Icon(
                  CupertinoIcons.delete_left_fill,
                  color: widget.primaryTextStyle?.color ?? Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
