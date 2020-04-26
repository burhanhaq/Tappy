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
        !gs.gameOver) {
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
        if (!gs.gameOver) {
          crosshairScaleController.forward();
          randomWidth = randomLoc.nextDouble();
          randomHeight = randomLoc.nextDouble();
        }
        break;
    }

    _onTapBackground(TapDownDetails details) {
      setState(() {
        print('tapped background');
        if (!gs.gameOver) {
          randomWidth = randomLoc.nextDouble();
          randomHeight = randomLoc.nextDouble();
          cursorErrorController.forward();
//          gs.taps = gs.taps % 2 == 0 ? gs.taps / 2 : (gs.taps - 1) / 2;
          --gs.taps;
          if (gs.gameOver) {
            replayIconOpacityController.forward();
          }

          gs.xTapPos = details.globalPosition.dx;
          gs.yTapPos = details.globalPosition.dy;
          gs.enemyLength += 50.0;
        }
      });
    }

    _onTapCrosshair() {
      setState(() {
        if (gs.gameOver) {
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
      print('tapped replay');
      setState(() {
        gameOverScaleController.reverse();
        crosshairScaleControllerDuration = Duration(milliseconds: 800);
        crosshairScaleController = AnimationController(
          vsync: this,
          duration: crosshairScaleControllerDuration,
        );
        replayIconRotateController.forward(from: 0.0);
        replayIconOpacityController.reverse();
        gs.enemyLength = 20;
        gs.gameOver = false;
        gs.xTapPos = 0.0;
        gs.yTapPos = 0.0;
        gs.taps = 0;
      });
    }

    _onTapGameOverOverlay() {
      print('tapped gameover overlay');
      setState(() {
        replayIconRotateController.forward(from: 0.0);
      });
    }

    _onTapEnemy() {
      print('tapped enemy');
      setState(() {
        gs.gameOver = true;
        gameOverScaleController.forward();
        replayIconOpacityController.forward();
      });
    }

    return Material(
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapBackground,
        child: Container(
          color: red1,
          width: width,
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Opacity(
                opacity: 0.1,
                child: Container(
                  width: width * 0.8 + 20,
                  height: height * 0.8 + 20,
                  color: trans,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: Icon(
                      Icons.adb,
                      size: 1000,
                    ),
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
                top: gs.yTapPos - gs.enemyLength / 2,
                left: gs.xTapPos - gs.enemyLength / 2,
                child: GestureDetector(
                  onTap: _onTapEnemy,
                  child: Offstage(
                    offstage: gs.xTapPos == 0,
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
//                        width: enemyLength,
//                        height: enemyLength,
//                        color: red2,
//                        child: Image(
//                          image: AssetImage('images/android.png'),
//                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.adb,
                              size: gs.enemyLength,
                              color: red3,
                            ),
                            Icon(
                              Icons.adb,
                              size: gs.enemyLength-gs.enemyLength*0.01,
                              color: red2,
                            ),
                            Positioned(
                              left: 0,
                              child: GestureDetector(
                                onTap: () {
                                  print('This hit test is ignored');
                                },
                                child: Container(
                                  color: trans,
                                  width: gs.enemyLength * 0.2,
                                  height: gs.enemyLength,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  print('This hit test is ignored');
                                },
                                child: Container(
                                  color: trans,
                                  width: gs.enemyLength * 0.2,
                                  height: gs.enemyLength,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: gs.yTapPos - 1500 * gameOverScaleController.value/2,
                left: gs.xTapPos - 1500 * gameOverScaleController.value/2,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _onTapGameOverOverlay,
                  child: Opacity(
                    opacity: 0.5,
                    child: Container( // todo check if values work with tab
                      width: 1500 * gameOverScaleController.value,
                      height: 1500 * gameOverScaleController.value,
                      decoration: BoxDecoration(
                        color: red3,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.14,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          gs.taps.toString(),
                          style: gs.gameOver
                              ? kLabelStyle.copyWith(
                                  fontWeight: FontWeight.w400,
                                )
                              : kLabelStyle,
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
                    SizedBox(height: 25),
                    Offstage(
                      offstage: !gs.gameOver,
                      child: Text(
                        'Game Over!',
                        style: kLabelStyle.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    IgnorePointer(
                      ignoring: !gs.gameOver,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _onTapReplay,
                        child: Opacity(
                          opacity: replayIconOpacityController.value,
                          child: Transform.rotate(
                            angle: -2 * math.pi * replayIconRotateAnimation.value,
                            child: Icon(Icons.replay, color: yellow, size: 80),
                          ),
                        ),
                      ),
                    ),
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
    gameOverScaleController.dispose();
    super.dispose();
  }
}
