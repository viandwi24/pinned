import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kBackgroundColor = Color(0xFFF6FAFB);
const Color kPrimaryColor = Color(0xFFFE7561);
const Color kDarkTextColor = Color(0xFFF1F1F1);
const Color kLightTextColor = Color(0xFF1D1D1D);
const Color kTextColor = kLightTextColor;
const Color kPlaceholderCardColor = Color(0xFFE5E5E5);
const Color kMutedTextColor = Color(0xFFA3A3A3);
const Color kBorderInputColor = Color(0xFF1D1D1D);

// THEME DATA
final TextTheme kDefaultTextTheme = TextTheme(
  button: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 20,
      color: kTextColor,
    ),
  ),
  bodyText1: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 14,
      color: kTextColor,
    ),
  ),
  bodyText2: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 14,
      color: kTextColor,
    ),
  ),
  headline1: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  headline2: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  headline3: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  headline4: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  headline5: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  headline6: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w500,
      color: kTextColor,
    ),
  ),
  caption: GoogleFonts.poppins(
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: kTextColor,
    ),
  ),
);
