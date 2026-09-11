import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kr_otp/src/controller.dart';
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
    this.textEditingController,
    this.otpController,
    this.onSubmitted,
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
  final TextEditingController? textEditingController;
  final OtpController? otpController;
  final Function()? onSubmitted;

  @override
  State<KrOtpKeyboard> createState() => _KrOtpKeyboardState();
}

class _KrOtpKeyboardState extends State<KrOtpKeyboard> {
  late final focusNode = widget.focusNode ?? FocusNode();

  @override
  void dispose() {
    if (widget.focusNode == null) focusNode.dispose();
    super.dispose();
  }

  static Timer? timer;

  // Resolved once per process: a platform round trip on every keystroke is
  // wasted work on a keypad the user is typing into quickly.
  static Future<bool>? _hasVibrator;

  void _pressKey(String value) {
    _handleKeyEvent(value);
    _hasVibrator ??= Vibration.hasVibrator().then((v) => v == true);
    _hasVibrator!.then((canVibrate) {
      if (canVibrate) Vibration.vibrate(duration: 5, amplitude: 100);
    });
  }

  void _handleKeyEvent(String value) {
    if (widget.onKeyPressed != null) {
      widget.onKeyPressed!(value);
    }
    if (widget.otpController != null) {
      widget.otpController!.onKeyPadPressed(value);
    }
    final controller = widget.textEditingController;
    if (controller != null) {
      final selection = controller.selection;
      final currentText = controller.text;
      final hasValidSelection = selection.isValid;

      if (value == 'x') {
        if (currentText.isEmpty) return;

        if (!hasValidSelection || selection.isCollapsed) {
          final cursor =
              hasValidSelection ? selection.start : currentText.length;
          if (cursor == 0) return;
          final deleteStart = cursor - 1;
          final newText = currentText.replaceRange(deleteStart, cursor, '');
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: deleteStart),
            composing: TextRange.empty,
          );
        } else {
          final newText =
              currentText.replaceRange(selection.start, selection.end, '');
          controller.value = controller.value.copyWith(
            text: newText,
            selection: TextSelection.collapsed(offset: selection.start),
            composing: TextRange.empty,
          );
        }
      } else {
        final insertStart =
            hasValidSelection ? selection.start : currentText.length;
        final insertEnd =
            hasValidSelection ? selection.end : currentText.length;
        final newText = currentText.replaceRange(insertStart, insertEnd, value);
        final newOffset = insertStart + value.length;
        controller.value = controller.value.copyWith(
          text: newText,
          selection: TextSelection.collapsed(offset: newOffset),
          composing: TextRange.empty,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (x) {
        if (x is KeyDownEvent && x.logicalKey == LogicalKeyboardKey.enter) {
          widget.onSubmitted?.call();
          return;
        }
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
          _handleKeyEvent(value);
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
        // A key fires on pointer down rather than on a completed tap: a tap
        // recognizer drops the press when the finger slides past the touch
        // slop, and ignores a second finger landing on a key it is already
        // tracking. Both happen constantly when someone types quickly.
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _pressKey(value),
          child: TextButton(
            onPressed: () {},
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
                // The letters shrink to fit rather than overflow the key
                // when a caller supplies text styles larger than it can hold.
                // Scaling keeps all four letters; ellipsizing would drop two
                // of them to make room for the ellipsis itself.
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      letters,
                      maxLines: 1,
                      softWrap: false,
                      style: widget.secondaryTextStyle ??
                          TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
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
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _pressKey('x'),
          child: GestureDetector(
            onLongPressCancel: () => timer?.cancel(),
            onLongPressStart: (details) {
              timer = Timer.periodic(Duration(milliseconds: 120), (timer) {
                _pressKey('x');
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
      ),
    );
  }
}
