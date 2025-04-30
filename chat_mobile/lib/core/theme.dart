import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontSize {
  static const small = 12.0;
  static const standard = 14.0;
  static const standardUp = 16.0;
  static const meduium = 20.0;
  static const large = 28.0;
}

class DefaultColors {
  static const Color greyText = Color(0xFF83B9C9);
  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color senderMessage = Color(0xFF7A8194);
  static const Color receiverMessage = Color(0xFF373E4E);
  static const Color sentMessageInput = Color(0xff3D4354);
  static const Color messageListPage = Color(0xFF292F3F);
  static const Color buttonColor = Color(0xFF7A8194);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFF1B202D),
      textTheme: TextTheme(
        titleMedium: GoogleFonts.alegreyaSans(
          fontSize: FontSize.meduium,
          color: DefaultColors.whiteText,
        ),
        titleLarge: GoogleFonts.alegreyaSans(
          fontSize: FontSize.large,
          color: DefaultColors.whiteText,
        ),
        bodySmall: TextStyle(
          fontSize: FontSize.standard,
          color: DefaultColors.whiteText,
        ),
        bodyMedium: TextStyle(
          fontSize: FontSize.standardUp,
          color: DefaultColors.whiteText,
        ),
        bodyLarge: TextStyle(
          fontSize: FontSize.standardUp,
          color: DefaultColors.whiteText,
        ),
      ),
    );
  }
}
