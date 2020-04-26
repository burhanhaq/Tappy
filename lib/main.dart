import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'game_state.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tappy',
      initialRoute: Home.id,
      routes: {
        Home.id: (context) => ChangeNotifierProvider(
            create: (context) => GameState(),
            child: Home()),
      },
    );
  }
}
