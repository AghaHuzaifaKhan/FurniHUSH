import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furnihush/providers/cart_provider.dart';
import 'package:furnihush/providers/user_provider.dart';
import 'package:furnihush/screens/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:furnihush/services/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize products (run this once)
  final db = DatabaseService();
  await db.initializeProducts();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'FurniHUSH',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          scaffoldBackgroundColor: Colors.amber.shade50,
          fontFamily: 'Poppins',
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.black;
              }
              return Colors.grey;
            }),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
