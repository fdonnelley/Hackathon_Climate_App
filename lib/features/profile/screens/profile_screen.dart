import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/models/user_model.dart';

/// Profile screen to display and edit user profile information
class ProfileScreen extends StatefulWidget {
  /// Route name for the screen
  static String get routeName => AppRoutes.getRouteName(AppRoute.profile);
  
  /// Constructor
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController _authController = Get.find<AuthController>();
  
  // Form controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    final user = _authController.currentUser;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
    _bioController = TextEditingController(text: user?.bio);
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      _errorMessage = null;
      
      // Reset controllers to current values if cancelling edit
      if (!_isEditing) {
        final user = _authController.currentUser;
        _nameController.text = user?.name ?? '';
        _emailController.text = user?.email ?? '';
        _bioController.text = user?.bio ?? '';
      }
    });
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final updatedUser = _authController.currentUser?.copyWith(
          name: _nameController.text,
          email: _emailController.text,
          bio: _bioController.text,
        );
        
        if (updatedUser != null) {
          final success = await _authController.updateProfile(updatedUser);
          
          if (success) {
            setState(() {
              _isEditing = false;
              _isLoading = false;
            });
            
            // Show success message
            Get.snackbar(
              'Success',
              'Profile updated successfully',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            setState(() {
              _errorMessage = _authController.errorMessage?.value ?? 'Failed to update profile';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: _toggleEdit,
          ),
        ],
      ),
      body: Obx(() {
        final user = _authController.currentUser;
        
        if (user == null) {
          return const Center(
            child: Text('No user data available'),
          );
        }
        
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  Center(
                    child: Column(
                      children: [
                        // Profile picture with camera icon
                        GestureDetector(
                          onTap: _isEditing ? () {
                            // TODO: Implement image picker
                          } : null,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: theme.colorScheme.primary,
                                child: Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 36,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              if (_isEditing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: theme.colorScheme.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (!_isEditing) ...[
                          Text(
                            user.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.email,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: theme.colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  // User Details Form
                  Text(
                    'Personal Information',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name field
                  AppTextField(
                    controller: _nameController,
                    labelText: 'Name',
                    hintText: 'Enter your name',
                    prefixIcon: Icons.person,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email field
                  AppTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email,
                    enabled: _isEditing,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Bio field
                  AppTextField(
                    controller: _bioController,
                    labelText: 'Bio',
                    hintText: 'Tell us about yourself',
                    prefixIcon: Icons.description,
                    enabled: _isEditing,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Account info (only show when not editing)
                  if (!_isEditing) ...[
                    Text(
                      'Account Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Account Created'),
                      subtitle: Text('January 1, 2025'),
                      tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ListTile(
                      leading: const Icon(Icons.verified_user),
                      title: const Text('Account Status'),
                      subtitle: const Text('Active'),
                      tileColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  if (_isEditing)
                    Center(
                      child: AppButton(
                        text: 'Save Changes',
                        onPressed: _isLoading ? null : _saveProfile,
                        isLoading: _isLoading,
                        icon: Icons.save,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
