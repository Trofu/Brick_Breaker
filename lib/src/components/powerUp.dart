import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class PowerUp extends Component with HasGameReference<BrickBreaker> {
  bool bigBat = false;
  bool bigBalls = false;
  final TypeDrop powerUpType;
  final Paint color;

  PowerUp({required this.powerUpType, required this.color});

  @override
  void onMount() {
    super.onMount();
    usePowerUp(powerUpType);
  }

  void usePowerUp(TypeDrop other) {
    switch (other) {
      case TypeDrop.moreBalls:
        spawnExtraBall();
        break;
      case TypeDrop.bigBat:
        enlargeBat();
        break;
      case TypeDrop.bigBall:
        makeBigBalls();
        break;
    }
  }

  void enlargeBat() {
    final Bat bat = game.world.children.query<Bat>().first;
    bat.children.query<BatGlow>().forEach((e) => e.removeFromParent());

    if (bat.size.x * widthBigBat > gameWidth / 2) return;

    bat.size.x *= widthBigBat;
    bat.children.query<BatGlow>().forEach((e) => e.removeFromParent());
    final batGlow = BatGlow(size: bat.size, color: Colors.blue);
    bat.add(batGlow);
    if (!bigBat) {
      bigBat = true;
      add(RemoveEffect(
        delay: (timeBigBat - 2) as double,
        onComplete: () {
          bat.children.query<BatGlow>().forEach((e) => e.add(
                SequenceEffect([
                  OpacityEffect.to(0.2, EffectController(duration: 0.2)),
                  OpacityEffect.to(1.0, EffectController(duration: 0.2)),
                ], repeatCount: 6),
              ));
        },
      ));
      add(RemoveEffect(
        delay: timeBigBat as double,
        onComplete: () {
          bat.size.x = batWidth;
          bigBat = false;
          batGlow.removeFromParent();
          bat.children.query<BatGlow>().forEach((e) => e.removeFromParent());
        },
      ));
    }
  }

  void spawnExtraBall() {
    final List<Ball> balls = game.world.children.query<Ball>().toList();
    if (balls.length >= maxCountBalls) return;

    for (Ball lastBall in balls) {
      final Ball ball1 = Ball(
        velocity: lastBall.velocity.clone()..rotate(newAngleOffset),
        position: lastBall.position.clone(),
        radius: lastBall.radius,
        difficultyModifier: lastBall.difficultyModifier,
      );
      ball1.paint = color;
      game.world.add(ball1);
    }
  }

  void makeBigBalls() {
    // Añadir Limites de bola Grande, hacer bola paqueña mas veloz y grande maz lenta
    var normalSpeed;
    game.world.children.query<Ball>().toList().forEach((ball) {
      normalSpeed = ball.velocity;
      ball.radius = (ballRadius * radiusBigBall);
      ball.velocity.setFrom(ball.velocity * speedBigBall);
      ball.damage += damageExtraBigBall;
    });
    if (bigBalls == true) return;
    bigBalls = true;
    add(RemoveEffect(delay: timeBigBall as double, onComplete: (){
      game.world.children.query<Ball>().toList().forEach((ball) {
        ball.radius = ballRadius;
        ball.velocity.setFrom(normalSpeed);
        ball.damage = minDamageBall;
      });
      bigBalls = false;
    }));
  }
}

enum TypeDrop { moreBalls, bigBat, bigBall }

TypeDrop getRandomDropType() {
  return TypeDrop.values[Random().nextInt(TypeDrop.values.length)];
}

class BatGlow extends RectangleComponent {
  BatGlow({required super.size, required Color color})
      : super(
          paint: Paint()
            ..color = color.brighten(0.5)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0),
        );
}
