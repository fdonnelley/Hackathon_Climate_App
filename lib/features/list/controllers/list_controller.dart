import 'package:get/get.dart';

import '../models/list_item_model.dart';
import '../repositories/list_repository.dart';

/// Controller for list screen
class ListController extends GetxController {
  /// Repository for list operations
  final ListRepository _repository = ListRepository();
  
  /// Loading state
  final RxBool isLoading = false.obs;
  
  /// List items
  final RxList<ListItemModel> items = <ListItemModel>[].obs;
  
  /// Error message
  final RxString errorMessage = ''.obs;
  
  /// Initialize the controller
  @override
  void onInit() {
    super.onInit();
    loadItems();
  }
  
  /// Load items from repository
  Future<void> loadItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Artificial delay for demo purposes
      await Future.delayed(const Duration(seconds: 1));
      
      final result = await _repository.getItems();
      items.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Add a new item
  Future<void> addItem(ListItemModel item) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _repository.addItem(item);
      items.add(item);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Update an existing item
  Future<void> updateItem(ListItemModel item) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _repository.updateItem(item);
      
      final index = items.indexWhere((element) => element.id == item.id);
      if (index != -1) {
        items[index] = item;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Remove an item
  Future<void> removeItem(String id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _repository.removeItem(id);
      
      items.removeWhere((element) => element.id == id);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Toggle completion status
  Future<void> toggleItemCompletion(String id) async {
    try {
      final index = items.indexWhere((element) => element.id == id);
      if (index != -1) {
        final item = items[index];
        final updatedItem = item.copyWith(isCompleted: !item.isCompleted);
        
        await updateItem(updatedItem);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
}
