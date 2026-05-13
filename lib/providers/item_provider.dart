import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../repositories/item_repository.dart';
import '../repositories/local_item_repository.dart';
import '../services/database_service.dart';
import '../utils/cost_calculator.dart';

// ==================== 基础 Provider ====================

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return LocalItemRepository(dbService);
});

// ==================== 物品列表 ====================

final itemListProvider =
    AsyncNotifierProvider<ItemListNotifier, List<Item>>(ItemListNotifier.new);

class ItemListNotifier extends AsyncNotifier<List<Item>> {
  @override
  Future<List<Item>> build() async {
    final repo = ref.watch(itemRepositoryProvider);
    return repo.getAllItems();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetch());
  }

  Future<List<Item>> _fetch() async {
    final repo = ref.read(itemRepositoryProvider);
    return repo.getAllItems();
  }

  Future<Item> addItem(Item item) async {
    final repo = ref.read(itemRepositoryProvider);
    final created = await repo.createItem(item);
    state = AsyncData([...?state.value, created]);
    return created;
  }

  Future<void> updateItem(Item item) async {
    final repo = ref.read(itemRepositoryProvider);
    await repo.updateItem(item);
    final items = await _fetch();
    state = AsyncData(items);
  }

  Future<void> deleteItem(int id) async {
    final repo = ref.read(itemRepositoryProvider);
    await repo.deleteItem(id);
    final items = await _fetch();
    state = AsyncData(items);
  }
}

// ==================== 单个物品详情 ====================

final itemDetailProvider =
    FutureProvider.family<Item, int>((ref, id) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemById(id);
});

// ==================== 成本计算 ====================

final itemCostSummaryProvider =
    Provider.family<CostSummary, Item>((ref, item) {
  return CostCalculator.summary(item);
});

final itemCostHistoryProvider =
    Provider.family<List<DailyCostPoint>, Item>((ref, item) {
  return CostCalculator.sampledCostHistory(item);
});

// ==================== 分类 ====================

final categoryListProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getAllCategories();
});

final itemsByCategoryProvider =
    FutureProvider.family<List<Item>, String>((ref, category) async {
  final repo = ref.watch(itemRepositoryProvider);
  return repo.getItemsByCategory(category);
});
