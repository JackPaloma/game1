import 'package:flutter/material.dart';
import 'theme.dart';
import 'models.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Map<String, Encounter> storyTree;
  String currentEncounterId = "inicio_01";
  List<Item> backpack = [];

  @override
  void initState() {
    super.initState();
    _loadStory();
    // Item inicial con ruta de imagen ficticia
    backpack.add(Item(id: "daga_01", name: "Daga", isWeapon: true, imagePath: "assets/daga.png"));
  }

  void _loadStory() {
    storyTree = {
      "inicio_01": Encounter(
          id: "inicio_01",
          characterName: "Vieja Bruja",
          description: "Una bruja te corta el paso. 'Dame algo brillante o te maldeciré'.",
          imagePath: "assets/bruja.png", // Imagen del personaje
          leftChoiceText: "Huir", leftNextEncounterId: "bosque_oscuro",
          rightChoiceText: "Pelear", rightNextEncounterId: "muerte_bruja",
          itemInteractions: { "moneda_oro": "bruja_feliz" }
      ),
      "bosque_oscuro": Encounter(
        id: "bosque_oscuro",
        characterName: "Mercader",
        description: "Un mercader te ofrece una poción en la oscuridad.",
        imagePath: "assets/mercader.png",
        leftChoiceText: "Ignorar", leftNextEncounterId: "inicio_01",
        rightChoiceText: "Robar", rightNextEncounterId: "guardias",
        rightReward: Item(id: "moneda_oro", name: "Oro", imagePath: "assets/oro.png"),
      ),
      "consecuencia_asesinato": Encounter(
        id: "consecuencia_asesinato",
        characterName: "Pueblo en Llamas",
        description: "Has atacado a sangre fría. Los aldeanos te persiguen.",
        imagePath: "assets/aldeanos.png",
        leftChoiceText: "Correr", leftNextEncounterId: "bosque_oscuro",
        rightChoiceText: "Pelear", rightNextEncounterId: "muerte_aldeanos",
      )
    };
  }

  void _goToNode(String nextId, {Item? reward}) {
    if (!storyTree.containsKey(nextId)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("FIN DE LA DEMO")));
      return;
    }
    setState(() {
      currentEncounterId = nextId;
      if (reward != null) backpack.add(reward);
    });
  }

  void _handleItemDroppedOnCard(Item droppedItem) {
    final encounter = storyTree[currentEncounterId]!;

    if (encounter.itemInteractions != null && encounter.itemInteractions!.containsKey(droppedItem.id)) {
      String nextId = encounter.itemInteractions![droppedItem.id]!;
      backpack.remove(droppedItem);
      _goToNode(nextId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Entregaste: ${droppedItem.name}")));
      return;
    }

    if (droppedItem.isWeapon) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: MedievalTheme.bloodRed, content: Text("¡Has atacado a ${encounter.characterName}!"))
      );
      _goToNode("consecuencia_asesinato");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No le interesa esto.")));
  }

  @override
  Widget build(BuildContext context) {
    final encounter = storyTree[currentEncounterId]!;

    return Scaffold(
      backgroundColor: MedievalTheme.darkStone,
      body: SafeArea(
        child: Column(
          children: [
            // --- ZONA DE HISTORIA (Arriba) ---
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                child: Row(
                  children: [
                    // BOTÓN IZQUIERDO (Decisión)
                    Expanded(
                      flex: 1,
                      child: _buildSideChoice(encounter.leftChoiceText, () => _goToNode(encounter.leftNextEncounterId, reward: encounter.leftReward)),
                    ),

                    const SizedBox(width: 8),

                    // CARTA CENTRAL (DragTarget + Imagen + Texto)
                    Expanded(
                      flex: 4,
                      child: DragTarget<Item>(
                        onAccept: (item) => _handleItemDroppedOnCard(item),
                        builder: (context, candidateData, rejectedData) {
                          return Card(
                            color: candidateData.isNotEmpty ? MedievalTheme.highlight : MedievalTheme.parchment,
                            elevation: 8,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Imagen del Personaje
                                Expanded(
                                  flex: 3,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                    child: _buildImage(encounter.imagePath),
                                  ),
                                ),
                                // Nombre y Descripción
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          encounter.characterName,
                                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: MedievalTheme.bloodRed),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          encounter.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 16, color: MedievalTheme.textDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    // BOTÓN DERECHO (Decisión)
                    Expanded(
                      flex: 1,
                      child: _buildSideChoice(encounter.rightChoiceText, () => _goToNode(encounter.rightNextEncounterId, reward: encounter.rightReward)),
                    ),
                  ],
                ),
              ),
            ),

            // --- ZONA BACKPACK (Abajo) ---
            Expanded(
              flex: 2,
              child: Container(
                color: MedievalTheme.leather,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Inventario", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: MedievalTheme.parchment)),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8,
                        ),
                        itemCount: backpack.length < 16 ? 16 : backpack.length,
                        itemBuilder: (context, index) {
                          if (index < backpack.length) {
                            final item = backpack[index];
                            return Draggable<Item>(
                              data: item,
                              feedback: Material(color: Colors.transparent, child: _buildItemWidget(item, isDragging: true)),
                              childWhenDragging: Opacity(opacity: 0.3, child: _buildItemWidget(item)),
                              child: _buildItemWidget(item),
                            );
                          } else {
                            return Container(decoration: BoxDecoration(color: MedievalTheme.slotEmpty, borderRadius: BorderRadius.circular(8)));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  // Botones laterales para las decisiones
  Widget _buildSideChoice(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MedievalTheme.darkStone.withOpacity(0.8),
          border: Border.all(color: MedievalTheme.parchment, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: RotatedBox(
          quarterTurns: 3, // Rota el texto para que quepa en vertical
          child: Text(text, style: const TextStyle(color: MedievalTheme.parchment, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Helper para manejar imágenes faltantes sin que crashee
  Widget _buildImage(String path) {
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Si no encuentra la imagen en tus assets, muestra un icono
        return Container(
          color: Colors.grey[800],
          child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white54, size: 40)),
        );
      },
    );
  }

  // Widget visual de los objetos en la mochila
  Widget _buildItemWidget(Item item, {bool isDragging = false}) {
    return Container(
      width: isDragging ? 80 : null,
      height: isDragging ? 80 : null,
      decoration: BoxDecoration(
        color: MedievalTheme.parchment,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: item.isWeapon ? MedievalTheme.bloodRed : MedievalTheme.highlight, width: isDragging ? 3 : 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono del objeto (puedes cambiarlo por _buildImage(item.imagePath) después)
          Icon(item.isWeapon ? Icons.colorize : Icons.monetization_on, color: MedievalTheme.textDark, size: 24),
          const SizedBox(height: 4),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: MedievalTheme.textDark),
          ),
        ],
      ),
    );
  }
}