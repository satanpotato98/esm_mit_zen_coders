import 'package:flutter/material.dart';

class LogoPage extends StatelessWidget {
  const LogoPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Container(
          height: double.infinity,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 30.0,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  child: Image(
                    image: AssetImage('assets/logo-black.png'),
                  ),
                ),
              ]),
        )));
  }
}
