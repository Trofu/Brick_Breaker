import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';
import 'ball.dart';
import 'bat.dart';
import 'drop.dart'; // Importar la clase Drop

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

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    removeFromParent();
    game.score.value++;

    // Probabilidad del 30% de soltar un Power-Up
    if (game.rand.nextDouble() < 1) {
      final dropType = (game.rand.nextBool()) ? TypeDrop.moreBalls : TypeDrop.bigBat;
      final drop = Drop(type: TypeDrop.bigBat, position: position.clone(),paint: this.paint);
      game.world.add(drop);
    }

    // Verificar si era el último bloque
    if (game.world.children.query<Brick>().length == 1) {
      game.playState = PlayState.won;
      game.world.removeAll(game.world.children.query<Ball>());
      game.world.removeAll(game.world.children.query<Bat>());
      game.world.removeAll(game.world.children.query<Drop>());
    }
  }

  // Método para obtener un power-up aleatorio
  TypeDrop getRandomDropType() {
    List<TypeDrop> types = [TypeDrop.moreBalls, TypeDrop.bigBat];
    return types[Random().nextInt(types.length)];
  }
}
