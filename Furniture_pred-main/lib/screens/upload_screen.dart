import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
// Add this import for File class

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _predictions = [];

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }

      final file = result.files.first;
      if (file.path == null) {
        throw 'File path is null';
      }

      // Create form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      // Make request
      final dio = Dio();
      final response = await dio.post(
        'http://10.0.2.2:5000/upload', // For Android emulator
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _predictions =
              List<Map<String, dynamic>>.from(response.data['items']);
        });
      }
    } catch (e) {
      setState(() {
        _error = e is DioException
            ? 'Connection error: Please check your internet connection'
            : 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Prediction'),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Upload CSV File',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickAndUploadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Select and Upload CSV'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[100],
                padding: const EdgeInsets.all(16),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
            if (_predictions.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Predictions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _predictions.length,
                  itemBuilder: (context, index) {
                    final item = _predictions[index];
                    return Card(
                      child: ListTile(
                        title: Text(item['name']),
                        subtitle: Text(
                          'Predicted Sales: ${item['predicted_sales']}',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
