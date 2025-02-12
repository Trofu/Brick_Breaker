import 'package:flame/collisions.dart'; // Add this import
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../brick_breaker.dart'; // And this import
import 'play_area.dart'; // And this one too
class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> { // Add these mixins
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
  }) : super(
      radius: radius,
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xff1e6091)
        ..style = PaintingStyle.fill,
      children: [CircleHitbox()]); // Add this parameter
  final Vector2 velocity;
  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }
  @override // Add from here...
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        removeFromParent();
      }
    } else {
      debugPrint('collision with $other');
    }
  } // To here.
}