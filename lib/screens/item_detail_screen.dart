import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/cost_calculator.dart';
import '../widgets/delete_confirm_dialog.dart';
import '../widgets/sticker_card.dart';
import 'add_item_screen.dart';

class ItemDetailScreen extends ConsumerWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);

    return itemsAsync.when(
      data: (items) {
        final item = items.where((i) => i.id == itemId).firstOrNull;
        if (item == null) {
          return Scaffold(
            body: Center(
              child: Text('物品未找到', style: Theme.of(context).textTheme.titleLarge),
            ),
          );
        }
        return _ItemDetailContent(item: item);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('加载失败: $e'))),
    );
  }
}

class _ItemDetailContent extends ConsumerWidget {
  final Item item;

  const _ItemDetailContent({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyCost = CostCalculator.dailyCost(item);
    final progress = CostCalculator.usageProgress(item);
    final remaining = CostCalculator.remainingDays(item);
    final totalDays = CostCalculator.expectedTotalDays(item);
    final daysUsed = CostCalculator.daysUsed(item);

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
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // Sticky AppBar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border(
                      bottom: BorderSide(color: AppColors.foreground, width: 2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.foreground,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.foreground, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.foreground,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: AppColors.foreground, size: 20),
                          onPressed: () async {
                            final result = await Navigator.push<Item>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddItemScreen(item: item),
                              ),
                            );
                            if (result != null) {
                              ref.invalidate(itemListProvider);
                            }
                          },
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Delete button
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.foreground, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.foreground,
                              offset: const Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(Icons.delete, color: AppColors.error, size: 20),
                          onPressed: () => _confirmDelete(context, ref),
                          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ===== Main Cost Card =====
                      StickerCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(24),
                        borderColor: AppColors.foreground,
                        shadowColor: AppColors.foreground,
                        shadowOffset: 4,
                        borderRadius: 16,
                        child: Column(
                          children: [
                            // Cost Text
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '当前每日成本',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      '¥',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      dailyCost.toStringAsFixed(2),
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '/ 天',
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Circular Progress
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CustomPaint(
                                        painter: _CircleProgressPainter(
                                          progress: progress.clamp(0.0, 1.0),
                                          backgroundColor: AppColors.surfaceContainerHighest,
                                          progressColor: AppColors.primary,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${(progress * 100).toInt()}%',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.onBackground,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '使用进度',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.05,
                                        color: AppColors.mutedForeground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats Cards — 3 cards in a row
                      Row(
                        children: [
                          // 已用天数
                          Expanded(
                            child: StickerCard(
                              margin: EdgeInsets.zero,
                              backgroundColor: AppColors.primaryContainer,
                              borderColor: AppColors.foreground,
                              shadowColor: AppColors.foreground,
                              shadowOffset: 4,
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '已用',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.05,
                                          color: AppColors.onPrimaryContainer.withValues(alpha: 0.9),
                                        ),
                                      ),
                                      Icon(Icons.event_available, color: AppColors.onPrimaryContainer, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$daysUsed天',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 目标周期
                          Expanded(
                            child: StickerCard(
                              margin: EdgeInsets.zero,
                              backgroundColor: AppColors.surfaceContainerHighest,
                              borderColor: AppColors.foreground,
                              shadowColor: AppColors.foreground,
                              shadowOffset: 4,
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '目标',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.05,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                      Icon(Icons.timer, color: AppColors.onSurfaceVariant, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$totalDays天',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 剩余天数
                          Expanded(
                            child: StickerCard(
                              margin: EdgeInsets.zero,
                              backgroundColor: AppColors.secondary,
                              borderColor: AppColors.foreground,
                              shadowColor: AppColors.foreground,
                              shadowOffset: 4,
                              borderRadius: 16,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '剩余',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.05,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        ),
                                      ),
                                      const Icon(Icons.hourglass_empty, color: Colors.white, size: 18),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$remaining天',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ===== Cost Trend Chart =====
                      StickerCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(20),
                        borderColor: AppColors.foreground,
                        shadowColor: AppColors.foreground,
                        shadowOffset: 4,
                        borderRadius: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.foreground, width: 2),
                                  ),
                                  child: Icon(Icons.trending_down, color: AppColors.onBackground, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '成本趋势',
                                  style: TextStyle(
                                    fontFamily: 'Outfit',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onBackground,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            // SVG-like trend chart using CustomPaint
                            SizedBox(
                              height: 180,
                              child: CustomPaint(
                                painter: _TrendChartPainter(
                                  data: _generateTrendData(item),
                                  lineColor: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // X-axis labels
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '购买日',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                Text(
                                  '今日',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                                Text(
                                  '目标日',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== Item Image =====
                      if (item.imagePath != null)
                        StickerCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(8),
                          borderColor: AppColors.foreground,
                          shadowColor: AppColors.foreground,
                          shadowOffset: 4,
                          borderRadius: 16,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(item.imagePath!),
                              width: double.infinity,
                              height: 240,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      if (item.imagePath != null)
                        const SizedBox(height: 24),

                      // ===== Details Grid =====
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Item Info Card
                          Expanded(
                            child: StickerCard(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.all(32),
                              borderColor: AppColors.foreground,
                              shadowColor: AppColors.foreground,
                              shadowOffset: 4,
                              borderRadius: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '物品信息',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onBackground,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _InfoRow(label: '品牌', value: item.brand ?? '-'),
                                  Divider(height: 24, color: AppColors.surfaceVariant, thickness: 1),
                                  _InfoRow(label: '分类', value: item.category ?? '-'),
                                  Divider(height: 24, color: AppColors.surfaceVariant, thickness: 1),
                                  _InfoRow(label: '购入价格', value: '¥${item.price.toStringAsFixed(2)}'),
                                  Divider(height: 24, color: AppColors.surfaceVariant, thickness: 1),
                                  _InfoRow(label: '购入日期', value: DateFormat('yyyy-MM-dd').format(item.purchaseDate)),
                                  Divider(height: 24, color: AppColors.surfaceVariant, thickness: 1),
                                  _InfoRow(label: '折旧方式', value: '直线折旧 (${item.expectedLifespanMonths ~/ 12}年)'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generateTrendData(Item item) {
    final history = CostCalculator.sampledCostHistory(item, maxPoints: 30);
    if (history.isEmpty) return [1.0, 0.8, 0.6, 0.4, 0.3];
    return history.map((p) => p.dailyCost).toList();
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDeleteConfirmDialog(context: context, item: item);
    if (confirmed == true) {
      await ref.read(itemListProvider.notifier).deleteItem(item.id!);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${item.name}」已删除')),
        );
      }
    }
  }
}

// ==================== Circle Progress Painter ====================

class _CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _CircleProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 12;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ==================== Trend Chart Painter ====================

class _TrendChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;

  _TrendChartPainter({required this.data, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal;
    final padding = 16.0;

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + (i / (data.length - 1).clamp(1, data.length)) * (size.width - padding * 2);
      final normalized = range > 0 ? (data[i] - minVal) / range : 0.5;
      final y = size.height - padding - normalized * (size.height - padding * 2);
      points.add(Offset(x, y));
    }

    // Gradient fill
    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [lineColor.withValues(alpha: 0.3), lineColor.withValues(alpha: 0.0)],
    );
    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _TrendChartPainter oldDelegate) =>
      oldDelegate.data != data;
}

// ==================== Info Row ====================

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ==================== Dot Grid Background ====================

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.foreground.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const dotSize = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
