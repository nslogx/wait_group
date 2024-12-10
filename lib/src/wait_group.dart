// The MIT License (MIT)
//
// Copyright (c) 2024 nslogx
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
// OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.

import 'dart:async';

/// A utility class for managing a group of tasks that need to complete before
/// continuing execution. Similar to the concept of WaitGroup in Go.
///
/// It also supports pause and resume functionality.
class WaitGroup {
  int _counter = 0;
  Completer<void> _complete = Completer<void>();
  final StreamController<bool> _pauseController =
      StreamController<bool>.broadcast();

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  /// Adds tasks to the WaitGroup.
  ///
  /// [count]: The number of tasks to add. Defaults to 1.
  /// Throws [ArgumentError] if the count is negative.
  /// Throws [StateError] if tasks are added after all tasks have completed.
  void add([int count = 1]) {
    if (count < 0) throw ArgumentError('The count must be non-negative.');
    if (_complete.isCompleted) {
      throw StateError('Cannot add tasks to a completed WaitGroup.');
    }
    _counter += count;
  }

  /// Marks one task as completed.
  ///
  /// Throws [StateError] if there are no tasks to complete.
  void done() {
    if (_counter <= 0) {
      throw StateError('No tasks to complete.');
    }
    _counter--;
    if (_counter == 0 && !_complete.isCompleted) {
      _complete.complete();
    }
  }

  /// Waits for all tasks to complete.
  ///
  /// If the WaitGroup is paused, this method waits until it is resumed
  /// before waiting for the tasks to complete.
  Future<void> wait() async {
    // Wait until the WaitGroup is resumed if it is paused.
    while (_isPaused) {
      await _pauseController.stream.firstWhere((event) => !event);
    }
    // Wait for all tasks to complete.
    await _complete.future;
  }

  /// Pauses the WaitGroup.
  ///
  /// Tasks will not proceed until [resume] is called.
  void pause() {
    if (!_isPaused) {
      _isPaused = true;
      _pauseController.add(true);
    }
  }

  /// Resumes the WaitGroup.
  ///
  /// Tasks can continue after this method is called.
  void resume() {
    if (_isPaused) {
      _isPaused = false;
      _pauseController.add(false);
    }
  }

  /// Resets the WaitGroup for reuse.
  ///
  /// Throws [StateError] if there are unfinished tasks.
  void reset() {
    if (_counter != 0) {
      throw StateError('Cannot reset while tasks are in progress.');
    }
    if (!_complete.isCompleted) {
      _complete.complete();
    }
    _counter = 0;
    _isPaused = false;
    _complete = Completer<void>();
  }

  /// Releases resources held by the WaitGroup.
  ///
  /// Should be called when the WaitGroup is no longer needed.
  void dispose() {
    if (!_pauseController.isClosed) {
      _pauseController.close();
    }
  }
}
