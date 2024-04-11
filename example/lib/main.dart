import 'package:flutter/material.dart';
import 'package:kr_otp/keyboard.dart';
import 'package:kr_otp/kr_otp.dart';
import 'package:lottie/lottie.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Otp Expample',
      home: OtpScreen(phone: '07714683468'),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countDown,
    presetMillisecond: StopWatchTimer.getMilliSecFromMinute(2),
  );

  @override
  void initState() {
    super.initState();
    _stopWatchTimer.onStartTimer();
  }

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                height: 80,
                child: Lottie.asset(
                  'assets/lottie/otp.json',
                  fit: BoxFit.fitHeight,
                  repeat: false,
                ),
              ),
              const Text(
                'Enter Code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  "we've sent an SMS with an activation code to your phone +964 ${widget.phone}",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    OtpInputField(
                      length: 6,
                      onCodeSubmitted: (code) async {
                        await Future.delayed(const Duration(seconds: 1));
                        if (code != '123456') {
                          return false;
                        }
                        if (!context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                body: Center(
                                  child: Text('Welcome to the app'),
                                ),
                              ),
                            ),
                          );
                        }
                        return true;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: StreamBuilder<int>(
                  stream: _stopWatchTimer.rawTime,
                  initialData: 0,
                  builder: (context, snap) {
                    final value = snap.data;
                    final displayTime = StopWatchTimer.getDisplayTime(
                      value ?? 0,
                      milliSecond: false,
                      hours: false,
                    );
                    if (value == 0) {
                      return TextButton(
                        onPressed: () {},
                        child: const Text('Resend code'),
                      );
                    }
                    return Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'The activation code is expired on ',
                          ),
                          TextSpan(
                            text: displayTime,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
              const Spacer(),
              KrOtpKeyboard(
                buttonColor: Colors.blue,
                buttonStyle: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(20),
                  minimumSize: const Size(60, 60),
                ),
                keyboardPadding: const EdgeInsets.symmetric(horizontal: 20),
                primaryTextStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                secondaryTextStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
