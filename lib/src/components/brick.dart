import 'dart:math';
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
    anchor: Anchor.center,
    paint: Paint()
      ..color = brickColors[hits-1]
      ..style = PaintingStyle.fill,
    children: [RectangleHitbox()],
  );
  int hits;
  late bool hit1 = false;

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if(other is Ball){
      print("Vida actual:" +hits.toString());
      print("Daño a realizar: "+other.damage.toString());
      hits -= other.damage;
      print("Vida despues de daño: "+hits.toString());
      if(hits>0){

        print("Color del bloque: "+paint.color.toString());

        paint..color = brickColors[hits];

        print("Color despues del hit "+paint.color.toString());
        print("**************");
        return;
      }

      if (hit1 == true) return;
      hit1 = true;
      removeFromParent();
      game.score.value++;

      // Verificar si era el último bloque
      if (game.world.children.query<Brick>().length == 1) {
        game.playState = PlayState.won;
        game.world.removeAll(game.world.children.query<Ball>());
        game.world.removeAll(game.world.children.query<DropBall>());
        game.world.removeAll(game.world.children.query<PowerUp>());
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
}
