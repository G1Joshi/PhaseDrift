import 'chamber_definition.dart';
import 'chambers/chamber_01.dart';
import 'chambers/chamber_02.dart';
import 'chambers/chamber_03.dart';
import 'chambers/chamber_04.dart';
import 'chambers/chamber_05.dart';
import 'chambers/chamber_06.dart';
import 'chambers/chamber_07.dart';
import 'chambers/chamber_08.dart';

abstract final class ChamberRegistry {
  static final List<ChamberDefinition Function()> _builders = [
    buildChamber01,
    buildChamber02,
    buildChamber03,
    buildChamber04,
    buildChamber05,
    buildChamber06,
    buildChamber07,
    buildChamber08,
  ];

  static int get totalChambers => _builders.length;

  static List<ChamberDefinition> get allChambers =>
      _builders.map((b) => b()).toList(growable: false);

  static ChamberDefinition getChamber(int chamberId) {
    final index = chamberId - 1;
    if (index >= 0 && index < _builders.length) {
      return _builders[index]();
    }
    return buildChamber01();
  }

  static ChamberDefinition? getNextChamber(int currentChamberId) {
    final nextId = currentChamberId + 1;
    if (nextId <= totalChambers) {
      return getChamber(nextId);
    }
    return null;
  }
}
