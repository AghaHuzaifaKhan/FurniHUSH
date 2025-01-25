import 'package:flutter/material.dart';
import 'package:furnihush/screens/category/product_detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Bedroom',
      'icon': Icons.bed,
      'images': [
        'assets/images/furniture/be1.jpeg',
        'assets/images/furniture/be2.jpeg',
        'assets/images/furniture/be3.jpeg',
        'assets/images/furniture/be4.jpeg',
        'assets/images/furniture/be5.jpeg',
        'assets/images/furniture/be6.jpeg',
      ],
    },
    {
      'name': 'Living Room',
      'icon': Icons.weekend,
      'images': [
        'assets/images/furniture/sa1.jpeg',
        'assets/images/furniture/sa2.jpeg',
        'assets/images/furniture/sa3.jpeg',
        'assets/images/furniture/sa4.jpeg',
        'assets/images/furniture/sa5.jpeg',
        'assets/images/furniture/sa6.jpeg',
      ],
    },
    {
      'name': 'Office',
      'icon': Icons.chair,
      'images': [
        'assets/images/furniture/ca1.jpeg',
        'assets/images/furniture/ca2.jpeg',
        'assets/images/furniture/ca3.jpeg',
        'assets/images/furniture/ca4.jpeg',
        'assets/images/furniture/ca5.jpeg',
        'assets/images/furniture/ca6.jpeg',
      ],
    },
    {
      'name': 'Dining',
      'icon': Icons.table_restaurant,
      'images': [
        'assets/images/furniture/ta1.jpeg',
        'assets/images/furniture/ta2.jpeg',
        'assets/images/furniture/ta3.jpeg',
        'assets/images/furniture/ta4.jpeg',
        'assets/images/furniture/ta5.jpeg',
        'assets/images/furniture/ta6.jpeg',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            // Navigate to category products
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CategoryProductsSheet(category: category),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(category['images'][0]),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withAlpha(102),
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'],
                    size: 40,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoryProductsSheet extends StatelessWidget {
  final Map<String, dynamic> category;

  const CategoryProductsSheet({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${category['name']} Collection',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: category['images'].length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              productId: index,
                              name: '${category['name']} Item ${index + 1}',
                              price: (index + 1) * 100.0,
                              images: [category['images'][index]],
                              description:
                                  'Detailed description for ${category['name']} Item ${index + 1}',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  image: DecorationImage(
                                    image:
                                        AssetImage(category['images'][index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${category['name']} Item ${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(index + 1) * 100}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
