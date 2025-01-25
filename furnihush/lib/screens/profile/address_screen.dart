import 'package:flutter/material.dart';
import 'package:furnihush/consts/firebase_consts.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    try {
      final doc = await firestore
          .collection(usersCollection)
          .doc(currentUser?.uid)
          .get();
      if (doc.exists) {
        setState(() {
          _addressController.text = doc.data()?['address'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading address: $e');
    }
  }

  Future<void> _saveAddress() async {
    setState(() => _isLoading = true);
    try {
      await firestore
          .collection(usersCollection)
          .doc(currentUser?.uid)
          .update({'address': _addressController.text});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating address: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shipping Address')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Shipping Address',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Full Address',
                hintText: 'Enter your complete shipping address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Address'),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Standard Delivery',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Delivery within 3-5 business days'),
                    Text('• Free shipping on orders above \$500'),
                    Text('• Tracking number provided'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
