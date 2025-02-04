import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:furniture_pred/config/app_config.dart';
import 'package:furniture_pred/widgets/sales_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static HomeScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<HomeScreenState>();
  }

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String _uploadStatus = "";
  List<double> predictions = [];
  bool _isLoading = false;
  String? _selectedFileName;
  List<ItemPrediction> _itemPredictions = [];

  List<ItemPrediction> get itemPredictions => _itemPredictions;

  Future<void> uploadCsv() async {
    http.MultipartRequest? request;
    final completer = Completer<void>();

    try {
      setState(() {
        _isLoading = true;
        _uploadStatus = "Selecting file...";
        predictions = [];
      });

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
        withReadStream: true,
      );

      if (result == null) {
        _updateStatus("No file selected");
        return;
      }

      final file = result.files.single;
      final fileSize = file.size / (1024 * 1024);

      if (fileSize > 16) {
        _updateStatus("Error: File size exceeds 16MB limit");
        return;
      }

      _updateStatus("Uploading file (${fileSize.toStringAsFixed(2)}MB)...");

      request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.serverUrl}/upload'),
      );

      request.files.add(
        http.MultipartFile(
          'file',
          file.readStream!,
          file.size,
          filename: file.name,
        ),
      );

      final response = await request.send().timeout(
            const Duration(minutes: 2),
            onTimeout: () => throw TimeoutException('Upload timed out'),
          );

      final responseData = await response.stream.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);

        if (data['items'] != null && data['items'] is List) {
          final itemPredictions = (data['items'] as List)
              .map((item) => ItemPrediction(
                    item['name'] as String,
                    item['predicted_sales'] as double,
                  ))
              .toList();

          setState(() {
            _itemPredictions = itemPredictions;
            predictions =
                itemPredictions.map((ip) => ip.predictedSales).toList();
          });
        }
      } else {
        throw HttpException(responseData);
      }
    } on TimeoutException {
      _updateStatus("Error: Upload timed out. Please try again.");
    } on SocketException catch (e) {
      _updateStatus("Network Error: ${e.message}");
    } on FormatException {
      _updateStatus("Error: Invalid response from server");
    } catch (e) {
      _updateStatus("Error: ${e.toString()}");
    } finally {
      request?.files.clear();
      setState(() => _isLoading = false);
      completer.complete();
    }

    return completer.future;
  }

  void _updateStatus(String status) {
    setState(() => _uploadStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Prediction"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.pushNamed(context, '/admin'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        "Upload CSV File",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedFileName != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Text(
                            "Selected file: $_selectedFileName",
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : uploadCsv,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(_isLoading
                            ? 'Processing...'
                            : 'Select and Upload CSV'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_uploadStatus.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    _uploadStatus,
                    style: TextStyle(
                      color: _uploadStatus.toLowerCase().contains('error')
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (_itemPredictions.isNotEmpty) ...[
                SalesChart(items: _itemPredictions),
                const SizedBox(height: 16),
                _buildPredictionSummary(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPredictionSummary() {
    if (_itemPredictions.isEmpty) return const SizedBox.shrink();

    final predictions =
        _itemPredictions.map((ip) => ip.predictedSales).toList();
    final average = predictions.reduce((a, b) => a + b) / predictions.length;
    final max = predictions.reduce((a, b) => a > b ? a : b);
    final min = predictions.reduce((a, b) => a < b ? a : b);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Prediction Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow("Average Sales", average.toStringAsFixed(2)),
            _buildSummaryRow("Highest Prediction", max.toStringAsFixed(2)),
            _buildSummaryRow("Lowest Prediction", min.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ItemPrediction {
  final String itemName;
  final double predictedSales;

  ItemPrediction(this.itemName, this.predictedSales);
}
