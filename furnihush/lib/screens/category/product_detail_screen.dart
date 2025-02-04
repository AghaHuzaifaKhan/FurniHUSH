import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:furnihush/providers/cart_provider.dart';
import 'package:furnihush/screens/ar/ar_view_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String? name;
  final double? price;
  final String? description;
  final List<String>? images;
  final String productId;
  final String? arModelUrl;

  const ProductDetailScreen({
    super.key,
    this.name,
    this.price,
    this.description,
    this.images,
    required this.productId,
    this.arModelUrl,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> productImages = widget.images ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemCount: productImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          image: DecorationImage(
                            image: AssetImage(productImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  if (productImages.isNotEmpty)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          productImages.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name ?? 'Product Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.price?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (productImages.length > 1) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Swipe to see more images',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ARViewScreen.checkARAvailability(context);
                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ARViewScreen(
                        modelUrl: widget.arModelUrl ?? 'assets/icons/sofa.glb',
                        productName: widget.name ?? 'sofa',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.view_in_ar),
                label: const Text('View in AR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<CartProvider>().addItem(
                        id: widget.productId,
                        name: widget.name ?? 'Unknown Product',
                        price: widget.price ?? 0.0,
                        image: widget.images?.first ?? '',
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart')),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
