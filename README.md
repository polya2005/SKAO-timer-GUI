# SKAO Timer

## Description
I was organizing an astronomy examination camp that required the staff, including
myself, to time each round of the exam and notify the participants when the time started,
when there was one minute left, and when the time was up. I initially built a
[simple CLI timer](https://github.com/polya2005/SKAO-timer)
that automates each round's process; hence, the timekeeper only needed to type a command to start
each round. I chose CLI because I needed to complete the program in 1 day.

For next years' editions of the camp, however, I made this nicer GUI version
for easier operation and aesthetic pleasure. This time, I used Flutter because of its
simplicity, cross-platform compatibility, and its beautiful material 3 theme. Note that the
notification sound is in Thai as the examination is for Thai students.

## Installation

|OS|Distribution|Download Link|CPU/Architecture|
|---|---|---|---|
|macOS|`.app`|[Link](https://github.com/polya2005/SKAO-timer-GUI/releases/download/v1.0.0/skao_timer_gui.app.zip)|Apple Silicon & Intel|

## Usage
- The default starting time for each round is 5 minutes. You can change it by clicking on
  "Change starting time" and then enter the desired amount of time.
- Simply click on the "Next round" button to start the next round. You cannot start the next
  round when the timer is running.
- Use the Pause/Resume button to pause and resume the timer.
