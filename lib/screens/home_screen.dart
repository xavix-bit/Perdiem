import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/cost_calculator.dart';
import '../widgets/sticker_card.dart';
import '../widgets/delete_confirm_dialog.dart';
import 'add_item_screen.dart';
import 'item_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _searchQuery = '';
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Micro texture background
          CustomPaint(
            painter: _DotGridPainter(),
            size: Size.infinite,
          ),
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Top AppBar
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha: 0.95),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: _isSearching
                        ? _buildSearchBar(context)
                        : _buildHeader(context),
                  ),
                ),

                // Content area with padding
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  sliver: itemsAsync.when(
                    data: (items) {
                      final filteredItems = _searchQuery.isEmpty
                          ? items
                          : items.where((item) =>
                              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                              (item.brand?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
                            ).toList();

                      if (items.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(
                            onAdd: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddItemScreen()),
                            ),
                          ),
                        );
                      }

                      if (filteredItems.isEmpty && _searchQuery.isNotEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: AppColors.onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text('未找到匹配的物品', style: Theme.of(context).textTheme.titleLarge),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildListDelegate([
                          // Bento Overview Grid
                          _BentoStats(items: items),
                          const SizedBox(height: 48),

                          // Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '我的物品',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  '查看全部',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.05,
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.primary,
                                    decorationThickness: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Item Cards
                          ...filteredItems.map((item) => _StickerItemCard(
                            item: item,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(itemId: item.id!),
                              ),
                            ),
                            onDelete: () => _deleteItem(context, ref, item),
                          )),

                          const SizedBox(height: 48),

                          // Add Item CTA
                          _AddItemCTA(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddItemScreen()),
                            ),
                          ),
                        ]),
                      );
                    },
                    loading: () => SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const _ShimmerCard(),
                        childCount: 4,
                      ),
                    ),
                    error: (e, _) => SliverFillRemaining(
                      child: Center(child: Text('加载失败: $e')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            'Perdiem',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
              letterSpacing: 0.03,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.search, color: AppColors.foreground),
          onPressed: () => setState(() => _isSearching = true),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '搜索物品...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _isSearching = false;
                  });
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        TextButton(
          onPressed: () {
            _searchController.clear();
            setState(() {
              _searchQuery = '';
              _isSearching = false;
            });
          },
          child: const Text('取消'),
        ),
      ],
    );
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref, Item item) async {
    final confirmed = await showDeleteConfirmDialog(context: context, item: item);
    if (confirmed == true) {
      await ref.read(itemListProvider.notifier).deleteItem(item.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('「${item.name}」已删除')),
        );
      }
    }
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

// ==================== Bento Stats ====================

class _BentoStats extends StatelessWidget {
  final List<Item> items;

  const _BentoStats({required this.items});

  @override
  Widget build(BuildContext context) {
    final avgDailyCost = items.isEmpty
        ? 0.0
        : items.map((item) => CostCalculator.dailyCost(item)).reduce((a, b) => a + b) / items.length;

    return Column(
      children: [
        // Items Card — secondary-container background (full width)
        StickerCard(
          margin: EdgeInsets.zero,
          backgroundColor: AppColors.secondaryContainer,
          borderColor: AppColors.foreground,
          shadowColor: AppColors.foreground,
          shadowOffset: 8,
          padding: const EdgeInsets.all(20),
          enableHoverEffect: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + Label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.foreground, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.foreground,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(Icons.inventory_2, color: AppColors.onSecondaryContainer, size: 18),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.foreground.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            'ITEMS',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.05,
                              color: AppColors.foreground,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${items.length} 件物品',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '目前正在追踪的资产总数',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSecondaryContainer.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Avg Cost Card — tertiary background (full width)
        StickerCard(
          margin: EdgeInsets.zero,
          backgroundColor: AppColors.tertiary,
          borderColor: AppColors.foreground,
          shadowColor: AppColors.foreground,
          shadowOffset: 8,
          padding: const EdgeInsets.all(20),
          enableHoverEffect: true,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.foreground, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.foreground,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Icon(Icons.payments, color: AppColors.onTertiaryFixedVariant, size: 18),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.foreground),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.foreground,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '¥${avgDailyCost.toStringAsFixed(1)} ',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: AppColors.onTertiaryFixedVariant,
                          ),
                        ),
                        Text(
                          '平均/天',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onTertiaryFixedVariant.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '所有资产每日折旧成本估算',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onTertiaryFixedVariant.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ==================== Sticker Item Card ====================

class _StickerItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StickerItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dailyCost = CostCalculator.dailyCost(item);
    final progress = CostCalculator.usageProgress(item);
    final remaining = CostCalculator.remainingDays(item);
    final daysUsed = CostCalculator.daysUsed(item);
    final color = _colorForCategory(item.category);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: StickerCard(
        margin: const EdgeInsets.only(bottom: 24),
        borderColor: AppColors.foreground,
        shadowColor: AppColors.foreground,
        shadowOffset: 8,
        padding: const EdgeInsets.all(24),
        onTap: onTap,
        child: Stack(
          children: [
            // Decorative circle (top-right)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Icon + Name + Category
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.foreground, width: 2),
                      ),
                      child: Icon(
                        _iconForCategory(item.category),
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category ?? '未分类',
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
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Daily Cost
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '每日成本',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '¥${dailyCost.toStringAsFixed(2)}/天',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar — 2px border + inner shadow
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(color: AppColors.foreground, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            border: Border(
                              right: BorderSide(color: AppColors.foreground, width: 2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Usage stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '使用 $daysUsed 天',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      '预计剩余 $remaining 天',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.05,
                        color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForCategory(String? category) {
    switch (category) {
      case '数码':
        return AppColors.primary;
      case '摄影':
        return AppColors.tertiaryContainer;
      default:
        return AppColors.secondary;
    }
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case '数码':
        return Icons.laptop_mac;
      case '家居':
        return Icons.chair_outlined;
      case '服饰':
        return Icons.checkroom_outlined;
      case '运动':
        return Icons.directions_run;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}

// ==================== Add Item CTA ====================

class _AddItemCTA extends StatelessWidget {
  final VoidCallback onTap;

  const _AddItemCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Decorative dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.foreground),
                boxShadow: [BoxShadow(color: AppColors.foreground, offset: const Offset(2, 2), blurRadius: 0)],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.foreground),
                boxShadow: [BoxShadow(color: AppColors.foreground, offset: const Offset(2, 2), blurRadius: 0)],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.foreground),
                boxShadow: [BoxShadow(color: AppColors.foreground, offset: const Offset(2, 2), blurRadius: 0)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: AppColors.foreground, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.foreground,
                  offset: const Offset(8, 8),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '添加物品',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.01,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.foreground.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Icons.add, color: AppColors.primary, size: 24),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Empty State ====================

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.calculate_outlined,
                size: 52,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            '开始记录你的第一件物品',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 10),
          Text(
            '看看你每天使用的物品，\n究竟花了你多少钱',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('添加第一件物品'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '也可以点击右下角的按钮随时添加',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ==================== Shimmer Card ====================

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return StickerCard(
      margin: const EdgeInsets.only(bottom: 24),
      borderColor: AppColors.foreground,
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 80,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
