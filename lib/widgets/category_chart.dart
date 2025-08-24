// widgets/category_chart.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class CategoryChart extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  const CategoryChart({super.key, required this.categoryData});

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Color> get expenseColors => [
    const Color(0xFFE74C3C), // Red
    const Color(0xFF3498DB), // Blue
    const Color(0xFF9B59B6), // Purple
    const Color(0xFFE67E22), // Orange
    const Color(0xFF1ABC9C), // Teal
    const Color(0xFFF39C12), // Yellow-Orange
    const Color(0xFF34495E), // Dark Gray
    const Color(0xFF95A5A6), // Light Gray
    const Color(0xFF8E44AD), // Violet
    const Color(0xFF16A085), // Dark Teal
  ];

  List<Color> get incomeColors => [
    const Color(0xFF27AE60), // Green
    const Color(0xFF2ECC71), // Light Green
    const Color(0xFF58D68D), // Lighter Green
    const Color(0xFF82E0AA), // Very Light Green
    const Color(0xFF52BE80), // Medium Green
  ];

  Widget _buildPieChart(
    List<dynamic> categories,
    List<Color> colors,
    String type,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No $type data available',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sections: categories.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percentage = double.parse(
                  category['percentage'].toString(),
                );

                return PieChartSectionData(
                  value: percentage,
                  title: '${percentage.toStringAsFixed(1)}%',
                  color: colors[index % colors.length],
                  radius: 60,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              centerSpaceRadius: 40,
              sectionsSpace: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Category Legend
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors[index % colors.length].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors[index % colors.length].withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(category['name'], style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(
                    '₹${category['amount']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBarChart(
    List<dynamic> categories,
    List<Color> colors,
    String type,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'No $type data available',
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }

    // Sort categories by amount for better visualization
    final sortedCategories = List<dynamic>.from(categories);
    sortedCategories.sort(
      (a, b) => (b['amount'] ?? 0).compareTo(a['amount'] ?? 0),
    );

    final maxAmount = sortedCategories.isNotEmpty
        ? (sortedCategories.first['amount'] ?? 0).toDouble()
        : 0.0;

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxAmount * 1.1,
          barGroups: sortedCategories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: (category['amount'] ?? 0).toDouble(),
                  color: colors[index % colors.length],
                  width: 24,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < sortedCategories.length) {
                    final categoryName = sortedCategories[index]['name']
                        .toString();
                    // Truncate long category names
                    final displayName = categoryName.length > 8
                        ? '${categoryName.substring(0, 8)}...'
                        : categoryName;

                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Transform.rotate(
                        angle: -0.5, // Slight rotation for better readability
                        child: Text(
                          displayName,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
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

                  if (value >= 1000) {
                    return Text(
                      '₹${(value / 1000).toStringAsFixed(0)}K',
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return Text(
                    '₹${value.toStringAsFixed(0)}',
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
            horizontalInterval: maxAmount / 5,
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
                final category = sortedCategories[group.x];
                return BarTooltipItem(
                  '${category['name']}\n₹${rod.toY.toStringAsFixed(0)}\n${category['count']} transactions',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenseCategories =
        widget.categoryData['expenses']?['categories'] ?? [];
    final incomeCategories = widget.categoryData['income']?['categories'] ?? [];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Color(0xFF667eea)),
                SizedBox(width: 8),
                Text(
                  'Category Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF667eea),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF667eea),
              tabs: const [
                Tab(text: 'Expenses'),
                Tab(text: 'Income'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Expenses Tab
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPieChart(
                          expenseCategories,
                          expenseColors,
                          'expense',
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        _buildBarChart(
                          expenseCategories,
                          expenseColors,
                          'expense',
                        ),
                      ],
                    ),
                  ),
                  // Income Tab
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPieChart(
                          incomeCategories,
                          incomeColors,
                          'income',
                        ),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),
                        _buildBarChart(
                          incomeCategories,
                          incomeColors,
                          'income',
                        ),
                      ],
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
}
