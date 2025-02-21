import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
    radius: radius,
    anchor: Anchor.center,
    paint: Paint()
      ..color = const Color(0xff1e6091)
      ..style = PaintingStyle.fill,
    children: [CircleHitbox()],
  );

  final Vector2 velocity;
  final double difficultyModifier;
  late int damage = minDamageBall;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0 || intersectionPoints.first.y >= game.height) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0 || intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      }
      if (intersectionPoints.first.y >= game.height) {
        if (game.world.children.query<Ball>().length == 1) {
            game.onGameOver();
        } else {
          removeFromParent();
        }
      }
    } else if (other is Bat) {
      velocity.y = -velocity.y;
      velocity.x += (position.x - other.position.x) / other.size.x * game.width * 0.3;
    } else if (other is Brick) {
      velocity.y = -velocity.y;
      velocity.setFrom(velocity * difficultyModifier);
    }
  }
}
