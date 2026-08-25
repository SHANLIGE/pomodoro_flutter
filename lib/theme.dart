import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Paleta ---
const cream = Color(0xFFFCF9F2);
const creamSidebar = Color(0xFFFCF9F2);
const creamBar = Color(0xFFFCF9F2);

const green = Color(0xFF3F9142);
const greenBright = Color(0xFF4CAF50);
const greenSoft = Color(0xFFEAF3E2);
const greenBorder = Color(0xFF6BA85F);

const ink = Color(0xFF364E3F);
const inkMuted = Color(0xFF8C8B80);
const inkFaint = Color(0xFFB5B2A5);
const line = Color(0xFFD8D3C4);

const projectPink = Color(0xFFE86FA8);
const projectBlue = Color(0xFF5B7CE8);
const projectRed = Color(0xFFE05A4A);

// --- Medidas ---
const px = 3.0; // unidad de "pixel" para los bordes escalonados
const sidebarWidth = 268.0;
const taskRowHeight = 46.0;

// --- Tipografía ---
// Jersey 10 para títulos y números; Kode Mono para texto de lectura.
TextStyle display(double size, {Color color = ink, FontWeight? weight}) =>
    GoogleFonts.jersey10(
      fontSize: size,
      color: color,
      fontWeight: weight ?? FontWeight.w400,
      height: 1.05,
    );

TextStyle mono(
  double size, {
  Color color = ink,
  FontWeight weight = FontWeight.w400,
  double spacing = 0,
}) =>
    GoogleFonts.kodeMono(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: spacing,
      height: 1.35,
    );