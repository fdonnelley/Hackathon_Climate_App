import '../../../core/storage/storage_service.dart';
import '../models/list_item_model.dart';

/// Repository for list operations
class ListRepository {
  /// Storage service for data persistence
  final StorageService _storageService = StorageService();
  
  /// Storage key for list items
  static const String _storageKey = 'list_items';
  
  /// Get all items
  Future<List<ListItemModel>> getItems() async {
    try {
      final data = _storageService.get(_storageKey);
      if (data == null) {
        return _generateSampleItems(); // For demo purposes
      }
      
      final List<dynamic> itemsData = data;
      return itemsData
          .map((item) => ListItemModel.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      // Return sample data for demo purposes if there's an error
      return _generateSampleItems();
    }
  }
  
  /// Add a new item
  Future<void> addItem(ListItemModel item) async {
    try {
      final items = await getItems();
      items.add(item);
      
      await saveItems(items);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Update an existing item
  Future<void> updateItem(ListItemModel updatedItem) async {
    try {
      final items = await getItems();
      final index = items.indexWhere((item) => item.id == updatedItem.id);
      
      if (index != -1) {
        items[index] = updatedItem;
        await saveItems(items);
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Remove an item
  Future<void> removeItem(String id) async {
    try {
      final items = await getItems();
      items.removeWhere((item) => item.id == id);
      
      await saveItems(items);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Save list items to storage
  Future<void> saveItems(List<ListItemModel> items) async {
    try {
      final List<Map<String, dynamic>> itemsData = 
          items.map((item) => item.toMap()).toList();
      
      await _storageService.set(_storageKey, itemsData);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Generate sample items for demo purposes
  List<ListItemModel> _generateSampleItems() {
    return [
      ListItemModel(
        id: '1',
        title: 'Welcome to the Hackathon App',
        description: 'This is a sample item to get you started.',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        priority: ItemPriority.high,
      ),
      ListItemModel(
        id: '2',
        title: 'Customize the UI',
        description: 'Update colors, fonts and components to match your brand.',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        priority: ItemPriority.medium,
      ),
      ListItemModel(
        id: '3',
        title: 'Connect to your API',
        description: 'Use the ApiClient to connect to your backend services.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        priority: ItemPriority.low,
      ),
      ListItemModel(
        id: '4',
        title: 'Add more features',
        description: 'Expand the app with your own custom features.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isCompleted: true,
      ),
    ];
  }
}
