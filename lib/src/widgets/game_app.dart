import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'overlay_screen.dart'; // Add this import
import 'score_card.dart'; // And this one too

class GameApp extends StatefulWidget {
  // Modify this line
  const GameApp({super.key});

  @override // Add from here...
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final BrickBreaker game;

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();
  } // To here.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      home: Scaffold(
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xffa9d6e5),
                  Color(0xfff2e8cf),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Column(
                    // Modify from here...
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double scaleFactor = constraints.maxWidth / gameWidth;
                          return Transform.scale(
                            scale: scaleFactor,
                            child: ScoreCard(score: game.score, lvl: game.lvl,),
                          );
                        },
                      ),
                      Expanded(
                        child: FittedBox(
                          child: SizedBox(
                            width: gameWidth,
                            height: gameHeight,
                            child: GameWidget(
                              game: game,
                              overlayBuilderMap: {
                                PlayState.welcome.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'TAP TO PLAY',
                                      subtitle: 'Use arrow keys or swipe',
                                    ),
                                PlayState.gameOver.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'G A M E O V E R',
                                      subtitle: 'Tap to Play Again',
                                    ),
                                PlayState.won.name: (context, game) =>
                                    const OverlayScreen(
                                      title: 'Y O U W O N ! ! !',
                                      subtitle: 'Tap to Play Again',
                                    ),
                                PlayState.nextLvL.name: (context, game) =>
                                const OverlayScreen(
                                  title: 'N E X T  L E V E L !',
                                  subtitle: 'Get Ready...',
                                ),
                                PlayState.notFound.name: (context, game) =>
                                const OverlayScreen(
                                  title: '   L E V E L\n'
                                      'N O T F O U N D',
                                  subtitle: 'Start Again',
                                ),
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ), // To here.
                ),
              ),
            )),
      ),
    );
  }
}
