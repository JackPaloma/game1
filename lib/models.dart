class Item {
  final String id;
  final String name;
  final bool isWeapon;
  final String imagePath; // NUEVO: Ruta de la imagen del objeto

  Item({
    required this.id,
    required this.name,
    this.isWeapon = false,
    required this.imagePath,
  });
}

class Encounter {
  final String id;
  final String characterName;
  final String description;
  final String leftChoiceText;
  final String rightChoiceText;
  final String leftNextEncounterId;
  final String rightNextEncounterId;
  final Item? leftReward;
  final Item? rightReward;
  final Map<String, String>? itemInteractions;

  final String imagePath; // NUEVO: Ruta de la imagen del personaje/evento

  Encounter({
    required this.id,
    required this.characterName,
    required this.description,
    required this.leftChoiceText,
    required this.rightChoiceText,
    required this.leftNextEncounterId,
    required this.rightNextEncounterId,
    this.leftReward,
    this.rightReward,
    this.itemInteractions,
    required this.imagePath,
  });
}