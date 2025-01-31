class ARModel {
  final String modelUrl;
  final double scale;
  final List<double> position;

  ARModel({
    required this.modelUrl,
    this.scale = 1.0,
    this.position = const [0, 0, -1.5],
  });
}
