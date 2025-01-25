import 'package:flutter/material.dart';
import 'package:furnihush/screens/cart/cart_screen.dart';
import 'package:furnihush/screens/category/category_screen.dart';
import 'package:furnihush/screens/category/product_detail_screen.dart';
import 'package:furnihush/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FurniHUSH'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  final List<Map<String, dynamic>> newArrivals = const [
    {
      'name': 'Modern Sofa',
      'description': 'Comfortable 3-seater sofa with premium fabric',
      'price': 899,
      'image': 'assets/images/furniture/sa1.jpeg',
    },
    {
      'name': 'Bedroom Set',
      'description': 'Complete bedroom set with modern design',
      'price': 1599,
      'image': 'assets/images/furniture/be1.jpeg',
    },
    {
      'name': 'Office Chair',
      'description': 'Ergonomic office chair with lumbar support',
      'price': 299,
      'image': 'assets/images/furniture/ca1.jpeg',
    },
    {
      'name': 'Coffee Table',
      'description': 'Contemporary coffee table with storage',
      'price': 399,
      'image': 'assets/images/furniture/ta1.jpeg',
    },
  ];

  final List<Map<String, dynamic>> hotDeals = const [
    {
      'name': 'Premium Sofa',
      'description': 'Luxury sofa with premium leather',
      'price': 1299,
      'originalPrice': 1599,
      'discount': '20% OFF',
      'image': 'assets/images/furniture/sa2.jpeg',
    },
    {
      'name': 'King Size Bed',
      'description': 'Modern bedroom set with storage',
      'price': 1899,
      'originalPrice': 2299,
      'discount': '30% OFF',
      'image': 'assets/images/furniture/be2.jpeg',
    },
    {
      'name': 'Executive Chair',
      'description': 'Premium office chair with massage',
      'price': 499,
      'originalPrice': 699,
      'discount': '40% OFF',
      'image': 'assets/images/furniture/ca2.jpeg',
    },
    {
      'name': 'Dining Set',
      'description': 'Modern 6-seater dining set',
      'price': 999,
      'originalPrice': 1099,
      'discount': '10% OFF',
      'image': 'assets/images/furniture/ta2.jpeg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New Arrivals Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'New Arrivals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: newArrivals.length,
              itemBuilder: (context, index) {
                final item = newArrivals[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: index,
                          name: item['name'],
                          price: item['price'].toDouble(),
                          images: [item['image']],
                          description: item['description'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 160,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              image: DecorationImage(
                                image: AssetImage(item['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.brown.withAlpha(204),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'NEW',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${item['price']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Hot Deals Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Hot Deals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: hotDeals.length,
            itemBuilder: (context, index) {
              final deal = hotDeals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(
                          productId: index,
                          name: deal['name'],
                          price: deal['price'].toDouble(),
                          images: [deal['image']],
                          description: deal['description'],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(12),
                          ),
                          image: DecorationImage(
                            image: AssetImage(deal['image']),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  deal['discount'],
                                  style: TextStyle(
                                    color: Colors.red[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                deal['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                deal['description'],
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    '\$${deal['price']}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${deal['originalPrice']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Categories Section
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Categories',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const CategoryScreen(),
        ],
      ),
    );
  }
}
