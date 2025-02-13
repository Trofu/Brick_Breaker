import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../brick_breaker.dart';
import 'bat.dart';
import 'components.dart';

enum TypeDrop { moreBalls, bigBat, nothing }

class Drop extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Drop({required this.type, required super.position, required super.paint})
      : super(
    radius: 10, // Tamaño del power-up
    anchor: Anchor.center,
    children: [CircleHitbox()],
  );

  final TypeDrop type;
  final Vector2 velocity = Vector2(0, 500); // Velocidad de caída

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
