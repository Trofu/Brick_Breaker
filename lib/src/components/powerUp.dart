import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class PowerUp extends Component with HasGameReference<BrickBreaker> {
  late bool bigBat = false;
  late bool bigBalls = false;
  late TypeDrop powerUpType;

  PowerUp({required this.powerUpType});

  @override
  void onMount() {
    usePowerUp(this.powerUpType);
  }

  void usePowerUp(TypeDrop other) {
    switch (other) {
      case TypeDrop.moreBalls:
        spawnExtraBall();
      case TypeDrop.bigBat:
        enlargeBat();
      case TypeDrop.bigBall:
        makeBigBalls();
    }
  }

  void enlargeBat() {
    final Bat bat = game.world.children.query<Bat>().first;
    final double originalWidth = bat.size.x;

    // Asegúrate de que la bat no se agrande más allá del ancho del juego
    if (bat.size.x * 1.5 > game.width) return;

    bat.size.x *= 1.5;
    if (bigBat == true) return;
    bigBat = true;

    // Aplica el GlowEffect cuando la bat se agrande
    bat.applyGlow();

    // Devolver el tamaño original después de un tiempo
    Future.delayed(Duration(seconds: 15), () {
      bat.size.x = originalWidth;
      bigBat = false;
    });
  }



  void spawnExtraBall() {
    final List<Ball> balls = game.world.children.query<Ball>().toList();
    if (balls.length > 100) return;
    for (Ball lastBall in balls) {
      final Ball ball1 = Ball(
        velocity: lastBall.velocity.clone()..rotate(newAngleOffset),
        position: lastBall.position.clone(),
        radius: lastBall.radius,
        difficultyModifier: lastBall.difficultyModifier,
      );
      game.world.add(ball1);
    }
  }

  void makeBigBalls() {
    game.world.children
        .query<Ball>()
        .toList()
        .forEach((ball) => ball.radius = ballRadius * 1.50);
    if (bigBalls == true) return;
    bigBalls = true;
    Future.delayed(Duration(seconds: 15), () {
      game.world.children
          .query<Ball>()
          .toList()
          .forEach((ball) => ball.radius = ballRadius);
      bigBalls = false;
    });
  }
}

enum TypeDrop { moreBalls, bigBat, bigBall }

TypeDrop getRandomDropType() {
  return TypeDrop.values[Random().nextInt(TypeDrop.values.length)];
}
