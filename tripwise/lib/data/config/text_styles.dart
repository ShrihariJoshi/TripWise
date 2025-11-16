import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Text robotoText(
  String text, {
  Color color = Colors.black,
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.normal,
  TextAlign textAlign = TextAlign.left,
  TextOverflow? overflow,
  double letterSpacing = -0.28,
}) {
  return Text(
    text,
    style: GoogleFonts.roboto(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
    ),
    overflow: overflow,
    textAlign: textAlign,
  );
}
