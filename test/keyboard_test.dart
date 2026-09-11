import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kr_otp/kr_otp.dart';

void main() {
  late List<String> keys;

  Future<void> pump(WidgetTester tester) async {
    keys = [];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Spacer(),
            KrOtpKeyboard(onKeyPressed: keys.add),
          ],
        ),
      ),
    ));
  }

  testWidgets('a tap reports the key exactly once', (tester) async {
    await pump(tester);
    await tester.tap(find.text('7'));
    await tester.pump();
    expect(keys, ['7']);
  });

  testWidgets('a key still registers when the finger slides off it',
      (tester) async {
    await pump(tester);
    final gesture = await tester.startGesture(tester.getCenter(find.text('7')));
    // kTouchSlop is 18: past this a tap recognizer gives up on the press.
    await gesture.moveBy(const Offset(0, 25));
    await gesture.up();
    await tester.pump();
    expect(keys, ['7']);
  });

  testWidgets('a second finger on the same key is not swallowed',
      (tester) async {
    await pump(tester);
    final position = tester.getCenter(find.text('7'));
    final first = await tester.startGesture(position, pointer: 1);
    final second = await tester.startGesture(position, pointer: 2);
    await first.up();
    await second.up();
    await tester.pump();
    expect(keys, ['7', '7']);
  });

  testWidgets('overlapping fingers on different keys both register',
      (tester) async {
    await pump(tester);
    final first =
        await tester.startGesture(tester.getCenter(find.text('7')), pointer: 1);
    final second =
        await tester.startGesture(tester.getCenter(find.text('8')), pointer: 2);
    await first.up();
    await second.up();
    await tester.pump();
    expect(keys, ['7', '8']);
  });

  testWidgets('backspace reports one delete per tap', (tester) async {
    await pump(tester);
    await tester.tap(find.byIcon(CupertinoIcons.delete_left_fill));
    await tester.pump();
    expect(keys, ['x']);
  });
}
