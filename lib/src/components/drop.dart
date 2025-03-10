
import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class DropBall extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  DropBall({ required super.position, required super.paint})
      : super(
    radius: 10, // Tamaño del power-up
    anchor: Anchor.center,
    children: [CircleHitbox()],
  );

  final Vector2 velocity = Vector2(0, Random().nextDouble() * (maxSpeed - minSpeed) + minSpeed);

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt; // Simula la caída del Drop
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      game.world.remove(this);
      return;
    }
  }



}
