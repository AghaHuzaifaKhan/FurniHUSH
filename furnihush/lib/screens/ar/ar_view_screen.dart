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

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  ArCoreController? arCoreController;

  @override
  void dispose() {
    arCoreController?.dispose();
    super.dispose();
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    arCoreController = controller;
    _addModel();
  }

  void _addModel() async {
    final node = ArCoreNode(
      shape: ArCoreCube(
        materials: [
          ArCoreMaterial(
            color: Colors.blue,
            metallic: 1.0,
          ),
        ],
        size: vector.Vector3(0.5, 0.5, 0.5),
      ),
      position: vector.Vector3(0, 0, -1.5),
    );

    arCoreController?.addArCoreNode(node);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AR View - ${widget.productName}'),
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableTapRecognizer: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () {
          // Add functionality to take screenshot
        },
      ),
    );
  }
}
