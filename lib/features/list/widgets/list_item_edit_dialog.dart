import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/list_item_model.dart';

/// Dialog for creating/editing list items
class ListItemEditDialog extends StatefulWidget {
  /// Existing item to edit (null for create)
  final ListItemModel? item;

  /// Creates a list item edit dialog
  const ListItemEditDialog({
    Key? key,
    this.item,
  }) : super(key: key);

  @override
  State<ListItemEditDialog> createState() => _ListItemEditDialogState();
}

class _ListItemEditDialogState extends State<ListItemEditDialog> {
  /// Form key
  final _formKey = GlobalKey<FormState>();
  
  /// Text controllers
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  
  /// Selected priority
  late ItemPriority _selectedPriority;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize controllers
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(text: widget.item?.description ?? '');
    
    // Initialize priority
    _selectedPriority = widget.item?.priority ?? ItemPriority.medium;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.item != null;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              Text(
                isEditing ? 'Edit Item' : 'Add New Item',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              
              // Title field
              AppTextField(
                controller: _titleController,
                labelText: 'Title',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description field
              AppTextField(
                controller: _descriptionController,
                labelText: 'Description',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Priority dropdown
              DropdownButtonFormField<ItemPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ItemPriority.values.map((priority) {
                  return DropdownMenuItem<ItemPriority>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Color(priority.color),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(priority.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPriority = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 24),
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    type: ButtonType.secondary,
                    text: 'Cancel',
                    onPressed: () => Get.back(),
                  ),
                  const SizedBox(width: 16),
                  AppButton(
                    text: isEditing ? 'Save Changes' : 'Add Item',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _handleSubmit() {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    final ListItemModel result = widget.item != null
        ? widget.item!.copyWith(
            title: _titleController.text,
            description: _descriptionController.text,
            priority: _selectedPriority,
          )
        : ListItemModel(
            id: const Uuid().v4(),
            title: _titleController.text,
            description: _descriptionController.text,
            timestamp: DateTime.now(),
            priority: _selectedPriority,
          );
    
    Get.back(result: result);
  }
}
