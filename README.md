# WaitGroup - A Dart Implementation Inspired by Golang's WaitGroup

---

## 📚 Project Overview

A tiny, lightweight Dart implementation of Golang's [WaitGroup](https://golang.org/pkg/sync/#WaitGroup) for managing asynchronous tasks.

---

## ⚙️ Installation

---

Add this to your package's pubspec.yaml file:

```bash
dependencies:
  wait_group: ^latest
```

---

## 🛠️ Usage Example

---

Below is the full usage example demonstrating how to use `WaitGroup` for task management, pause/resume functionality, and task reset:

```dart
import 'package:wait_group/wait_group.dart';

void main() async {
  final wg = WaitGroup();

  // Add three tasks to the WaitGroup
  wg.add(3);

  // Task 1
  Future(() async {
    print('Task 1 started');
    await Future.delayed(Duration(seconds: 2));
    print('Task 1 completed');
    wg.done();
  });

  // Task 2
  Future(() async {
    print('Task 2 started');
    await Future.delayed(Duration(seconds: 3));
    print('Task 2 completed');
    wg.done();
  });

  // Task 3
  Future(() async {
    print('Task 3 started');
    await Future.delayed(Duration(seconds: 1));
    print('Task 3 completed');
    wg.done();
  });

  // Pause the WaitGroup and resume after 3 seconds
  Future(() async {
    await Future.delayed(Duration(seconds: 1));
    print('Pausing WaitGroup...');
    wg.pause();

    await Future.delayed(Duration(seconds: 3));
    print('Resuming WaitGroup...');
    wg.resume();
  });

  // Wait for all tasks to complete
  print('Waiting for all tasks to complete...');
  await wg.wait();
  print('All tasks completed.');

  // Reset the WaitGroup
  wg.reset();
  print('WaitGroup reset.');
}
```

---

### 🖥️ **Output**

```plaintext
Task 1 started
Task 2 started
Task 3 started
Pausing WaitGroup...
Task 3 completed
Resuming WaitGroup...
Task 1 completed
Task 2 completed
Waiting for all tasks to complete...
All tasks completed.
WaitGroup reset.
```

---

## 🚀 Features Overview

1. **Task Management Mechanism**

   - Register tasks using `add()`.
   - Mark them as completed using `done()`.

2. **Pause/Resume Support**

   - Call `pause()` to temporarily halt task progression.
   - Call `resume()` to continue processing.

3. **Reset Mechanism**

   - `reset()` clears internal counters and allows reuse of the same instance.

4. **Resource Cleanup**
   - Use `dispose()` to close event listeners and free up memory when no longer needed.

---

## 💬 FAQ

### 1. How can I handle interrupted tasks?

If you’re running long tasks and relying on `pause()`, ensure the task periodically checks `_isPaused` state to avoid unexpected behavior.

---

### 2. How can I ensure thread-safe task management?

Only call `done()` once a task has fully finished. Ensure tasks themselves follow safe async coding patterns.

---

## 🎉 Summary

`WaitGroup` provides a simple, efficient, and easy-to-use task manager, making asynchronous task synchronization more intuitive. Inspired by Golang's design philosophy, it gives developers better control over asynchronous operations.

🚀 **Start using WaitGroup now and streamline your asynchronous programming!**
