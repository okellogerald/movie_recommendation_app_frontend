import 'package:flutter/material.dart';
import 'package:recommendation/source.dart';


class SharedWidgets{
    Widget indicator(String message) {
    return Column(
      children: [
        Expanded(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation(Color(0xffFB3A3D)),
              ),
              SizedBox(height: 40),
              text(message, color: Colors.white)
            ])))
      ],
    );
  }

   Text myCustomizedText(String data,
      {bool withLinearGradient = false,
      List<Color> colors = const [Colors.yellow, Colors.orange],
      Color color = Colors.black,
      String family = 'Medium',
      TextAlign alignment = TextAlign.start,
      int size = 20}) {
    return withLinearGradient
        ? Text(data,
            style: TextStyle(
                fontSize: size.toDouble(),
                fontFamily: family,
                foreground: Paint()
                  ..shader = LinearGradient(colors: colors)
                      .createShader((Rect.fromLTWH(0.0, 0.0, 350.0, 100.0)))))
        : Text(data,
            textAlign: alignment,
            style: TextStyle(
                fontSize: size.toDouble(), fontFamily: family, color: color));
  }
}