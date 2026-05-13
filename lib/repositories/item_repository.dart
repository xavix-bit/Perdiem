import '../models/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getAllItems();
  Future<Item> getItemById(int id);
  Future<Item> createItem(Item item);
  Future<Item> updateItem(Item item);
  Future<void> deleteItem(int id);
  Future<void> deleteAllItems();
  Future<List<Item>> getItemsByCategory(String category);
  Future<List<String>> getAllCategories();
}
