import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Center(
        child: Text(
          'Loading..........',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.red[700], Colors.red[200]],
            begin: Alignment.topCenter,
            end: Alignment.center),
      ),
    ));
  }
}
