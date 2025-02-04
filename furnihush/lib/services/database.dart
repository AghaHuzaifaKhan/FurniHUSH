import 'package:cloud_firestore/cloud_firestore.dart' as fs;

class Database {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;

  Future<void> initializeDummyData() async {
    // Categories
    final categories = [
      'Sofas',
      'Beds',
      'Tables',
      'Chairs',
      'Storage',
      'Lighting',
    ];

    // Sample Products
    final products = [
      {
        'name': 'Modern L-Shape Sofa',
        'price': 1299.99,
        'description':
            'Contemporary L-shaped sofa with premium fabric upholstery. Perfect for modern living rooms.',
        'images': [
          'assets/images/sofa1.jpg',
          'assets/images/sofa2.jpg',
        ],
        'category': 'Sofas',
        'arModelUrl': 'assets/models/sofa_3d.glb',
        'dimensions': {
          'width': 280,
          'height': 85,
          'depth': 180,
        },
        'isAvailable': true,
        'stock': 5,
        'features': [
          'Stain-resistant fabric',
          'High-density foam',
          'Solid wood frame',
        ],
        'colors': ['Grey', 'Blue', 'Beige'],
      },
      {
        'name': 'Queen Size Platform Bed',
        'price': 899.99,
        'description':
            'Modern platform bed with integrated storage and LED lighting.',
        'images': [
          'assets/images/bed1.jpg',
          'assets/images/bed2.jpg',
        ],
        'category': 'Beds',
        'arModelUrl': 'assets/models/bed_3d.glb',
        'dimensions': {
          'width': 160,
          'height': 100,
          'depth': 200,
        },
        'isAvailable': true,
        'stock': 8,
        'features': [
          'Under-bed storage',
          'LED headboard',
          'No box spring needed',
        ],
        'colors': ['Walnut', 'White', 'Black'],
      },
      {
        'name': 'Dining Table Set',
        'price': 799.99,
        'description':
            '6-seater dining table set with tempered glass top and comfortable chairs.',
        'images': [
          'assets/images/table1.jpg',
          'assets/images/table2.jpg',
        ],
        'category': 'Tables',
        'arModelUrl': 'assets/models/table_3d.glb',
        'dimensions': {
          'width': 180,
          'height': 75,
          'depth': 90,
        },
        'isAvailable': true,
        'stock': 3,
        'features': [
          'Tempered glass top',
          'Stainless steel base',
          'Includes 6 chairs',
        ],
        'colors': ['Clear/Silver'],
      },
    ];

    // Initialize Categories
    for (var category in categories) {
      await _firestore.collection('categories').add({
        'name': category,
        'createdAt': fs.Timestamp.now(),
      });
    }

    // Initialize Products
    for (var product in products) {
      await _firestore.collection('products').add({
        ...product,
        'createdAt': fs.Timestamp.now(),
        'updatedAt': fs.Timestamp.now(),
      });
    }

    // Sample Users
    await _firestore.collection('users').add({
      'name': 'John Doe',
      'email': 'john@example.com',
      'phone': '+1234567890',
      'address': '123 Main St, City, Country',
      'createdAt': fs.Timestamp.now(),
      'wishlist': [],
      'cart': [],
      'orders': [],
    });

    // Sample Orders
    await _firestore.collection('orders').add({
      'userId': 'dummy_user_id',
      'items': [
        {
          'productId': 'dummy_product_id',
          'name': 'Modern L-Shape Sofa',
          'price': 1299.99,
          'quantity': 1,
        }
      ],
      'total': 1299.99,
      'status': 'Processing',
      'createdAt': fs.Timestamp.now(),
      'shippingAddress': {
        'street': '123 Main St',
        'city': 'City',
        'state': 'State',
        'zipCode': '12345',
        'country': 'Country',
      },
      'paymentMethod': '**** **** **** 1234',
    });
  }

  // Call this method to initialize the database with dummy data
  Future<void> initialize() async {
    try {
      await initializeDummyData();
      print('Dummy data initialized successfully');
    } catch (e) {
      print('Error initializing dummy data: $e');
    }
  }
}
