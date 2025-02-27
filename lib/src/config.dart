import 'package:flame/components.dart';
import 'package:flutter/material.dart'; // Add this import
import 'dart:math';

const brickColors = [ // Add this const
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xfff9844a),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xff4d908e),
  Color(0xff277da1),
  Color(0xff577590),
];
// Size Window
const gameWidth = 820.0;
const gameHeight = 1600.0;
// Ball Stats
const ballRadius = gameWidth * 0.02;
const minDamageBall = 1;
final ballSpeed = Vector2((Random().nextDouble() - 0.5) * gameWidth, gameHeight * 0.2)
    .normalized()
  ..scale(gameWidth / 4);
// Bat Stats
const batWidth = gameWidth * 0.2;
// const batWidth = gameWidth;
const batHeight = ballRadius * 2;
const batStep = gameWidth * 0.1;
// Brick Stats
const brickGutter = gameWidth * 0.015;
final brickWidth =
    (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
const brickHeight = gameHeight * 0.03;
const margintopBrick = gameHeight*0.04;
// Modificator Difficulty
const difficultyModifier = 1.03;
// Drop Ball
const minSpeed = 300;
const maxSpeed = 700;
// POWER UPS
const probPowerUp = 1;
// More Balls
const maxCountBalls = 100;
final newAngleOffset = (Random().nextDouble() - 0.5) * 0.5;
// Big Bat
const timeBigBat = 10.0;
const widthBigBat = 1.25;
// Big Balls
const radiusBigBall = 2.0;
const speedBigBall = 1.10;
const timeBigBall = 5.0;
const damageExtraBigBall = 1;
// Brick Health
const healthminBrick = 1;
const healtMaxBrick = 4;
// Nivel
const startLVL = 1;
final bricksPerRow = ((gameWidth + brickGutter) / (brickWidth + brickGutter)).floor();
final totalWidth = (bricksPerRow * brickWidth) + ((bricksPerRow - 1) * brickGutter);
final sideMargin = (gameWidth - totalWidth) / 2;
// Color
Color randomColor() {
  final random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}



