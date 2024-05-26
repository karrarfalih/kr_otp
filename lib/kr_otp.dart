import 'package:flutter/material.dart';
import 'package:flutter_shakemywidget/flutter_shakemywidget.dart';
import 'package:kr_otp/controller.dart';

import 'src/notifier.dart';

class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.primaryColor,
    this.secondaryColor,
    required this.onCodeSubmitted,
    this.length = 6,
    this.buttonStyle,
    this.textStyle,
  });

  final Future<bool> Function(String code) onCodeSubmitted;
  final int length;
  final Color? primaryColor;
  final Color? secondaryColor;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late OtpController controller = OtpController(
    onCodeSubmitted: widget.onCodeSubmitted,
    length: widget.length,
  );

  didUpdateWidget(OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      controller.dispose();
      controller = OtpController(
        onCodeSubmitted: widget.onCodeSubmitted,
        length: widget.length,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShakeMe(
        key: OtpController.shakeKey,
        shakeCount: 5,
        shakeOffset: 10,
        shakeDuration: Duration(milliseconds: 1000),
        child: MultiValuesListenableBuilder(
            valueListenables: [
              controller.numbers,
              controller.focusedIndex,
              controller.isSahking,
            ],
            builder: (context, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.length,
                  (index) => OtpText(
                    value: controller.numbers.value.elementAt(index).toString(),
                    isFocused: controller.focusedIndex.value == index,
                    isError: controller.isSahking.value,
                    primaryColor: widget.primaryColor,
                    buttonStyle: widget.buttonStyle,
                    textStyle: widget.textStyle,
                    secondaryColor: widget.secondaryColor,
                    onPressed: () {
                      controller.focusedIndex.value = index;
                      setState(() {});
                    },
                  ),
                ),
              );
            }),
      ),
    );
  }
}

class OtpText extends StatelessWidget {
  const OtpText({
    super.key,
    required this.value,
    required this.onPressed,
    required this.isFocused,
    required this.isError,
    this.primaryColor,
    this.secondaryColor,
    this.buttonStyle,
    this.textStyle,
  });

  final String value;
  final bool isFocused;
  final Function() onPressed;
  final bool isError;
  final Color? primaryColor;
  final Color? secondaryColor;
  final ButtonStyle? buttonStyle;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        height: 50,
        child: TextButton(
          onPressed: onPressed,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: Text(
              value,
              key: ValueKey(value),
              style: textStyle ?? TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          style: buttonStyle ??
              TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 10),
                minimumSize: Size(50, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: isError
                        ? Colors.red
                        : isFocused
                            ? primaryColor ?? Theme.of(context).primaryColor
                            : secondaryColor ?? Colors.grey.shade300,
                  ),
                ),
              ),
        ),
      ),
    );
  }
}
