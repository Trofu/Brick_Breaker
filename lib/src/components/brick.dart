import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'components.dart';

class Brick extends RectangleComponent
    with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Brick({required super.position, required Color color})
      : super(
    size: Vector2(brickWidth, brickHeight),
    anchor: Anchor.center,
    paint: Paint()
      ..color = color
      ..style = PaintingStyle.fill,
    children: [RectangleHitbox()],
  );

  late bool hit1 = false;

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (hit1 == true) return;
    hit1 = true;
    removeFromParent();
    game.score.value++;

    // Verificar si era el último bloque
    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<DropBall>());
      game.world.removeAll(game.world.children.query<Bat>());
    }else{
      // Probabilidad del 30% de soltar un Power-Up
      if (game.rand.nextDouble() < probPowerUp) {
        final drop = DropBall(position: position.clone(),paint: this.paint);
        game.world.add(drop);
      }
    }
  }

}
