import 'package:flutter/material.dart';
import 'package:furnihush/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _loadingController;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _loadingAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_loadingController);

    _loadingController.forward();
    navigateToLogin();
  }

  navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/applogo.png',
                    height: 100,
                    width: 100,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'FURNIHUSH. INC.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: 200,
                    child: AnimatedBuilder(
                      animation: _loadingAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _loadingAnimation.value,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.amber.shade700,
                          ),
                          minHeight: 2,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Image.asset(
                'assets/icons/splash_illustration.png',
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
