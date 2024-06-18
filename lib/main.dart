import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TimerState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class TimerState extends ChangeNotifier {
  var secondsLeft = 0;
  var startSeconds = 300;
  var isRunning = false;
  var _oneMinuteWarningPending = true;
  final stopwatch = Stopwatch();
  Timer? mainTimer;
  final player = AudioPlayer();

  void toggleRunning() {
    isRunning = !isRunning;
    if (isRunning) {
      stopwatch.start();
    } else {
      stopwatch.stop();
    }
    notifyListeners();
  }

  void setStartSeconds(int seconds) {
    startSeconds = seconds;
    notifyListeners();
  }

  void nextRound() async {
    if (!isRunning) {
      mainTimer?.cancel();
      isRunning = true;
      _oneMinuteWarningPending = true;
      stopwatch.reset();
      stopwatch.start();
      final startSecondsForThisRound = startSeconds;
      secondsLeft = startSecondsForThisRound;
      notifyListeners();
      await player.play(AssetSource('nextround.mp3'));
      mainTimer = Timer.periodic(Duration.zero, (timer) async {
        secondsLeft = startSecondsForThisRound - stopwatch.elapsed.inSeconds;
        // if startSeconds has passed
        if (secondsLeft <= 0) {
          timer.cancel();
          isRunning = false;
          await player.play(AssetSource('timeout.mp3'));
          stopwatch.stop();
        }
        if (_oneMinuteWarningPending && secondsLeft <= 60) {
          _oneMinuteWarningPending = false;
          await player.play(AssetSource('oneminleft.mp3'));
        }
        notifyListeners();
      });
    }
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  String _stringFromSeconds(seconds) {
    return '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timerState = context.watch<TimerState>();
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () {
              PackageInfo.fromPlatform().then((info) {
                showAboutDialog(
                  context: context,
                  applicationName: 'SKAO Timer',
                  applicationVersion: info.version,
                  applicationLegalese: '''MIT License

Copyright © 2024 Boonyakorn Thanpanit

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.''',
                );
              });
            },
            icon: const Icon(Icons.info),
            tooltip: 'About',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _stringFromSeconds(timerState.secondsLeft),
              style: theme.textTheme.headlineLarge,
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(15.0),
            ),
            ElevatedButton(
              onPressed: timerState.nextRound,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              child: const Text('Next Round'),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(8.0),
            ),
            ElevatedButton(
              onPressed: timerState.toggleRunning,
              child: Text(timerState.isRunning ? 'Pause' : 'Resume'),
            ),
            SizedBox.fromSize(
              size: const Size.fromHeight(15.0),
            ),
            TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.secondary),
              onPressed: () {
                showTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 5, minute: 0),
                  initialEntryMode: TimePickerEntryMode.inputOnly,
                  hourLabelText: 'Minutes',
                  minuteLabelText: 'Seconds',
                  helpText: 'Enter new starting time',
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                ).then((newTime) {
                  if (newTime != null) {
                    timerState
                        .setStartSeconds(newTime.hour * 60 + newTime.minute);
                  }
                });
              },
              child: const Text('Change starting time'),
            )
          ],
        ),
      ),
    );
  }
}
