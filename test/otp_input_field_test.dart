import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kr_otp/kr_otp.dart';

Widget _wrap(Widget child, {required double width}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('does not overflow when the available width is too narrow',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        OtpInputField(
          controller: OtpController(),
          onCodeSubmitted: (code) async => true,
        ),
        // 6 boxes need 324px at their natural size, so this is 4px short.
        width: 320,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(OtpInputField)).width, lessThanOrEqualTo(320));
  });

  testWidgets('keeps its natural size when there is room to spare',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        OtpInputField(
          controller: OtpController(),
          onCodeSubmitted: (code) async => true,
        ),
        width: 600,
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(OtpText).first).width, 54);
  });

  testWidgets('works inside an unbounded width parent', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FittedBox(
          fit: BoxFit.scaleDown,
          child: OtpInputField(
            controller: OtpController(),
            onCodeSubmitted: (code) async => true,
          ),
        ),
        width: 320,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
