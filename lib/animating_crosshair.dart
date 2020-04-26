import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'constants.dart';


class AnimatingCrosshair extends StatefulWidget {
  @override
  _AnimatingCrosshairState createState() => _AnimatingCrosshairState();
}

class _AnimatingCrosshairState extends State<AnimatingCrosshair>
    with TickerProviderStateMixin {
  final spacingOffset = 20.0;
  final iconSize = 40.0;


  @override
  Widget build(BuildContext context) {

    return Container(
      width: 80,
      height: 80,
      color: trans,
      child: Stack(
        alignment: FractionalOffset.center,
        children: <Widget>[
          Transform.translate(
            offset: Offset(0, -spacingOffset),
            child: Icon(Icons.keyboard_arrow_down,
                color: yellow, size: iconSize),
          ),
          Transform.translate(
            offset: Offset(0, spacingOffset),
            child: Icon(Icons.keyboard_arrow_up,
                color: yellow, size: iconSize),
          ),
          Transform.translate(
            offset: Offset(-spacingOffset, 0),
            child: Icon(Icons.keyboard_arrow_right,
                color: yellow, size: iconSize),
          ),
          Transform.translate(
            offset: Offset(spacingOffset, 0),
            child: Icon(Icons.keyboard_arrow_left,
                color: yellow, size: iconSize),
          ),
        ],
      ),
    );
  }
}
