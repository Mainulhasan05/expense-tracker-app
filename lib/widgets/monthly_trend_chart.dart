// widgets/monthly_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MonthlyTrendChart extends StatelessWidget {
  final List<dynamic> trends;

  const MonthlyTrendChart({
    super.key,
    required this.trends,
  });

  @override
  Widget build(BuildContext context) {
    if (trends.isEmpty) {
      return const Center(
        child: Text(
          'No trend data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: trends.map((e) => e['income'].toDouble()).reduce((a, b) => a > b ? a : b) * 1.2,
          barGroups: trends.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data['income'].toDouble(),
                  color: Colors.green,
                  width: 20,
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < trends.length) {
                    return Text(
                      trends[index]['month'].toString().substring(0, 3),
                      style: const TextStyle(fontSize: 12),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
