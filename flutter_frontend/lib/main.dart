import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/chat_provider.dart';

void main() {
  runApp(const StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: 'StudyBuddy AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.interTextTheme(),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
