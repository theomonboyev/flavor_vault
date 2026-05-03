import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/recipe_provider.dart';
import 'providers/vault_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/main_screen.dart';

void main() {
  // App entry point. Using MultiProvider to inject our state management 
  // classes (Providers) at the top of the widget tree so they can be accessed anywhere.
  runApp(
    MultiProvider(
      providers: [
        // RecipeProvider handles fetching data from the API
        ChangeNotifierProvider(create: (_) => RecipeProvider()..fetchDefaultRecipes()),
        // VaultProvider handles our local SharedPreferences data
        ChangeNotifierProvider(create: (_) => VaultProvider()),
        // ThemeProvider handles light/dark mode switching
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const FlavorVaultApp(),
    ),
  );
}

class FlavorVaultApp extends StatelessWidget {
  const FlavorVaultApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Consumer listens to changes in ThemeProvider to rebuild the app when theme changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'FlavorVault',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepOrange,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            useMaterial3: true,
          ),
          home: const MainScreen(),
        );
      },
    );
  }
}
