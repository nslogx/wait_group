import 'package:flutter_test/flutter_test.dart';
import 'package:wait_group/wait_group.dart';

void main() {
  group('WaitGroup Tests', () {
    late WaitGroup wg;

    setUp(() {
      wg = WaitGroup();
    });

    tearDown(() {
      wg.dispose();
    });

    test('Should manage basic add and done logic correctly', () async {
      wg.add(2);

      // Simulate task completion
      Future(() async {
        await Future.delayed(const Duration(milliseconds: 100));
        wg.done();
      });
      Future(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        wg.done();
      });

      // Wait until all tasks complete
      await wg.wait();
      expect(wg, isNotNull);
    });

    test('Pause and Resume logic', () async {
      wg.add(2);

      // Pause the WaitGroup
      wg.pause();

      Future(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        wg.done();
      });
      Future(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        wg.done();
      });

      // Wait while paused, should not finish
      final timeout = DateTime.now().add(const Duration(milliseconds: 300));
      while (DateTime.now().isBefore(timeout)) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Resume and expect tasks to process
      expect(() => wg.resume(), returnsNormally);
      await wg.wait();
    });

    test('Reset the WaitGroup', () async {
      wg.add(2);

      Future(() async {
        await Future.delayed(const Duration(milliseconds: 200));
        wg.done();
      });

      await wg.wait();
      expect(wg, isNotNull);

      // Test reset
      expect(() => wg.reset(), returnsNormally);
      expect(() => wg.add(1), returnsNormally);
    });

    test('Error should throw when calling done() prematurely', () {
      expect(() => wg.done(), throwsA(isA<StateError>()));
    });

    test('Error should throw if reset is called while counter is not 0', () {
      wg.add(2);
      expect(() => wg.reset(), throwsA(isA<StateError>()));
    });

    test('Cannot add tasks after WaitGroup is completed', () async {
      wg.add(1);
      wg.done();
      await wg.wait();

      expect(() => wg.add(1), throwsA(isA<StateError>()));
    });
  });
}
