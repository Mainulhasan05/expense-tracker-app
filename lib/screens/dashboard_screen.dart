// screens/dashboard_screen.dart
import 'package:expense_tracker/screens/add_traansaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/balance_card.dart';
import '../widgets/financial_chart.dart';
import '../widgets/monthly_trend_chart.dart';
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
  bool isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    loadDashboardData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    final data = await ApiService.getDashboardData();
    final trends = await ApiService.getMonthlyTrends();

    setState(() {
      dashboardData = data;
      monthlyTrends = trends;
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
                      // Balance Cards
                      if (dashboardData != null)
                        BalanceCard(
                          totalIncome: dashboardData!['totalIncome']?.toDouble() ?? 0,
                          totalExpense: dashboardData!['totalExpense']?.toDouble() ?? 0,
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
                                    'Financial Overview - ${DateFormat('MMM yyyy').format(DateTime.now())}',
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
                                  income: dashboardData!['totalIncome']?.toDouble() ?? 0,
                                  expense: dashboardData!['totalExpense']?.toDouble() ?? 0,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
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
