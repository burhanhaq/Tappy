import 'package:flutter/material.dart';

class GameState with ChangeNotifier {
  int _taps = 0;
  var _xTapPos = 0.0;
  var _yTapPos = 0.0;
  var _enemyLength = 20.0;
  var _gameOver = false;

  get taps => _taps;

  set taps(int num) {
    _taps = num;
    if (_taps < 0) _taps = 0;
    notifyListeners();
  }

  get xTapPos => _xTapPos;
  get yTapPos => _yTapPos;

  set xTapPos(double val) {
    _xTapPos = val;
    notifyListeners();
  }

  set yTapPos(double val) {
    _yTapPos = val;
    notifyListeners();
  }

  get enemyLength => _enemyLength;

  set enemyLength(double val) {
    _enemyLength = val;
    notifyListeners();
  }

  get gameOver => _gameOver;

  set gameOver(bool val) {
    _gameOver = val;
    notifyListeners();
  }
}
