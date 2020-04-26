import 'package:flutter/material.dart';

class GameState with ChangeNotifier {
  int _taps = 0;

  get taps => _taps;

  set taps(int num) {
    _taps = num;
    if (_taps < 0) _taps = 0;
    notifyListeners();
  }
}
