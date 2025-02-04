import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:furniture_pred/screens/auth/home_screen.dart'; // Adjust path if needed

class SalesChart extends StatelessWidget {
  final List<ItemPrediction> items;
  final double height;

  const SalesChart({
    super.key,
    required this.items,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final trend = _calculateTrend();
    final trendIcon = trend > 0.05
        ? Icons.trending_up
        : trend < -0.05
            ? Icons.trending_down
            : Icons.trending_flat;
    final trendColor = trend > 0.05
        ? Colors.green
        : trend < -0.05
            ? Colors.red
            : Colors.orange;

    return Column(
      children: [
        // Chart Section
        Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sales Prediction Analysis',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: trendColor.withValues(),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(trendIcon, color: trendColor),
                          const SizedBox(width: 4),
                          Text(
                            '${(trend * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: trendColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Chart Container
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 10,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: Colors.grey.withValues(),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 60,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final int index = value.toInt();
                              if (index < 0 || index >= items.length) {
                                return const Text('');
                              }
                              return Transform.rotate(
                                angle: 45 * 3.1415927 / 180,
                                child: Text(
                                  items[index].itemName,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 42,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                            color: const Color(0xFF94A3B8), width: 1),
                      ),
                      minX: 0,
                      maxX: (items.length - 1).toDouble(),
                      minY: _getMinY(),
                      maxY: _getMaxY(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _createSpots(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).primaryColor,
                              Theme.of(context).primaryColor.withValues(),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).primaryColor.withValues(),
                                Theme.of(context).primaryColor.withValues(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Recommendations Section
        Card(
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.recommend, color: Color(0xFF334155)),
                    SizedBox(width: 8),
                    Text(
                      'Production Recommendations',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                // Top Items Section
                ...items.take(3).map((item) => _buildItemCard(item, context)),
                const SizedBox(height: 16),
                // Trend Advice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: trendColor.withValues()),
                  ),
                  child: Row(
                    children: [
                      Icon(trendIcon, color: trendColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getTrendAdvice(trend),
                          style: TextStyle(
                            color: trendColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(ItemPrediction item, BuildContext context) {
    final priority = _getPriority(item.predictedSales);
    final minStock = (item.predictedSales * 0.3).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.white,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getPriorityColor(priority).withValues(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                priority,
                style: TextStyle(
                  color: _getPriorityColor(priority),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Predicted: ${item.predictedSales.round()} units • Min Stock: $minStock units',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTrend() {
    if (items.length < 2) return 0;
    final firstHalf = items
            .sublist(0, items.length ~/ 2)
            .map((e) => e.predictedSales)
            .reduce((a, b) => a + b) /
        (items.length ~/ 2);
    final secondHalf = items
            .sublist(items.length ~/ 2)
            .map((e) => e.predictedSales)
            .reduce((a, b) => a + b) /
        (items.length - (items.length ~/ 2));
    return (secondHalf - firstHalf) / firstHalf;
  }

  String _getPriority(double predictedSales) {
    if (predictedSales > 100) return 'HIGH';
    if (predictedSales > 50) return 'MEDIUM';
    return 'LOW';
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getTrendAdvice(double trend) {
    if (trend > 0.05) {
      return 'Increasing demand trend. Consider increasing production by ${(trend * 100).toStringAsFixed(0)}%';
    } else if (trend < -0.05) {
      return 'Decreasing demand trend. Maintain minimum stock levels.';
    }
    return 'Stable demand trend. Maintain current production levels.';
  }

  double _getMinY() {
    if (items.isEmpty) return 0;
    double minY = double.infinity;
    for (var item in items) {
      if (item.predictedSales < minY) minY = item.predictedSales;
    }
    return (minY * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (items.isEmpty) return 100;
    double maxY = -double.infinity;
    for (var item in items) {
      if (item.predictedSales > maxY) maxY = item.predictedSales;
    }
    return (maxY * 1.1).ceilToDouble();
  }

  List<FlSpot> _createSpots() {
    return List.generate(items.length, (index) {
      return FlSpot(index.toDouble(), items[index].predictedSales);
    });
  }
}
