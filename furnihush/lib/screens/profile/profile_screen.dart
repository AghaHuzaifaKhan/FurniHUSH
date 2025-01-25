import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furnihush/providers/cart_provider.dart';
import 'package:furnihush/providers/user_provider.dart';
import 'package:furnihush/screens/auth/login_screen.dart';
import 'package:furnihush/screens/profile/orders_screen.dart';
import 'package:furnihush/screens/profile/wishlist_screen.dart';
import 'package:furnihush/screens/profile/address_screen.dart';
import 'package:furnihush/screens/profile/payment_screen.dart';
import 'package:furnihush/screens/profile/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final orders = context.watch<UserProvider>().orders;
    final wishlist = context.watch<UserProvider>().wishlist;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Header
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.amber.shade100,
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.black54,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            // Profile Options
            _buildProfileOption(
              context,
              icon: Icons.shopping_bag,
              title: 'My Orders',
              subtitle: '${orders.length} orders',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrdersScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              context,
              icon: Icons.favorite,
              title: 'Wishlist',
              subtitle: '${wishlist.length} items',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WishlistScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              context,
              icon: Icons.location_on,
              title: 'Shipping Address',
              subtitle: user.address ?? 'Add address',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              context,
              icon: Icons.payment,
              title: 'Payment Methods',
              subtitle: '${user.paymentMethods.length} cards saved',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PaymentScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              context,
              icon: Icons.settings,
              title: 'Settings',
              subtitle: 'Edit profile details',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sign Out Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<CartProvider>().clear();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red.shade900,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
