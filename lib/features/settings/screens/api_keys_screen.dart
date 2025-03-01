import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/config/env_config.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';

/// Screen for managing API keys
class ApiKeysScreen extends StatefulWidget {
  /// Route name for this screen
  static String get routeName => '/settings/api-keys';

  /// Creates the API keys screen
  const ApiKeysScreen({Key? key}) : super(key: key);

  @override
  State<ApiKeysScreen> createState() => _ApiKeysScreenState();
}

class _ApiKeysScreenState extends State<ApiKeysScreen> {
  final _openAiController = TextEditingController();
  final _geminiController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  final _envConfig = EnvConfig();
  
  @override
  void initState() {
    super.initState();
    _loadApiKeys();
  }
  
  @override
  void dispose() {
    _openAiController.dispose();
    _geminiController.dispose();
    super.dispose();
  }
  
  /// Load API keys from environment configuration
  Future<void> _loadApiKeys() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final openAiKey = await _envConfig.openAiApiKey;
      final geminiKey = await _envConfig.geminiApiKey;
      
      setState(() {
        _openAiController.text = openAiKey ?? '';
        _geminiController.text = geminiKey ?? '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load API keys: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Save API keys to secure storage
  Future<void> _saveApiKeys() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });
    
    try {
      await _envConfig.setOpenAiApiKey(_openAiController.text);
      await _envConfig.setGeminiApiKey(_geminiController.text);
      
      setState(() {
        _successMessage = 'API keys saved successfully';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save API keys: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Keys'),
      ),
      body: _isLoading ? 
        const Center(child: CircularProgressIndicator()) :
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'API Key Security',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'API keys are stored securely on your device and are not shared with anyone. '
                        'You can obtain API keys from the respective provider websites:',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      _buildLinkItem(
                        context, 
                        'OpenAI API', 
                        'https://platform.openai.com/account/api-keys',
                      ),
                      _buildLinkItem(
                        context, 
                        'Google AI Studio (Gemini)', 
                        'https://aistudio.google.com/',
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
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
                
                // Success message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: const TextStyle(
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // OpenAI API key
                Text(
                  'OpenAI API Key',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _openAiController,
                  labelText: 'OpenAI API Key',
                  hintText: 'Enter your OpenAI API key',
                  prefixIcon: Icons.key,
                  obscureText: true,
                  toggleObscureText: true,
                ),
                
                const SizedBox(height: 24),
                
                // Gemini API key
                Text(
                  'Google Gemini API Key',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AppTextField(
                  controller: _geminiController,
                  labelText: 'Gemini API Key',
                  hintText: 'Enter your Google Gemini API key',
                  prefixIcon: Icons.key,
                  obscureText: true,
                  toggleObscureText: true,
                ),
                
                const SizedBox(height: 32),
                
                // Save button
                Center(
                  child: AppButton(
                    text: 'Save API Keys',
                    onPressed: _saveApiKeys,
                    isLoading: _isLoading,
                    icon: Icons.save,
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
  
  Widget _buildLinkItem(BuildContext context, String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(
            Icons.link,
            size: 16,
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              // Use the URL launcher package to open the URL
              // This is just a placeholder, you'd use url_launcher in a real app
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening $url'),
                  action: SnackBarAction(
                    label: 'OK',
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
