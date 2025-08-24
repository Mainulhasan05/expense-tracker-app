// screens/dashboard_screen.dart
import 'package:expense_tracker/screens/add_traansaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/financial_chart.dart';
import '../widgets/monthly_trend_chart.dart';
import '../widgets/category_chart.dart';
import 'add_traansaction_screen.dart';
import 'categories_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? dashboardData;
  List<dynamic>? monthlyTrends;
  Map<String, dynamic>? categoryData;
  bool isLoading = true;
  late AnimationController _animationController;

  // Month selection variables
  DateTime selectedMonth = DateTime.now();
  List<DateTime> availableMonths = [];
  static const String _selectedMonthKey = 'selected_month';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _generateAvailableMonths();
    _loadSelectedMonth();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateAvailableMonths() {
    final now = DateTime.now();
    availableMonths.clear();

    for (int i = 0; i < 12; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      availableMonths.add(month);
    }
  }

  Future<void> _loadSelectedMonth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMonth = prefs.getString(_selectedMonthKey);

      if (savedMonth != null) {
        final parsedDate = DateTime.parse(savedMonth);
        setState(() {
          selectedMonth = parsedDate;
        });
      }
    } catch (e) {
      print('Error loading selected month: $e');
    }

    loadDashboardData();
  }

  Future<void> _saveSelectedMonth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedMonthKey, selectedMonth.toIso8601String());
    } catch (e) {
      print('Error saving selected month: $e');
    }
  }

  String _formatMonthForAPI(DateTime month) {
    return DateFormat('MMMM yyyy').format(month);
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    final monthString = _formatMonthForAPI(selectedMonth);
    final data = await ApiService.getDashboardData(monthString);
    final trends = await ApiService.getMonthlyTrends();
    final categories = await ApiService.getCategoryData(monthString);

    setState(() {
      dashboardData = data;
      monthlyTrends = trends;
      categoryData = categories;
      isLoading = false;
    });

    _animationController.forward();
  }

  Future<void> _handleSignOut() async {
    await AuthService.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showMonthSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              'Select Month',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: availableMonths.length,
                itemBuilder: (context, index) {
                  final month = availableMonths[index];
                  final isSelected =
                      month.month == selectedMonth.month &&
                      month.year == selectedMonth.year;

                  return ListTile(
                    title: Text(
                      DateFormat('MMMM yyyy').format(month),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected ? const Color(0xFF667eea) : null,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: Color(0xFF667eea))
                        : null,
                    onTap: () {
                      setState(() {
                        selectedMonth = month;
                      });
                      _saveSelectedMonth();
                      Navigator.pop(context);
                      loadDashboardData();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: _showMonthSelector,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_month,
                color: Color(0xFF667eea),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM yyyy').format(selectedMonth),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF667eea),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadDashboardData,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'categories',
                child: Row(
                  children: [
                    Icon(Icons.category),
                    SizedBox(width: 8),
                    Text('Categories'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'categories') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoriesScreen(),
                  ),
                );
              } else if (value == 'signout') {
                _handleSignOut();
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _animationController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Selector
                      Center(child: _buildMonthSelector()),

                      const SizedBox(height: 16),

                      // Balance Cards
                      if (dashboardData != null)
                        BalanceCard(
                          totalIncome:
                              dashboardData!['income']?.toDouble() ?? 0,
                          totalExpense:
                              dashboardData!['expense']?.toDouble() ?? 0,
                        ),

                      const SizedBox(height: 24),

                      // Financial Overview Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.pie_chart,
                                    color: Color(0xFF667eea),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Financial Overview - ${DateFormat('MMM yyyy').format(selectedMonth)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (dashboardData != null)
                                FinancialChart(
                                  income:
                                      dashboardData!['income']?.toDouble() ?? 0,
                                  expense:
                                      dashboardData!['expense']?.toDouble() ??
                                      0,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Category Breakdown Chart
                      if (categoryData != null)
                        CategoryChart(categoryData: categoryData!),

                      const SizedBox(height: 24),

                      // Monthly Trends Chart
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.trending_up,
                                    color: Color(0xFF667eea),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Monthly Trends',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (monthlyTrends != null)
                                MonthlyTrendChart(trends: monthlyTrends!),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          ).then((_) => loadDashboardData());
        },
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }
}
