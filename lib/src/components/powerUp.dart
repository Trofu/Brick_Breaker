import 'dart:math';

import 'package:flame/components.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class PowerUp extends Component with HasGameReference<BrickBreaker> {

  late bool big = false;
  late TypeDrop powerUpType;

  PowerUp() {
    usePowerUp(getRandomDropType());
  }


  void usePowerUp(TypeDrop other) {
    switch (other) {
      case TypeDrop.moreBalls:
        spawnExtraBall();
      case TypeDrop.bigBat:
        enlargeBat();
    }
  }

  void enlargeBat() {
    final Bat bat = game.world.children.query<Bat>().first;
    final double originalWidth = bat.size.x;
    bat.size.x *= 1.5;
    if (big == true) return;
    big = true;
    Future.delayed(Duration(seconds: 15), () {
      bat.size.x = originalWidth;
      big = false;
    });
  }

  void spawnExtraBall() {
    final List<Ball> balls = game.world.children.query<Ball>().toList();
    for (Ball lastBall in balls) {
      final Ball ball1 = Ball(
        velocity: speedNewBall,
        position: lastBall.position.clone(),
        radius: lastBall.radius,
        difficultyModifier: lastBall.difficultyModifier,
      );
      game.world.add(ball1);
    }
  }
}

enum TypeDrop { moreBalls, bigBat }

TypeDrop getRandomDropType() {
  return TypeDrop.values[Random().nextInt(TypeDrop.values.length)];
}
