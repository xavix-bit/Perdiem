import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/cost_calculator.dart';
import '../widgets/sticker_card.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dot grid background
          CustomPaint(
            painter: _DotGridPainter(),
            size: Size.infinite,
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // TopAppBar
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        bottom: BorderSide(color: AppColors.onSurface, width: 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface,
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.grid_view, color: AppColors.primary, size: 24),
                            const SizedBox(width: 8),
                            Stack(
                              children: [
                                Text(
                                  '统计',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                // Underline decoration
                                Positioned(
                                  bottom: 1,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(color: AppColors.onSurface, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.onSurface,
                                          offset: const Offset(2, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Icon(Icons.calendar_today, color: AppColors.onSurfaceVariant, size: 24),
                      ],
                    ),
                  ),
                ),

                // Content
                itemsAsync.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.equalizer_outlined, size: 64, color: AppColors.onSurfaceVariant),
                              const SizedBox(height: 16),
                              Text('暂无数据', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text('添加物品后即可查看统计', style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverToBoxAdapter(
                      child: _StatsContent(items: items),
                    );
                  },
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => SliverFillRemaining(
                    child: Center(child: Text('加载失败: $e')),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final List<Item> items;

  const _StatsContent({required this.items});

  @override
  Widget build(BuildContext context) {
    final totalDailyCost = items.isEmpty
        ? 0.0
        : items.map((item) => CostCalculator.dailyCost(item)).reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Section 1: Overview =====
          _DashedSection(
            title: '概览',
            child: StickerCard(
              margin: EdgeInsets.zero,
              borderColor: AppColors.onSurface,
              shadowColor: AppColors.secondary,
              shadowOffset: 8,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '总资产折旧',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.05,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Icon(Icons.trending_down, color: AppColors.secondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¥${totalDailyCost.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Mini bar chart — driven by each item's daily cost
                  Builder(builder: (context) {
                    final costs = items.map((i) => CostCalculator.dailyCost(i)).toList();
                    final maxCost = costs.isEmpty ? 1.0 : costs.reduce((a, b) => a > b ? a : b);
                    final displayCosts = costs.length > 8
                        ? List.generate(8, (i) => costs[((i + 1) * costs.length / 8 - 1).round()])
                        : costs;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '各物品日均',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.05,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(displayCosts.length, (i) {
                              final h = maxCost > 0 ? (displayCosts[i] / maxCost * 48) : 0.0;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 2),
                                  child: Container(
                                    height: h.clamp(4.0, 48.0),
                                    decoration: BoxDecoration(
                                      color: i == displayCosts.length - 1 ? AppColors.primary : AppColors.secondary,
                                      borderRadius: BorderRadius.circular(9999),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== Section 2: Expense Trend =====
          _DashedSection(
            title: '支出趋势',
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.onSurface, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.onSurface,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '过去30天日均折旧',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.onSurface),
                        ),
                        child: Text(
                          '30 DAYS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Bar Chart with grid lines — driven by real monthly cost data
                  Builder(builder: (context) {
                    // Compute daily cost at 12 evenly spaced points over the last 360 days
                    final now = DateTime.now();
                    final bucketSize = 30; // 30 days per bucket
                    final numBuckets = 12;
                    final bucketCosts = List<double>.filled(numBuckets, 0);
                    for (final item in items) {
                      for (int b = 0; b < numBuckets; b++) {
                        final bucketEnd = now.subtract(Duration(days: (numBuckets - 1 - b) * bucketSize));
                        final daysSincePurchase = bucketEnd.difference(item.purchaseDate).inDays;
                        if (daysSincePurchase > 0) {
                          bucketCosts[b] += item.price / daysSincePurchase;
                        }
                      }
                    }
                    final maxBucket = bucketCosts.isEmpty ? 1.0 : bucketCosts.reduce((a, b) => a > b ? a : b);
                    final colors = [
                      AppColors.primaryContainer,
                      AppColors.secondaryContainer,
                      AppColors.tertiary,
                    ];
                    return SizedBox(
                      height: 160,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                              (_) => Container(
                                height: 1,
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: AppColors.onSurface.withValues(alpha: 0.1),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(numBuckets, (i) {
                              final h = maxBucket > 0 ? (bucketCosts[i] / maxBucket * 140) : 0.0;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 3, bottom: 4),
                                  child: Container(
                                    height: h.clamp(4.0, 140.0),
                                    decoration: BoxDecoration(
                                      color: colors[i % 3],
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                      border: Border.all(color: AppColors.onSurface, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.onSurface,
                                          offset: const Offset(3, 3),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // X-axis labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('12个月前', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: -0.5)),
                      Text('6个月前', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: -0.5)),
                      Text('今天', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant, letterSpacing: -0.5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===== Section 3: Category Breakdown =====
          _DashedSection(
            title: '分类分布',
            child: Column(
              children: _buildCategoryStats(context, items),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryStats(BuildContext context, List<Item> items) {
    final categories = <String, List<Item>>{};
    for (final item in items) {
      final cat = item.category ?? '其他';
      categories.putIfAbsent(cat, () => []).add(item);
    }

    final categoryColors = {
      '数码': AppColors.quaternary,
      '家居': AppColors.tertiary,
      '服饰': AppColors.primaryContainer,
      '运动': AppColors.secondary,
      '其他': AppColors.outline,
    };

    final categoryIcons = {
      '数码': Icons.devices,
      '家居': Icons.chair_outlined,
      '服饰': Icons.checkroom_outlined,
      '运动': Icons.directions_run,
      '其他': Icons.inventory_2_outlined,
    };

    return categories.entries.map((entry) {
      final percentage = (entry.value.length / items.length * 100).round();
      final color = categoryColors[entry.key] ?? AppColors.outline;
      final icon = categoryIcons[entry.key] ?? Icons.inventory_2_outlined;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.onSurface, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.onSurface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onSurface,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(icon, color: AppColors.onSurface, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Striped progress bar
              Container(
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.onSurface, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: Stack(
                    children: [
                      FractionallySizedBox(
                        widthFactor: percentage / 100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            border: Border(
                              right: BorderSide(color: AppColors.onSurface, width: 2),
                            ),
                          ),
                          child: CustomPaint(
                            painter: _StripePainter(),
                            size: Size.infinite,
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
      );
    }).toList();
  }
}

// ==================== Dashed Section Container ====================

class _DashedSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DashedSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 2,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title with tab style
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.onSurface, width: 2),
                bottom: BorderSide(color: AppColors.onSurface, width: 2),
                right: BorderSide(color: AppColors.onSurface, width: 2),
              ),
              borderRadius: const BorderRadius.only(topRight: Radius.circular(4), bottomRight: Radius.circular(4)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.onSurface,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ==================== Stripe Painter ====================

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    const stripeWidth = 10.0;
    const gap = 10.0;

    for (double x = -size.height; x < size.width + size.height; x += stripeWidth + gap) {
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth - size.height, size.height)
        ..lineTo(x - size.height, size.height)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== Dot Grid Background ====================

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.fill;

    const spacing = 24.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
