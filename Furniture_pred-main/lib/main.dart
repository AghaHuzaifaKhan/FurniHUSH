import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:furniture_pred/screens/auth/auth_wrapper.dart';
import 'package:furniture_pred/screens/auth/home_screen.dart';
import 'package:furniture_pred/screens/auth/login_screen.dart';
import 'package:furniture_pred/screens/auth/signup_screen.dart';
import 'package:furniture_pred/screens/admin/admin_dashboard.dart';
import 'package:furniture_pred/screens/admin/manage_items_screen.dart';
import 'package:furniture_pred/screens/admin/stock_management_screen.dart';
import 'package:furniture_pred/screens/admin/price_management_screen.dart';
import 'package:furniture_pred/widgets/sales_chart.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Furniture Sales Prediction',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminDashboard(),
        '/admin/items': (context) => const ManageItemsScreen(),
        '/admin/stock': (context) => const StockManagementScreen(),
        '/admin/prices': (context) => const PriceManagementScreen(),
        '/admin/analytics': (context) => SalesChart(
              items: HomeScreen.of(context)?.itemPredictions ?? [],
            ),
      },
    );
  }
}


  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

 