import 'package:flutter_telink_ble/models/trait.dart';

class OnOffTrait extends Trait {
  final bool isOn;

  OnOffTrait({required this.isOn});

  @override
  String getTraitName() => 'OnOff';

  @override
  String toString() => 'OnOffTrait(isOn: $isOn)';
}
