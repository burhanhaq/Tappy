import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';

import 'constants.dart';
import 'animating_crosshair.dart';
import 'game_state.dart';

class Home extends StatefulWidget {
  static final String id = 'Home';

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  var randomLoc = math.Random();
  var randomWidth;
  var randomHeight;

  var cursorOpacityController;
  var cursorErrorController;
  var replayIconOpacityController;
  var replayIconRotateController;
  var replayIconRotateAnimation;
  var crosshairRotateController;
  var crosshairScaleController;
  var gameOverScaleController;

  var crosshairScaleControllerDuration;
  var xTapPos = 0.0;
  var yTapPos = 0.0;
  var enemyLength = 20.0;
  var gameOver = false;

  @override
  void initState() {
    super.initState();
    randomWidth = randomLoc.nextDouble();
    randomHeight = randomLoc.nextDouble();

    cursorOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
        setState(() {});
      });
    cursorErrorController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    )
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          cursorErrorController.reverse();
        }
      });
    replayIconOpacityController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
        setState(() {});
      });
    replayIconRotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    replayIconRotateAnimation = CurvedAnimation(
      parent: replayIconRotateController,
      curve: Curves.easeOutBack,
    )..addListener(() {
        setState(() {});
      });
    crosshairRotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 900),
    )..addListener(() {
        setState(() {});
      });
    crosshairScaleControllerDuration = Duration(milliseconds: 800);
    crosshairScaleController = AnimationController(
      vsync: this,
      duration: crosshairScaleControllerDuration,
    )..addListener(() {
        setState(() {});
      });
    gameOverScaleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    )..addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    GameState gs = Provider.of<GameState>(context);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if (cursorOpacityController.status == AnimationStatus.completed) {
      cursorOpacityController.reverse();
    } else if (cursorOpacityController.status == AnimationStatus.dismissed &&
        !gameOver) {
      cursorOpacityController.forward();
    }
    // animating crosshair
    if (!crosshairRotateController.isAnimating) {
      crosshairRotateController.forward(from: 0.0);
    }
    switch (crosshairScaleController.status) {
      case AnimationStatus.completed:
        crosshairScaleController.reverse();
        break;
      case AnimationStatus.dismissed:
        if (!gameOver) {
          crosshairScaleController.forward();
          randomWidth = randomLoc.nextDouble();
          randomHeight = randomLoc.nextDouble();
        }
        break;
    }

    _onTapBackground(TapDownDetails details) {
      setState(() {
        if (!gameOver) {
          print('tapped main');
          randomWidth = randomLoc.nextDouble();
          randomHeight = randomLoc.nextDouble();
          cursorErrorController.forward();
//          gs.taps = gs.taps % 2 == 0 ? gs.taps / 2 : (gs.taps - 1) / 2;
          --gs.taps;
          if (gameOver) {
            replayIconOpacityController.forward();
          }

          xTapPos = details.globalPosition.dx;
          yTapPos = details.globalPosition.dy;
          enemyLength += 50;
        }
      });
    }

    _onTapCrosshair() {
      setState(() {
        if (gameOver) {
          replayIconRotateController.forward(from: 0.0);
        } else {
          crosshairScaleControllerDuration *= 0.97;
          crosshairScaleController = AnimationController(
            vsync: this,
            duration: crosshairScaleControllerDuration,
          );
          randomWidth = randomLoc.nextDouble();
          randomHeight = randomLoc.nextDouble();
          ++gs.taps;
        }
        print('tapped crosshair----------------------');
      });
    }

    _onTapReplay() {
      setState(() {
        gameOverScaleController.reverse();
        crosshairScaleControllerDuration = Duration(milliseconds: 800);
        crosshairScaleController = AnimationController(
          vsync: this,
          duration: crosshairScaleControllerDuration,
        );
        replayIconRotateController.forward(from: 0.0);
        replayIconOpacityController.reverse();
        enemyLength = 20;
        gameOver = false;
        xTapPos = 0.0;
        yTapPos = 0.0;
        gs.taps = 0;
      });
    }

    _onTapEnemy() {
      // todo add animation
      setState(() {
        print('YEEEEhaawwwwww');
        gameOver = true;
        gameOverScaleController.forward();
        replayIconOpacityController.forward();
      });
    }

    return Material(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapBackground,
        child: Container(
//          padding: EdgeInsets.symmetric(horizontal: 20),
          // add a controller or something here maybe
          color: red1,
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: 0.2,
                child: Container(
                  width: width * 0.8 + 20,
                  height: height * 0.8 + 20,
                  decoration: BoxDecoration(
                    color: trans,
                    border: Border.all(color: red12, width: 4),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(randomWidth * width * 0.8 - width / 2 * 0.8,
                    randomHeight * height * 0.8 - height / 2 * 0.8),
                child: GestureDetector(
                  onTap: _onTapCrosshair,
                  child: Transform.rotate(
                    angle: math.pi / 2 * crosshairRotateController.value,
                    child: Transform.scale(
                        alignment: Alignment.center,
                        scale: 0.2 + 0.4 * crosshairScaleController.value,
                        child: AnimatingCrosshair()),
                  ),
                ),
              ),
              Positioned(
                top: yTapPos - enemyLength / 2,
                left: xTapPos - enemyLength / 2,
                child: GestureDetector(
                  onTap: _onTapEnemy,
                  child: Offstage(
                    offstage: xTapPos == 0,
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
//                        width: enemyLength,
//                        height: enemyLength,
//                        color: red2,
//                        child: Image(
//                          image: AssetImage('images/android.png'),
//                        ),
                        child: Icon(
                          Icons.adb,
                          size: enemyLength,
                          color: red3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: yTapPos - 5,
                left: xTapPos - 5,
                child: Offstage(
                  offstage: false,
                  child: Opacity(
                    opacity: 0.5,
                    child: Transform.scale(
                      scale: 200 * gameOverScaleController.value,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: red3,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: !gameOver,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTapReplay,
                  child: Opacity(
                    opacity: replayIconOpacityController.value,
                    child: Transform.rotate(
                      angle: -2 * math.pi * replayIconRotateAnimation.value,
                      child: Icon(Icons.replay, color: yellow, size: 120),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.14,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      gs.taps == 0 ? '' : gs.taps.toString(),
                      style: kLabelStyle,
                    ),
                    Opacity(
                      opacity: cursorOpacityController.value,
                      child: Container(
                        width: 2,
                        height: 80,
                        color: yellow,
                      ),
                    ),
                    SizedBox(width: 0 + 40 * cursorErrorController.value),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cursorOpacityController.dispose();
    replayIconOpacityController.dispose();
    replayIconRotateController.dispose();
    cursorErrorController.dispose();
    crosshairScaleController.dispose();
    crosshairRotateController.dispose();
    super.dispose();
  }
}
