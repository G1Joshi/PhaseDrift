import 'package:flutter_test/flutter_test.dart';
import 'package:phasedrift/game/levels/levels.dart';

void main() {
  group('ProceduralChamberGenerator Logic', () {
    test('all 50 campaign chambers pass structural validation', () {
      final all = ChamberRegistry.allChambers;
      expect(all.length, equals(50));
      for (final chamber in all) {
        expect(
          chamber.isValid,
          isTrue,
          reason:
              'Campaign Chamber ${chamber.chamberId} must pass structural validation',
        );
        expect(chamber.shards.length, equals(3));
        expect(chamber.parTimeMs, greaterThan(10000));
        expect(chamber.width, greaterThanOrEqualTo(480.0));
        expect(chamber.height, greaterThanOrEqualTo(260.0));
      }
    });

    test('generates valid solvable chambers across difficulty tiers', () {
      for (var id = 9; id <= 15; id++) {
        final chamber = ProceduralChamberGenerator.generateChamber(
          chamberId: id,
          difficulty: id - 8,
        );

        expect(
          chamber.isValid,
          isTrue,
          reason: 'Procedural Chamber $id must pass structural validation',
        );
        expect(chamber.chamberId, equals(id));
        expect(chamber.shards.length, equals(3));
        expect(chamber.parTimeMs, greaterThan(14000));
        expect(chamber.width, greaterThanOrEqualTo(480.0));
        expect(chamber.height, greaterThanOrEqualTo(260.0));
      }
    });

    test('generateRandomChamber generates unique dynamic anomalies', () {
      final randomChamber = ProceduralChamberGenerator.generateRandomChamber(
        seed: 42,
        difficulty: 3,
      );

      expect(randomChamber.isValid, isTrue);
      expect(randomChamber.chamberId, equals(999));
      expect(randomChamber.name.startsWith('QUANTUM //'), isTrue);
      expect(randomChamber.shards.length, equals(3));
    });

    test('ChamberRegistry routes beyond campaign into procedural chambers', () {
      expect(ChamberRegistry.isProcedural(50), isFalse);
      expect(ChamberRegistry.isProcedural(51), isTrue);

      final chamber51 = ChamberRegistry.getChamber(51);
      expect(chamber51.isValid, isTrue);
      expect(chamber51.chamberId, equals(51));

      final chamber52 = ChamberRegistry.getNextChamber(51);
      expect(chamber52?.chamberId, equals(52));

      final endlessChamber51 = ChamberRegistry.getNextChamber(
        50,
        allowEndless: true,
      );
      expect(endlessChamber51?.chamberId, equals(51));

      final nextRandomAnomaly = ChamberRegistry.getNextChamber(
        999,
        allowEndless: true,
      );
      expect(nextRandomAnomaly?.chamberId, equals(999));
      expect(nextRandomAnomaly?.isValid, isTrue);
    });
  });
}
