import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Paleta portada 1:1 desde las variables de main.py.
// En Dart los colores son 0xAARRGGBB: el FF inicial es la opacidad.
const backgroundColor = Color(0xFFFFFFFF);
const primaryColor = Color(0xFFFFC7F5);
const secondaryColor = Color(0xFFFF85BE);
const textColor = Color(0xFF333333);
const textColorTertiary = Color(0xFF808080);
const textColorDone = Color(0xFFB0B0B0);
const scrollbarColor = Color(0xFFE0E0E0);

const titleBarTextColor = Color(0xFF262728);
const titleBarHoverColor = Color(0xFFB6B6B6);
const borderColor = Color(0xFFE4E6E9);

const windowRadius = 12.0;
const taskRowHeight = 46.0;
const backgroundtransparent = Colors.transparent;

const degrade = LinearGradient(
  colors: [
    Color.fromARGB(255, 255, 162, 138),
    Color.fromARGB(255, 255, 136, 245),
    Color.fromARGB(255, 136, 144, 255),
  ],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);
final fontFamily = GoogleFonts.manropeTextTheme();
