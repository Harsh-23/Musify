import 'package:flutter/material.dart';
import 'package:music/style/appColors.dart';
import 'package:music/ui/musify.dart';

main() async {
  runApp(
    MaterialApp(
      theme: ThemeData(
        fontFamily: "DMSans",
        accentColor: accent,
        primaryColor: accent,
        canvasColor: Colors.transparent,
      ),
      home: Musify(),
    ),
  );
}
