import 'dart:async';
import 'package:get/get.dart';
import '../storage/storage_service.dart';
import 'api_client.dart';
import 'dart:collection';

/// Service to handle synchronization of data between local storage and server
class SyncService extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiClient _apiClient = Get.find<ApiClient>();
  
  /// Queue of pending sync operations
  final Queue<SyncOperation> _pendingOperations = Queue<SyncOperation>();
  
  /// Whether sync is currently in progress
  final RxBool isSyncing = false.obs;
  
  /// Whether the device is currently offline
  final RxBool isOffline = false.obs;
  
  /// Last sync timestamp
  final Rx<DateTime?> lastSyncTime = Rx<DateTime?>(null);
  
  Timer? _syncTimer;
  
  @override
  void onInit() {
    super.onInit();
    // Load pending operations from storage
    _loadPendingOperations();
    
    // Start periodic sync
    _startPeriodicSync();
  }
  
  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }
  
  /// Adds an operation to the sync queue
  Future<void> addOperation(SyncOperation operation) async {
    _pendingOperations.add(operation);
    await _savePendingOperations();
    
    // Try to sync immediately if online
    if (!isOffline.value) {
      syncNow();
    }
  }
  
  /// Triggers an immediate sync attempt
  Future<bool> syncNow() async {
    if (isSyncing.value || _pendingOperations.isEmpty) {
      return true; // Already syncing or nothing to sync
    }
    
    isSyncing.value = true;
    bool success = true;
    
    try {
      while (_pendingOperations.isNotEmpty) {
        final operation = _pendingOperations.first;
        
        final result = await _executeOperation(operation);
        if (result) {
          _pendingOperations.removeFirst();
          await _savePendingOperations();
        } else {
          // If one operation fails, stop the sync
          success = false;
          break;
        }
      }
      
      if (success) {
        lastSyncTime.value = DateTime.now();
        await _storageService.set('last_sync_time', lastSyncTime.value?.toIso8601String());
      }
    } catch (e) {
      success = false;
    } finally {
      isSyncing.value = false;
    }
    
    return success;
  }
  
  /// Executes a single sync operation
  Future<bool> _executeOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncOperationType.create:
          await _apiClient.post(
            operation.endpoint,
            data: operation.data,
          );
          break;
          
        case SyncOperationType.update:
          await _apiClient.put(
            '${operation.endpoint}/${operation.id}',
            data: operation.data,
          );
          break;
          
        case SyncOperationType.delete:
          await _apiClient.delete(
            '${operation.endpoint}/${operation.id}',
          );
          break;
          
        default:
          return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Loads pending operations from storage
  Future<void> _loadPendingOperations() async {
    final String? storedOperations = await _storageService.get('pending_sync_operations');
    if (storedOperations != null) {
      final List<dynamic> operations = [];
      // Parse the stored operations
      // For each operation in operations:
      // _pendingOperations.add(SyncOperation.fromJson(operation));
    }
    
    final String? lastSync = await _storageService.get('last_sync_time');
    if (lastSync != null) {
      lastSyncTime.value = DateTime.parse(lastSync);
    }
  }
  
  /// Saves pending operations to storage
  Future<void> _savePendingOperations() async {
    final List<Map<String, dynamic>> operations = _pendingOperations
        .map((op) => op.toJson())
        .toList();
    
    await _storageService.set('pending_sync_operations', operations);
  }
  
  /// Starts periodic sync attempts
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      if (!isOffline.value && _pendingOperations.isNotEmpty) {
        syncNow();
      }
    });
  }
  
  /// Sets the offline status
  void setOfflineStatus(bool offline) {
    isOffline.value = offline;
    if (!offline && _pendingOperations.isNotEmpty) {
      // Try to sync when we come back online
      syncNow();
    }
  }
}

/// Types of sync operations
enum SyncOperationType {
  create,
  update,
  delete,
}

/// Represents a pending sync operation
class SyncOperation {
  final String id;
  final String endpoint;
  final SyncOperationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  
  SyncOperation({
    required this.id,
    required this.endpoint,
    required this.type,
    this.data,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  
  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endpoint': endpoint,
      'type': type.toString(),
      'data': data,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  /// Create from JSON
  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      endpoint: json['endpoint'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => SyncOperationType.create,
      ),
      data: json['data'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
