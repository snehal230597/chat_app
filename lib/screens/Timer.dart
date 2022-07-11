import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OtpTimer extends StatefulWidget {
  @override
  _OtpTimerState createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  Timer? countdownTimer;
  Duration myDuration = Duration(days: 1);

  @override
  void initState() {
    super.initState();
  }

  /// Timer related methods ///
  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void resetTimer() {
    setState(() => myDuration = Duration(days: 1));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final seconds = strDigits(myDuration.inSeconds.remainder(60));

    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Resend OTP',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 50),
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                '00 :' + ' $seconds' + ' sec',
                style: TextStyle(color: Colors.black, fontSize: 40),
              ),
              SizedBox(height: 50),
              SizedBox(
                height: 50,
                width: 250,
                child: CupertinoButton(
                  color: Colors.green,
                  onPressed: () {
                    startTimer();
                  },
                  child: Center(
                    child: Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              SizedBox(
                height: 50,
                width: 250,
                child: CupertinoButton(
                  child: Center(
                    child: Text(
                      'Resend OTP',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  color: Colors.red,
                  onPressed: () {
                    resetTimer();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
