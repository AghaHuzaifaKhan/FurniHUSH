import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ARViewScreen extends StatefulWidget {
  final String modelUrl;
  final String productName;

  const ARViewScreen({
    super.key,
    required this.modelUrl,
    required this.productName,
  });

  static Future<void> checkARAvailability(BuildContext context) async {
    try {
      bool available = await ArCoreController.checkArCoreAvailability();
      bool installed = await ArCoreController.checkIsArCoreInstalled();

      if (!available || !installed) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('AR Not Available'),
            content: const Text('Please install Google Play Services for AR'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint('AR Error: $e');
    }
  }

  @override
  ARViewScreenState createState() => ARViewScreenState();
}

class ARViewScreenState extends State<ARViewScreen>
    with WidgetsBindingObserver {
  ArCoreController? arCoreController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    arCoreController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      arCoreController?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View ${widget.productName} in AR'),
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          else
            ArCoreView(
              onArCoreViewCreated: _onArCoreViewCreated,
              enableTapRecognizer: true,
              debug: true,
            ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Initializing AR...\nPlease move your device slowly',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    try {
      arCoreController = controller;
      arCoreController?.onPlaneTap = _handleOnPlaneTap;
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize AR: $e';
        _isLoading = false;
      });
      debugPrint('AR Error: $e');
    }
  }

  void _handleOnPlaneTap(List<ArCoreHitTestResult> hits) {
    try {
      final hit = hits.first;
      _addModel(hit);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error placing model: $e')),
      );
    }
  }

  Future<void> _addModel(ArCoreHitTestResult hit) async {
    try {
      setState(() => _isLoading = true);
      final node = ArCoreReferenceNode(
        name: widget.productName,
        objectUrl: widget.modelUrl,
        position: hit.pose.translation,
        rotation: hit.pose.rotation,
        scale: vector.Vector3(0.5, 0.5, 0.5),
        object3DFileName: widget.modelUrl.startsWith('assets/')
            ? widget.modelUrl.split('/').last
            : null,
      );

      await arCoreController?.addArCoreNode(node);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading model: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
