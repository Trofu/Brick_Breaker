import 'dart:math';
import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'components.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required this.hits})
      : super(
    size: Vector2(brickWidth, brickHeight),
    anchor: Anchor.topLeft ,
    paint: Paint()
      ..color = brickColors[hits - 1] // Color basado en la salud inicial
      ..style = PaintingStyle.fill,
    children: [RectangleHitbox()],
  );

  int hits;
  late bool hit1 = false;

  @override
  void onRemove() {
    super.onRemove();
    game.checkLevelCompletion();
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Ball) {
      hits -= other.damage;  // Reducir la salud por el daño de la pelota

      if (hits > 0) {
        // Actualizar el color del ladrillo basado en los hits restantes
        game.score.value++;
        paint..color = brickColors[hits - 1];
      } else {
        if (hit1 == true) return;
        hit1 = true;  // Evitar múltiples eliminaciones
        removeFromParent();
        game.score.value++; // Incrementar el puntaje
        game.checkLevelCompletion(); // Verificar si se completó el nivel

        // Ver si se genera un PowerUp
        if (game.rand.nextDouble() < probPowerUp) {
          final drop = DropBall(position: position.clone(), paint: paint..color =randomColor());
          game.world.add(drop);
        }
      }
    }
  }
}
