import 'package:flutter/material.dart';

/// Ancient archaeologist's ledger theme definition.
/// Evokes the feel of a rare manuscript bound in dark weathered leather,
/// with aged parchment folios, gold-foil stamped titles, and charcoal ink.
class LedgerTheme {
  // Leather & Binding Tones
  static const Color leatherDarkest = Color(0xFF0F0804);
  static const Color leatherDark = Color(0xFF1B0E07);
  static const Color leatherBase = Color(0xFF2B180D);
  static const Color leatherHighlight = Color(0xFF3F2414);
  static const Color leatherBorder = Color(0xFF4D2C19);
  static const Color leatherStitch = Color(0xFFC29B38);

  // Brass, Bronze & Gold Foil Tones
  static const Color goldFoil = Color(0xFFD4AF37);
  static const Color goldFoilLight = Color(0xFFF9E498);
  static const Color goldFoilDark = Color(0xFF9E781B);
  static const Color antiqueBronze = Color(0xFF8A6A3B);
  static const Color brassShadow = Color(0xFF4A381C);

  // Parchment & Paper Tones
  static const Color parchmentBackground = Color(0xFFF5EEDD);
  static const Color parchmentPage = Color(0xFFF4ECD8);
  static const Color parchmentDark = Color(0xFFE4D4B3);
  static const Color parchmentAged = Color(0xFFD9C69E);
  static const Color parchmentEdge = Color(0xFFBFAB81);
  static const Color parchmentRedMargin = Color(0x33A3382A);

  // Inks & Typography Tones
  static const Color charcoalInk = Color(0xFF1E1A18);
  static const Color fadedInk = Color(0xFF3C3530);
  static const Color umberInk = Color(0xFF5A3D28);
  static const Color interrogatorRed = Color(0xFF7A2016);
  static const Color waxSealRed = Color(0xFF8E1B1B);
  static const Color waxSealDark = Color(0xFF520E0E);

  // Leather Gradients
  static const LinearGradient leatherGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [leatherHighlight, leatherBase, leatherDark, leatherDarkest],
    stops: [0.0, 0.35, 0.75, 1.0],
  );

  static const LinearGradient leatherAppBarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2F1A0E), Color(0xFF1E0F07), Color(0xFF120803)],
  );

  static const LinearGradient parchmentGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF9F3E5), Color(0xFFF4ECD8), Color(0xFFECE1C6), Color(0xFFE5D5B3)],
    stops: [0.0, 0.25, 0.75, 1.0],
  );

  static const LinearGradient goldPlateGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDE8A5),
      Color(0xFFD4AF37),
      Color(0xFFB58E29),
      Color(0xFF785B17),
      Color(0xFFE4C66C),
    ],
    stops: [0.0, 0.28, 0.55, 0.85, 1.0],
  );

  // Shadows
  static List<BoxShadow> ledgerDepthShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.65),
      blurRadius: 18,
      spreadRadius: 2,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> plateShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.5),
      blurRadius: 12,
      spreadRadius: 1,
      offset: const Offset(0, 5),
    ),
  ];

  // Font styling using serif editorial family
  static const TextStyle goldHeadingStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: goldFoil,
    shadows: [
      Shadow(
        color: Colors.black87,
        offset: Offset(1, 1),
        blurRadius: 2,
      ),
    ],
  );

  static const TextStyle ledgerSubheadingStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 13,
    letterSpacing: 2.2,
    fontWeight: FontWeight.w600,
    color: Color(0xFFD9BF8F),
  );

  static const TextStyle parchmentBodyStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 16,
    height: 1.68,
    color: charcoalInk,
    letterSpacing: 0.2,
  );

  static const TextStyle questionStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 16,
    height: 1.55,
    fontWeight: FontWeight.w700,
    color: interrogatorRed,
    letterSpacing: 0.1,
  );

  static const TextStyle answerStyle = TextStyle(
    fontFamily: 'serif',
    fontSize: 16,
    height: 1.68,
    fontWeight: FontWeight.normal,
    color: charcoalInk,
    letterSpacing: 0.15,
  );
}
