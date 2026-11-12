import 'chamber_definition.dart';
import 'procedural_chamber_generator.dart';

abstract final class ChamberRegistry {
  static const int totalChambers = 50;
  static const int campaignChambersCount = 50;

  static List<ChamberDefinition> get allChambers =>
      List.generate(totalChambers, (i) => getChamber(i + 1), growable: false);

  static bool isProcedural(int chamberId) => chamberId > totalChambers;

  static ChamberDefinition getChamber(int chamberId) {
    if (chamberId >= 1 && chamberId <= totalChambers) {
      return ProceduralChamberGenerator.generateChamber(chamberId: chamberId);
    }
    if (chamberId > totalChambers) {
      final diff = ((chamberId - totalChambers - 1) ~/ 10) + 5;
      return ProceduralChamberGenerator.generateChamber(
        chamberId: chamberId,
        difficulty: diff,
      );
    }
    return ProceduralChamberGenerator.generateChamber(chamberId: 1);
  }

  static ChamberDefinition getRandomChamber({int? seed, int difficulty = 3}) {
    return ProceduralChamberGenerator.generateRandomChamber(
      seed: seed,
      difficulty: difficulty,
    );
  }

  static ChamberDefinition? getNextChamber(
    int currentChamberId, {
    bool allowEndless = false,
  }) {
    if (currentChamberId == 999) {
      return getRandomChamber();
    }
    final nextId = currentChamberId + 1;
    if (nextId <= totalChambers) {
      return getChamber(nextId);
    }
    if (allowEndless || currentChamberId > totalChambers) {
      return getChamber(nextId);
    }
    return null;
  }
}
