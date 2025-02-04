import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furnihush/providers/user_provider.dart';
import 'package:furnihush/screens/auth/login_screen.dart';
import 'package:furnihush/screens/profile/orders_screen.dart';
import 'package:furnihush/screens/profile/wishlist_screen.dart';
import 'package:furnihush/screens/profile/payment_screen.dart';
import 'package:furnihush/screens/profile/settings_screen.dart';
import 'package:furnihush/controllers/auth_controller.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when screen loads
    context.read<UserProvider>().fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final userData = userProvider.userData;

          if (userData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Image.asset(
                //   'assets/icons/applogo.png',
                //   height: 80,
                //   width: 80,
                // ),
                const SizedBox(height: 20),
                // Profile Image
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.amber.shade100,
                      backgroundImage: userData['image'] != null &&
                              userData['image'].isNotEmpty
                          ? FileImage(File(userData['image']))
                          : null,
                      child:
                          userData['image'] == null || userData['image'].isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.black54)
                              : null,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // User Name
                Text(
                  userData['name'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // User Email
                Text(
                  userData['email'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                // Phone Number
                if (userData['phone'] != null && userData['phone'].isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(userData['phone']),
                  ),
                // Address
                if (userData['address'] != null &&
                    userData['address'].isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(userData['address']),
                  ),
                const Divider(),
                // Menu Items
                ListTile(
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: const Text('My Orders'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrdersScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: const Text('Wishlist'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WishlistScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Methods'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await context.read<AuthController>().signOut();
                        if (!mounted) return;

                        // Clear user data from provider
                        // ignore: use_build_context_synchronously
                        context.read<UserProvider>().clearUserData();

                        // Navigate to login screen
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false, // This removes all previous routes
                        );
                      } catch (e) {
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: $e')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
