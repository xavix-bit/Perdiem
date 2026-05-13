import '../models/item.dart';
import '../services/database_service.dart';
import 'item_repository.dart';

class LocalItemRepository implements ItemRepository {
  final DatabaseService _dbService;

  LocalItemRepository(this._dbService);

  @override
  Future<List<Item>> getAllItems() async {
    final maps = await _dbService.queryAllItems();
    return maps.map((m) => Item.fromMap(m)).toList();
  }

  @override
  Future<Item> getItemById(int id) async {
    final map = await _dbService.queryItemById(id);
    return Item.fromMap(map);
  }

  @override
  Future<Item> createItem(Item item) async {
    final id = await _dbService.insertItem(item.toMap());
    return item.copyWith(id: id);
  }

  @override
  Future<Item> updateItem(Item item) async {
    await _dbService.updateItem(item.toMap());
    return item;
  }

  @override
  Future<void> deleteItem(int id) async {
    await _dbService.deleteItem(id);
  }

  @override
  Future<void> deleteAllItems() async {
    await _dbService.deleteAllItems();
  }

  @override
  Future<List<Item>> getItemsByCategory(String category) async {
    final maps = await _dbService.queryItemsByCategory(category);
    return maps.map((m) => Item.fromMap(m)).toList();
  }

  @override
  Future<List<String>> getAllCategories() async {
    final maps = await _dbService.queryAllCategories();
    return maps.map((m) => m['category'] as String).toList();
  }
}
