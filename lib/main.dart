import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const ZeldaBrawlApp());
}

class ZeldaBrawlApp extends StatelessWidget {
  const ZeldaBrawlApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wind Waker Brawl',
      theme: ThemeData(
        fontFamily: 'Roboto', // Si descargas una fuente de Zelda, ponla aquí
      ),
      home: const GameScreen(),
    );
  }
}
