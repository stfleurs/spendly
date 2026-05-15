import 'package:flutter/material.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/features/home/view/dashboard_screen.dart';
import 'package:spendly/features/accounts/view/accounts_screen.dart';
import 'package:spendly/features/transactions/view/transactions_screen.dart';
import 'package:spendly/features/transactions/view/new_transaction_screen.dart';
import 'package:spendly/features/ocr/view/receipt_scanner_screen.dart';
import 'package:spendly/features/upcoming/view/add_upcoming_screen.dart';
import 'package:spendly/features/upcoming/view/add_plan_screen.dart';
import 'package:spendly/features/budget/view/budget_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AccountsScreen(),
    const MyBudgetScreen(),
    const TransactionsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Current Screen
          Padding(
            padding: const EdgeInsets.only(bottom: 0), // Handle padding in screens or bar
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),

          // Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBarItem(
                          icon: Icons.grid_view_rounded,
                          label: 'HOME',
                          isSelected: _selectedIndex == 0,
                          onTap: () => setState(() => _selectedIndex = 0),
                        ),
                        _NavBarItem(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'WALLETS',
                          isSelected: _selectedIndex == 1,
                          onTap: () => setState(() => _selectedIndex = 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 80), // Perfect gap for FAB
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _NavBarItem(
                          icon: Icons.pie_chart_rounded,
                          label: 'BUDGET',
                          isSelected: _selectedIndex == 2,
                          onTap: () => setState(() => _selectedIndex = 2),
                        ),
                        _NavBarItem(
                          icon: Icons.receipt_long_rounded,
                          label: 'HISTORY',
                          isSelected: _selectedIndex == 3,
                          onTap: () => setState(() => _selectedIndex = 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Speed-Dial FAB (Floating above the bar)
          const _SpeedDialFab(bottomNavHeight: 128),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Speed-Dial FAB
// ---------------------------------------------------------------------------

class _SpeedDialFab extends StatefulWidget {
  final double bottomNavHeight;
  const _SpeedDialFab({required this.bottomNavHeight});

  @override
  State<_SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<_SpeedDialFab>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    _isOpen ? _controller.forward() : _controller.reverse();
  }

  void _close() {
    if (!_isOpen) return;
    setState(() => _isOpen = false);
    _controller.reverse();
  }

  void _navigate(Widget screen) {
    _close();
    Future.delayed(const Duration(milliseconds: 160), () {
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Position FAB centred vertically in the bottom nav bar
    final fabBottom = widget.bottomNavHeight / 2 - 35;

    return Stack(
      children: [
        // ── Dimming overlay ─────────────────────────────────────────────────
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),

        // ── Action buttons (fan up above the FAB) ──────────────────────────
        Positioned(
          bottom: fabBottom + 85,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Create Plan
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _SpeedDialAction(
                    icon: Icons.account_tree_outlined,
                    label: 'Create Plan',
                    color: const Color(0xFFD946EF), // Pink/Purple
                    onTap: () => _navigate(const AddPlanScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Add Payment
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _SpeedDialAction(
                    icon: Icons.upcoming_outlined,
                    label: 'Add Payment',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _navigate(const AddUpcomingScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Scan Receipt
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _SpeedDialAction(
                    icon: Icons.receipt_long,
                    label: 'Scan Receipt',
                    color: AppColors.primary,
                    onTap: () => _navigate(const ReceiptScannerScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Add Manually
              ScaleTransition(
                scale: _expandAnimation,
                child: FadeTransition(
                  opacity: _expandAnimation,
                  child: _SpeedDialAction(
                    icon: Icons.edit_outlined,
                    label: 'Quick Add',
                    color: AppColors.income,
                    onTap: () => _navigate(const NewTransactionScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),

        // ── Main FAB ────────────────────────────────────────────────────────
        Positioned(
          bottom: fabBottom,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: GestureDetector(
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: _isOpen ? Colors.white : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isOpen ? Colors.black : AppColors.primary)
                        .withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0.0, // 45° → looks like X
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  Icons.add,
                  color: _isOpen ? AppColors.primary : Colors.white,
                  size: 36,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Speed-Dial Action Button
// ---------------------------------------------------------------------------

class _SpeedDialAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _SpeedDialAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Mini FAB
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nav Bar Item
// ---------------------------------------------------------------------------

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.textLight.withValues(alpha: 0.5),
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textLight.withValues(alpha: 0.5),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
