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

enum PlayState { welcome, playing, gameOver, won, nextLvL, notFound }

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

  void onGameOver() {
    overlays.clear();
    playState = PlayState.gameOver;
    score.value = 0;
    lvl.value = startLVL;
    world.removeAll(world.children.query<RemoveEffect>());
    world.removeAll(world.children.query<PowerUp>());
    world.removeAll(world.children.query<DropBall>());
    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());
  }

  void checkLevelCompletion() {
    if(playState!= PlayState.gameOver){
      if (world.children.query<Brick>().isEmpty) {
        if (lvl.value - 1 < levels.length && lvl.value - 1 >= 0) {
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

    world.add(Ball(
        difficultyModifier: difficultyModifier,
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
    debugMode=true;
  }

  List<Function> levels = [
    () {
      // Nivel 1
      return [
        for (var i = 0; i < 10; i++)
          for (var j = 1; j <= 5; j++)
            Brick(
              position: Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter,
                (j + 2.0) * brickHeight + j * brickGutter,
              ),
              hits: math.Random().nextInt(healtMaxBrick-(healtMaxBrick-2)) +
                  healthminBrick,
            ),
      ];
    },
    () {
      // Nivel 2
      return [
        for (var i = 0; i < 12; i++)
          for (var j = 1; j <= 6; j++)
            Brick(
              position: Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter * 1.2,
                (j + 2.0) * brickHeight + j * brickGutter,
              ),
              hits: math.Random().nextInt(healtMaxBrick - 1) +
                  healthminBrick +
                  1, // mayor salud
            ),
      ];
    },
    () {
      // Nivel 3
      return [
        for (var i = 0; i < 8; i++)
          for (var j = 1; j <= 6; j++)
            if ((i % 2 == 0 && j % 2 == 0) || (i % 2 == 1 && j % 2 == 1))
              Brick(
                position: Vector2(
                  (i + 0.5) * brickWidth + (i + 1) * brickGutter * 1.3,
                  (j + 2.0) * brickHeight + j * brickGutter,
                ),
                hits: math.Random().nextInt(healtMaxBrick - 1) +
                    healthminBrick +
                    2, // más salud
              ),
      ];
    },
    () {
      // Nivel 4
      return [
        for (var i = 0; i < 15; i++)
          for (var j = 1; j <= 4; j++)
            Brick(
              position: Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter * 1.4,
                (j + 1.5) * brickHeight + j * brickGutter,
              ),
              hits: math.Random().nextInt(healtMaxBrick - 1) +
                  healthminBrick +
                  3, // más salud
            ),
      ];
    },
    () {
      // Nivel 5
      return [
        for (var i = 0; i < 10; i++)
          for (var j = 0; j < 10; j++)
            Brick(
              position: Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter * 1.1,
                (j + 1.5) * brickHeight + j * brickGutter,
              ),
              hits: math.Random().nextInt(healtMaxBrick - 1) +
                  healthminBrick +
                  4, // más salud
            ),
      ];
    },
  ];

  @override
  void onTap() {
    super.onTap();
    // Si estamos en gameOver, reiniciar el juego
    if (playState == PlayState.gameOver || playState == PlayState.welcome) {
      loadLevel(lvl.value);
      score.value = 0;
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
