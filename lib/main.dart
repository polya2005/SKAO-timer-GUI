import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

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
