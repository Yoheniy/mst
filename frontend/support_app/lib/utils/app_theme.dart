// // // lib/utils/app_theme.dart
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';

// // class AppTheme {
// //   // Define your brand colors
// //   static const Color primaryColor = Color(0xFF1F2937); // Deep Dark Grey (Stealth-like)
// //   static const Color accentColor = Color(0xFF2563EB); // Modern Blue
// //   static const Color lightBackgroundColor = Color(0xFFF8FAFC); // Off-white
// //   static const Color darkTextColor = Color(0xFF374151); // Darker text
// //   static const Color greyTextColor = Color(0xFF6B7280); // Grey text

// //   static final ThemeData lightTheme = ThemeData(
// //     brightness: Brightness.light,
// //     scaffoldBackgroundColor: lightBackgroundColor,
// //     primaryColor: primaryColor,
// //     colorScheme: const ColorScheme.light(
// //       primary: primaryColor,
// //       secondary: accentColor,
// //       surface: Colors.white,
// //       onSurface: darkTextColor,
// //     ),
// //     appBarTheme: const AppBarTheme(
// //       backgroundColor: primaryColor,
// //       foregroundColor: Colors.white,
// //       elevation: 0,
// //       centerTitle: true,
// //       titleTextStyle: TextStyle(
// //         fontSize: 20,
// //         fontWeight: FontWeight.bold,
// //         color: Colors.white,
// //       ),
// //     ),
// //     cardTheme: CardThemeData(
// //       color: Colors.white,
// //       elevation: 6,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(16),
// //       ),
// //     ),
// //     inputDecorationTheme: InputDecorationTheme(
// //       filled: true,
// //       fillColor: Colors.white,
// //       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
// //       border: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         borderSide: BorderSide.none,
// //       ),
// //       enabledBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         borderSide: BorderSide.none,
// //       ),
// //       focusedBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         borderSide: BorderSide(color: accentColor, width: 2),
// //       ),
// //       errorBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         borderSide: const BorderSide(color: Colors.red, width: 2),
// //       ),
// //       focusedErrorBorder: OutlineInputBorder(
// //         borderRadius: BorderRadius.circular(12),
// //         borderSide: const BorderSide(color: Colors.red, width: 2),
// //       ),
// //       hintStyle: GoogleFonts.inter(color: greyTextColor.withOpacity(0.7)),
// //       labelStyle: GoogleFonts.inter(color: greyTextColor),
// //     ),
// //     elevatedButtonTheme: ElevatedButtonThemeData(
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: accentColor,
// //         foregroundColor: Colors.white,
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
// //         textStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
// //         elevation: 2,
// //       ),
// //     ),
// //     textButtonTheme: TextButtonThemeData(
// //       style: TextButton.styleFrom(
// //         foregroundColor: accentColor,
// //         textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
// //       ),
// //     ),
// //     textTheme: TextTheme(
// //       displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.bold, color: darkTextColor),
// //       displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.bold, color: darkTextColor),
// //       displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: darkTextColor),
// //       headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: darkTextColor),
// //       headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: darkTextColor),
// //       headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: darkTextColor),
// //       titleLarge: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextColor),
// //       titleMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: darkTextColor),
// //       titleSmall: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: darkTextColor),
// //       bodyLarge: GoogleFonts.inter(fontSize: 16, color: darkTextColor),
// //       bodyMedium: GoogleFonts.inter(fontSize: 14, color: darkTextColor),
// //       bodySmall: GoogleFonts.inter(fontSize: 12, color: greyTextColor),
// //       labelLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
// //       labelMedium: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: greyTextColor),
// //       labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: greyTextColor),
// //     ),
// //   );
// // }

// // lib/utils/app_theme.dart
// import 'package:flutter/material.dart';

// class AppTheme {
//   // Define your brand colors based on the attached images (Dark/Green)
//   static const Color primaryDarkBackground = Color(0xFF171717); // Almost black
//   static const Color secondaryDarkBackground =
//       Color(0xFF242424); // Slightly lighter for cards/inputs
//   static const Color accentGreenPrimary =
//       Color(0xFF00FF00); // Vibrant Green (start of gradient)
//   static const Color accentGreenSecondary =
//       Color(0xFF00C853); // Darker Green (end of gradient)
//   static const Color lightTextColor = Color(0xFFFFFFFF); // White text
//   static const Color greyTextColor = Color(0xFFB0B0B0); // Light grey text
//   static const Color subtleGreenIcon =
//       Color(0xFF69F0AE); // Lighter green for icons/accents

//   // Custom text styles using Flutter's built-in system fonts
//   static const TextStyle _poppinsStyle = TextStyle(
//     fontFamily:
//         'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
//     fontWeight: FontWeight.normal,
//   );

//   static const TextStyle _interStyle = TextStyle(
//     fontFamily:
//         'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
//     fontWeight: FontWeight.normal,
//   );

//   static final ThemeData lightTheme = ThemeData(
//     // We are overriding 'light' theme with dark aesthetics
//     brightness: Brightness.dark, // Set brightness to dark
//     scaffoldBackgroundColor: primaryDarkBackground, // Main background
//     primaryColor: primaryDarkBackground, // Primary color for the app
//     fontFamily:
//         'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif', // Use system fonts to prevent external loading
//     colorScheme: ColorScheme.dark(
//       // Use dark ColorScheme
//       primary: primaryDarkBackground,
//       secondary: accentGreenPrimary, // Use green as secondary accent
//       surface: secondaryDarkBackground, // Cards and input fields background
//       onSurface: lightTextColor, // Text color on surfaces
//       background: primaryDarkBackground, // Background for the whole app
//       onBackground: lightTextColor, // Text color on background
//       error: Colors.redAccent, // Error color
//       onError: lightTextColor,
//     ),
//     appBarTheme: AppBarTheme(
//       // Custom app bar for the main app (not auth pages)
//       backgroundColor: primaryDarkBackground,
//       foregroundColor: lightTextColor,
//       elevation: 0,
//       centerTitle: true,
//       titleTextStyle: _poppinsStyle.copyWith(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: lightTextColor,
//       ),
//     ),
//     cardTheme: CardThemeData(
//       color: secondaryDarkBackground, // Card background color
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20), // More rounded corners
//       ),
//     ),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: secondaryDarkBackground, // Input field background
//       contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12), // Rounded input borders
//         borderSide: BorderSide.none, // No border, rely on fill color/shadow
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(
//             color: accentGreenPrimary, width: 2), // Green border when focused
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: Colors.redAccent, width: 2),
//       ),
//       hintStyle: _interStyle.copyWith(color: greyTextColor.withOpacity(0.7)),
//       labelStyle: _interStyle.copyWith(color: greyTextColor),
//       prefixIconColor: greyTextColor, // Default icon color
//       suffixIconColor: greyTextColor, // Default icon color
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         // Use a gradient for the button background
//         backgroundColor:
//             Colors.transparent, // Set to transparent to use gradient
//         shadowColor: accentGreenPrimary.withAlpha((255 * 0.5).round()),
//         elevation: 8,
//         foregroundColor: lightTextColor,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12), // Rounded buttons
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
//         textStyle:
//             _interStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
//       ).copyWith(
//         backgroundColor: MaterialStateProperty.resolveWith<Color>(
//           (Set<MaterialState> states) {
//             if (states.contains(MaterialState.disabled)) {
//               return Colors.grey.shade700; // Disabled color
//             }
//             return Colors.transparent; // Use transparent to allow gradient
//           },
//         ),
//       ),
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: accentGreenPrimary, // Green for links
//         textStyle:
//             _interStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
//       ),
//     ),
//     textTheme: TextTheme(
//       // Ensure all text colors contrast with dark background
//       displayLarge: _poppinsStyle.copyWith(
//           fontSize: 57, fontWeight: FontWeight.bold, color: lightTextColor),
//       displayMedium: _poppinsStyle.copyWith(
//           fontSize: 45, fontWeight: FontWeight.bold, color: lightTextColor),
//       displaySmall: _poppinsStyle.copyWith(
//           fontSize: 36, fontWeight: FontWeight.bold, color: lightTextColor),
//       headlineLarge: _poppinsStyle.copyWith(
//           fontSize: 32, fontWeight: FontWeight.bold, color: lightTextColor),
//       headlineMedium: _poppinsStyle.copyWith(
//           fontSize: 28, fontWeight: FontWeight.bold, color: lightTextColor),
//       headlineSmall: _poppinsStyle.copyWith(
//           fontSize: 24, fontWeight: FontWeight.bold, color: lightTextColor),
//       titleLarge: _interStyle.copyWith(
//           fontSize: 22, fontWeight: FontWeight.bold, color: lightTextColor),
//       titleMedium: _interStyle.copyWith(
//           fontSize: 18, fontWeight: FontWeight.w600, color: lightTextColor),
//       titleSmall: _interStyle.copyWith(
//           fontSize: 14, fontWeight: FontWeight.w600, color: lightTextColor),
//       bodyLarge: _interStyle.copyWith(fontSize: 16, color: lightTextColor),
//       bodyMedium: _interStyle.copyWith(fontSize: 14, color: lightTextColor),
//       bodySmall: _interStyle.copyWith(fontSize: 12, color: greyTextColor),
//       labelLarge: _interStyle.copyWith(
//           fontSize: 14, fontWeight: FontWeight.w600, color: lightTextColor),
//       labelMedium: _interStyle.copyWith(
//           fontSize: 12, fontWeight: FontWeight.w600, color: greyTextColor),
//       labelSmall: _interStyle.copyWith(
//           fontSize: 11, fontWeight: FontWeight.w500, color: greyTextColor),
//     ),
//     // Icon theme for global icon colors
//     iconTheme: const IconThemeData(color: greyTextColor),
//   );

//   // Helper methods for consistent text styling
//   static TextStyle poppins({
//     double? fontSize,
//     FontWeight? fontWeight,
//     Color? color,
//     double? height,
//     TextDecoration? decoration,
//   }) {
//     return _poppinsStyle.copyWith(
//       fontSize: fontSize,
//       fontWeight: fontWeight,
//       color: color,
//       height: height,
//       decoration: decoration,
//     );
//   }

//   static TextStyle inter({
//     double? fontSize,
//     FontWeight? fontWeight,
//     Color? color,
//     double? height,
//     TextDecoration? decoration,
//   }) {
//     return _interStyle.copyWith(
//       fontSize: fontSize,
//       fontWeight: fontWeight,
//       color: color,
//       height: height,
//       decoration: decoration,
//     );
//   }
// }



// lib/utils/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  // Define your brand colors based on the attached images (Dark/Green)
  static const Color primaryDarkBackground = Color(0xFF171717); // Almost black
  static const Color secondaryDarkBackground =
      Color(0xFF242424); // Slightly lighter for cards/inputs
  static const Color accentGreenPrimary =
      Color(0xFF00FF00); // Vibrant Green (start of gradient)
  static const Color accentGreenSecondary =
      Color(0xFF00C853); // Darker Green (end of gradient)
  static const Color lightTextColor = Color(0xFFFFFFFF); // White text
  static const Color greyTextColor = Color(0xFFB0B0B0); // Light grey text
  static const Color subtleGreenIcon =
      Color(0xFF69F0AE); // Lighter green for icons/accents

  // Use bundled custom fonts
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Inter', // Default to Inter
    fontWeight: FontWeight.normal,
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: primaryDarkBackground,
    primaryColor: primaryDarkBackground,
    fontFamily: 'Inter', // Default font family
    colorScheme: ColorScheme.dark(
      primary: primaryDarkBackground,
      secondary: accentGreenPrimary,
      surface: secondaryDarkBackground,
      onSurface: lightTextColor,
      background: primaryDarkBackground,
      onBackground: lightTextColor,
      error: Colors.redAccent,
      onError: lightTextColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryDarkBackground,
      foregroundColor: lightTextColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: lightTextColor,
      ),
    ),
    cardTheme: CardThemeData(
      color: secondaryDarkBackground,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: secondaryDarkBackground,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: accentGreenPrimary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      hintStyle: _baseTextStyle.copyWith(color: greyTextColor.withOpacity(0.7)),
      labelStyle: _baseTextStyle.copyWith(color: greyTextColor),
      prefixIconColor: greyTextColor,
      suffixIconColor: greyTextColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: accentGreenPrimary.withAlpha((255 * 0.5).round()),
        elevation: 8,
        foregroundColor: lightTextColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        textStyle: _baseTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.disabled)) {
              return Colors.grey.shade700;
            }
            return Colors.transparent;
          },
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentGreenPrimary,
        textStyle: _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: _baseTextStyle.copyWith(
          fontSize: 57, fontWeight: FontWeight.bold, color: lightTextColor),
      displayMedium: _baseTextStyle.copyWith(
          fontSize: 45, fontWeight: FontWeight.bold, color: lightTextColor),
      displaySmall: _baseTextStyle.copyWith(
          fontSize: 36, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineLarge: _baseTextStyle.copyWith(
          fontSize: 32, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineMedium: _baseTextStyle.copyWith(
          fontSize: 28, fontWeight: FontWeight.bold, color: lightTextColor),
      headlineSmall: _baseTextStyle.copyWith(
          fontSize: 24, fontWeight: FontWeight.bold, color: lightTextColor),
      titleLarge: _baseTextStyle.copyWith(
          fontSize: 22, fontWeight: FontWeight.bold, color: lightTextColor),
      titleMedium: _baseTextStyle.copyWith(
          fontSize: 18, fontWeight: FontWeight.w600, color: lightTextColor),
      titleSmall: _baseTextStyle.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: lightTextColor),
      bodyLarge: _baseTextStyle.copyWith(fontSize: 16, color: lightTextColor),
      bodyMedium: _baseTextStyle.copyWith(fontSize: 14, color: lightTextColor),
      bodySmall: _baseTextStyle.copyWith(fontSize: 12, color: greyTextColor),
      labelLarge: _baseTextStyle.copyWith(
          fontSize: 14, fontWeight: FontWeight.w600, color: lightTextColor),
      labelMedium: _baseTextStyle.copyWith(
          fontSize: 12, fontWeight: FontWeight.w600, color: greyTextColor),
      labelSmall: _baseTextStyle.copyWith(
          fontSize: 11, fontWeight: FontWeight.w500, color: greyTextColor),
    ),
    iconTheme: const IconThemeData(color: greyTextColor),
  );

  // Helper methods for consistent text styling
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return _baseTextStyle.copyWith(
      fontFamily: 'Poppins', // Use Poppins font family
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return _baseTextStyle.copyWith(
      fontFamily: 'Inter', // Use Inter font family
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      decoration: decoration,
    );
  }
}