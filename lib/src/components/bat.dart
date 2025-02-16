import 'dart:math' as math;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_ap/src/config.dart';

import '../brick_breaker.dart';
import 'components.dart';

class Bat extends PositionComponent
    with DragCallbacks, CollisionCallbacks, HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  final rand = math.Random();

  final Radius cornerRadius;
  final paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size.toSize(),
          cornerRadius,
        ),
        paint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x)
        .clamp(0 + batWidth / 2, game.width - batWidth / 2);
  }

  void moveBy(double dx) {
    add(MoveToEffect(
      Vector2(
          (position.x + dx).clamp(0 + batWidth / 2, game.width - batWidth / 2),
          position.y),
      EffectController(duration: 0.1),
    ));
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is DropBall) {
      game.score.value++;
      final power = PowerUp(powerUpType: getRandomDropType(), color: other.paint);
      game.world.add(power);
      other.removeFromParent();
    }
  }
}
