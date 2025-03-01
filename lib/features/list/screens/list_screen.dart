import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../controllers/list_controller.dart';
import '../models/list_item_model.dart';
import '../widgets/list_item_card.dart';

/// List screen
class ListScreen extends StatelessWidget {
  /// Route name
  static const String routeName = '/list';
  
  /// Creates list screen
  const ListScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<ListController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Items List'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filters
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item
          controller.addItem(
            ListItemModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'New Item',
              description: 'Tap to edit this item',
              timestamp: DateTime.now(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingList();
          }
          
          if (controller.items.isEmpty) {
            return _buildEmptyState(theme);
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadItems();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final item = controller.items[index];
                return ListItemCard(
                  item: item,
                  onTap: () {
                    // Show item details
                  },
                  onEdit: () {
                    // Edit item
                  },
                  onDelete: () {
                    controller.removeItem(item.id);
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 72,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Items Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add a new item',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
