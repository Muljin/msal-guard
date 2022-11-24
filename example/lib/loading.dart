import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(builder: (context, child) {
      return Scaffold(
          body: Center(
        child: CircularProgressIndicator(),
      ));
    });
  }
}
