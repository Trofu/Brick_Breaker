import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_ap/src/config.dart';
import 'dart:math' as math;

import '../brick_breaker.dart';
import 'drop.dart'; // Importamos Drop
import 'ball.dart'; // Para el efecto de más bolas

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
  final _paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;
  late bool big = false;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size.toSize(),
          cornerRadius,
        ),
        _paint);
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
    if (other is Drop) {
      applyPowerUp(other.type);
      other.removeFromParent(); // Eliminamos el power-up tras activarlo
    }
  }

  void applyPowerUp(TypeDrop type) {
    switch (type) {
      case TypeDrop.moreBalls:
        spawnExtraBall();
      case TypeDrop.bigBat:
        enlargeBat();
      case TypeDrop.nothing:
        break;
    }
  }

// Genera bolas extra desde la última en juego
  void spawnExtraBall() {
    final List<Ball> balls = game.world.children.query<Ball>().toList();
    for(Ball lastBall in balls){
      final Ball ball1 = Ball(
        velocity: Vector2(lastBall.velocity.x + 50, lastBall.velocity.y - 50),
        position: lastBall.position.clone(),
        radius: lastBall.radius,
        difficultyModifier: lastBall.difficultyModifier,
      );
      game.world.add(ball1);
    }
  }

  void enlargeBat() {
    final double originalWidth = size.x;
    size.x *= 1.5;
    if (big==true) return;
    big = true;
    Future.delayed(Duration(seconds: 15), () {
      size.x = originalWidth;
      big=false;
    });
  }
}
