// widgets/financial_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class FinancialChart extends StatelessWidget {
  final double income;
  final double expense;

  const FinancialChart({
    super.key,
    required this.income,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expense;
    if (total == 0) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: income,
              color: Colors.green,
              title: 'Income\n${(income / total * 100).toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: expense,
              color: Colors.red,
              title: 'Expense\n${(expense / total * 100).toStringAsFixed(1)}%',
              radius: 80,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
          centerSpaceRadius: 0,
          sectionsSpace: 2,
        ),
      ),
    );
  }
}
