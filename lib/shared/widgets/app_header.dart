import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendly/shared/themes/app_theme.dart';
import 'package:spendly/core/providers/firebase_providers.dart';
import 'package:spendly/core/providers/date_provider.dart';
import 'package:spendly/core/providers/currency_provider.dart';
import 'package:spendly/features/settings/view/settings_screen.dart';
import 'package:spendly/generated/l10n/app_localizations.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool showDatePicker;
  final bool showBackButton;
  final bool showActions;

  const AppHeader({
    super.key,
    required this.title,
    this.trailing,
    this.showDatePicker = true,
    this.showBackButton = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 24,
        left: 24,
        right: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (showBackButton) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              if (showActions) const HeaderActions(),
            ],
          ),
          if (showDatePicker) ...[
            const SizedBox(height: 20),
            const DatePickerBar(),
          ],
        ],
      ),
    );
  }
}

class SliverAppHeader extends StatelessWidget {
  final String title;
  final bool showDatePicker;
  final bool showBackButton;
  final bool showActions;

  const SliverAppHeader({
    super.key,
    required this.title,
    this.showDatePicker = true,
    this.showBackButton = false,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: showDatePicker ? 180 : 100,
      backgroundColor: AppColors.primary,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (showDatePicker) const DatePickerBar(),
            ],
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (showBackButton) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          if (showActions) const HeaderActions(),
        ],
      ),
    );
  }
}

class HeaderActions extends ConsumerWidget {
  const HeaderActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    final initials = user?.email?.substring(0, 2).toUpperCase() ?? '??';
    final currency = ref.watch(currencyProvider);

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.public, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  currency,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen())),
        ),
      ],
    );
  }
}

class DatePickerBar extends ConsumerWidget {
  const DatePickerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isCurrentMonth = selectedDate.year == now.year && selectedDate.month == now.month;
    
    final l10n = AppLocalizations.of(context)!;
    final monthNames = [
      l10n.jan, l10n.feb, l10n.mar, l10n.apr, l10n.may, l10n.jun,
      l10n.jul, l10n.aug, l10n.sep, l10n.oct, l10n.nov, l10n.dec
    ];
    final label = isCurrentMonth ? l10n.thisMonth : '${monthNames[selectedDate.month - 1]} ${selectedDate.year}'.toUpperCase();

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppColors.background,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return Material(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.selectMonth, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 1.2)),
                      const SizedBox(height: 16),
                      ...List.generate(6, (index) {
                        final date = DateTime(now.year, now.month - index, 1);
                        final isSelected = date.year == selectedDate.year && date.month == selectedDate.month;
                        final text = index == 0 ? l10n.thisMonth : '${monthNames[date.month - 1]} ${date.year}';
                        return ListTile(
                          title: Text(
                            text,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                              color: isSelected ? AppColors.primary : AppColors.textDark,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          onTap: () {
                            ref.read(selectedDateProvider.notifier).select(date);
                            Navigator.pop(context);
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}
