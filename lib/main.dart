import 'package:flutter/material.dart';
import 'package:music/ui/musify.dart';

import 'music.dart';

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
