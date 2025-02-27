import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won, nextLvL, notFound, ballOut }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final ValueNotifier<int> lvl = ValueNotifier(startLVL);
  final rand = math.Random();

  double get width => size.x;

  double get height => size.y;
  late PlayState _playState;

  PlayState get playState => _playState;

  set playState(PlayState playState) {
    _playState = playState;
    overlays.clear();
    if (playState != PlayState.playing) {
      overlays.add(playState.name);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    camera.viewfinder.anchor = Anchor.topLeft;
    world.add(PlayArea());
    playState = PlayState.welcome;
  }

  void onGameOver(PlayState motivo) {
    overlays.clear();
    playState = motivo;
    world.removeAll(world.children.query<RemoveEffect>());
    world.removeAll(world.children.query<PowerUp>());
    world.removeAll(world.children.query<DropBall>());
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());
  }

  void checkLevelCompletion() {
    if (playState != PlayState.gameOver && playState != PlayState.ballOut && playState != PlayState.won) {
      if (world.children.query<Brick>().isEmpty) {
        if (lvl.value < levels.length && lvl.value - 1 >= 0) {
          if (playState == PlayState.nextLvL) {
            return;
          }
          playState = PlayState.nextLvL;
          world.removeAll(world.children.query<RemoveEffect>());
          add(RemoveEffect(
              delay: 5,
              onComplete: () {
                loadLevel(++lvl.value);
                playState = PlayState.playing;
              }));
        } else {
          playState = PlayState.won;
        }
      }
    }
  }

  void loadLevel(int level) {
    if (playState == PlayState.playing) return;

    world.removeAll(world.children.query<RemoveEffect>());
    world.removeAll(world.children.query<PowerUp>());
    world.removeAll(world.children.query<DropBall>());
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    var dificultad = difficultyModifier;
    if(level>3){
      dificultad -= 0.02;
    }

    world.add(Ball(
        difficultyModifier: dificultad,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4)));
    world.add(Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        position: Vector2(width / 2, height * 0.95)));

    if (level - 1 < levels.length && level - 1 >= 0) {
      world.addAll(levels[level - 1]());
    } else {
      playState = PlayState.notFound;
    }
    debugMode = true;
  }

  List<Function> levels = [
    () {
      return [
        for (var i = 0; i < bricksPerRow; i++)
          for (var j = 0; j < 5; j++)
            Brick(
              position: Vector2(
                sideMargin + i * (brickWidth + brickGutter),
                margintopBrick + j * (brickHeight + brickGutter),
              ),
              hits: math.Random().nextInt(healthminBrick+1) + healthminBrick, // [1, 2]
            ),
      ];
    },
    () {
      return [
        for (var i = 0; i < bricksPerRow; i++)
          for (var j = 0; j < 6; j++)
            Brick(
              position: Vector2(
                sideMargin + i * (brickWidth + brickGutter),
                margintopBrick + j * (brickHeight + brickGutter),
              ),
              hits: math.Random().nextInt(healtMaxBrick-1) + healthminBrick, // [1, 3]
            ),
      ];
    },
    () {
      return [
        for (var i = 0; i < bricksPerRow; i++)
          for (var j = 0; j < 6; j++)
            if ((i + j) % 2 == 0)
              Brick(
                position: Vector2(
                  sideMargin + i * (brickWidth + brickGutter),
                  margintopBrick + j * (brickHeight + brickGutter),
                ),
                hits: math.Random().nextInt(healtMaxBrick-1) + healthminBrick+1, // [2, 4]
              ),
      ];
    },
    () {
      return [
        for (var i = 0; i < bricksPerRow; i++)
          for (var j = 0; j < 4; j++)
            Brick(
              position: Vector2(
                sideMargin +
                    i * (brickWidth*0.9 + brickGutter) +
                    (j.isEven ? 0 : brickWidth /2), // Alterna la posición
                margintopBrick + j * (brickHeight + brickGutter),
              ),
              hits: math.Random().nextInt(healtMaxBrick) + healthminBrick+1, // [2, 5]
            ),
      ];
    },
    () {
      return [
        for (var j = 0; j < brickColors.length; j++) // Altura de la pirámide
          for (var i = 0;
              i < bricksPerRow - j;
              i++) // Cada fila tiene menos ladrillos
            Brick(
              position: Vector2(
                (gameWidth - ((bricksPerRow - j) * (brickWidth + brickGutter) - brickGutter)) / 2 +
                    i * (brickWidth + brickGutter), // Centrado automático
                margintopBrick + j * (brickHeight + brickGutter),
              ),
              hits:
                  j + 1, // Vida empieza en 1 en la base y aumenta con cada fila
            ),
      ];
    },
  ];

  @override
  void onTap() {
    super.onTap();
    // Si estamos en gameOver, reiniciar el juego
    if (playState == PlayState.gameOver ||
        playState == PlayState.welcome ||
        playState == PlayState.ballOut ||
        playState == PlayState.won) {
      score.value = 0;
      lvl.value = startLVL;
      loadLevel(lvl.value);
      playState = PlayState.playing; // Cambiar el estado a playing
    }
  }

  @override
  KeyEventResult onKeyEvent(
      KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);

    if (event is KeyDownEvent) {
      if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
        world.children.query<Bat>().first.moveBy(-batStep);
      } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
        world.children.query<Bat>().first.moveBy(batStep);
      } else if (keysPressed.contains(LogicalKeyboardKey.space) ||
          keysPressed.contains(LogicalKeyboardKey.enter)) {
        loadLevel(1);
      }
    }
    return KeyEventResult.handled;
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);
}
