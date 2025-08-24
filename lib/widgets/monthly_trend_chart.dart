// widgets/monthly_trend_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class MonthlyTrendChart extends StatelessWidget {
  final List<dynamic> trends;

  const MonthlyTrendChart({super.key, required this.trends});

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

    // Calculate the maximum value from both income and expenses for proper scaling
    double maxValue = 0;
    for (var trend in trends) {
      final income = (trend['income'] ?? 0).toDouble();
      final expenses = (trend['expenses'] ?? 0).toDouble();
      maxValue = max(maxValue, max(income, expenses));
    }

    return Column(
      children: [
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text('Income', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text('Expenses', style: TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * 1.2, // Add 20% padding to the top
              barGroups: trends.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;

                return BarChartGroupData(
                  x: index,
                  groupVertically: false,
                  barRods: [
                    // Income bar
                    BarChartRodData(
                      toY: (data['income'] ?? 0).toDouble(),
                      color: Colors.green,
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                    // Expenses bar
                    BarChartRodData(
                      toY: (data['expenses'] ?? 0).toDouble(),
                      color: Colors.red,
                      width: 12,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ],
                  barsSpace: 4, // Space between income and expense bars
                );
              }).toList(),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < trends.length) {
                        // Extract first 3 characters of month name
                        final monthName = trends[index]['name'].toString();
                        final shortName = monthName.length >= 3
                            ? monthName.substring(0, 3)
                            : monthName;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            shortName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) return const Text('0');

                      // Format large numbers (e.g., 50000 -> 50K)
                      if (value >= 1000) {
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}K',
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                drawVerticalLine: false,
                horizontalInterval: maxValue / 5, // Show 5 grid lines
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.3),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  // tooltipBgColor: Colors.black87,
                  // tooltipRoundedRadius: 8,
                  tooltipPadding: const EdgeInsets.all(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final data = trends[group.x];
                    final monthName = data['name'].toString();

                    if (rodIndex == 0) {
                      // Income tooltip
                      return BarTooltipItem(
                        '$monthName\nIncome: ₹${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    } else {
                      // Expenses tooltip
                      return BarTooltipItem(
                        '$monthName\nExpenses: ₹${rod.toY.toStringAsFixed(0)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
