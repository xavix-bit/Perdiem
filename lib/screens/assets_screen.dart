import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../utils/cost_calculator.dart';
import '../widgets/sticker_card.dart';
import 'item_detail_screen.dart';

class AssetsScreen extends ConsumerWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemListProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '资产',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
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
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '暂无资产',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '添加物品后即可查看资产',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: _AssetsContent(items: items),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('加载失败: $e')),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _AssetsContent extends StatelessWidget {
  final List<Item> items;

  const _AssetsContent({required this.items});

  @override
  Widget build(BuildContext context) {
    final totalValue = items.fold(0.0, (sum, item) => sum + item.price);
    final totalDailyCost = items.isEmpty
        ? 0.0
        : items
                .map((item) => CostCalculator.dailyCost(item))
                .reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Cards
          Row(
            children: [
              Expanded(
                child: StickerCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '总资产价值',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${totalValue.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StickerCard(
                  margin: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.trending_down,
                        color: Theme.of(context).colorScheme.error,
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '每日总折旧',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '¥${totalDailyCost.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Assets List Header
          Text(
            '资产列表',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Assets List
          ...items.map((item) => _AssetItem(item: item)),
        ],
      ),
    );
  }
}

class _AssetItem extends StatelessWidget {
  final Item item;

  const _AssetItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final dailyCost = CostCalculator.dailyCost(item);
    final progress = CostCalculator.usageProgress(item);
    final remaining = CostCalculator.remainingDays(item);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: StickerCard(
        margin: EdgeInsets.zero,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ItemDetailScreen(itemId: item.id!),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _iconForCategory(item.category),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (item.brand != null && item.brand!.isNotEmpty)
                    Text(
                      item.brand!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '购入价 ¥${item.price.toStringAsFixed(0)} · 每日 ¥${dailyCost.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '剩余 $remaining 天',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).colorScheme.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
