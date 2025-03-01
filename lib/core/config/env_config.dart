import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Environment configuration service for managing API keys and other sensitive data
class EnvConfig {
  static final EnvConfig _instance = EnvConfig._internal();
  
  /// Singleton instance
  factory EnvConfig() => _instance;
  
  EnvConfig._internal();
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  bool _isInitialized = false;
  
  /// Available LLM providers
  static const availableLlmProviders = [
    'OpenAI', 
    'Google Gemini',
    'Groq'
  ];
  
  /// Initialize the environment configuration
  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      // Load .env file if it exists
      await dotenv.load(fileName: ".env").catchError((e) {
        debugPrint('No .env file found. Using defaults or secure storage.');
      });
      
      _isInitialized = true;
    } catch (e) {
      debugPrint('Error initializing environment config: $e');
    }
  }
  
  /// Get a value from .env file or secure storage
  Future<String?> get(String key) async {
    // First try to get from .env file
    final envValue = dotenv.env[key];
    
    // If not found in .env, try secure storage
    if (envValue == null || envValue.isEmpty) {
      try {
        return await _secureStorage.read(key: key);
      } catch (e) {
        debugPrint('Error reading from secure storage: $e');
        return null;
      }
    }
    
    return envValue;
  }
  
  /// Set a value in secure storage
  Future<void> set(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (e) {
      debugPrint('Error writing to secure storage: $e');
      // If secure storage fails, fall back to in-memory storage
      dotenv.env[key] = value;
    }
  }
  
  /// Check if a key exists in .env or secure storage
  Future<bool> has(String key) async {
    final value = await get(key);
    return value != null && value.isNotEmpty;
  }
  
  /// Get the OpenAI API key
  Future<String?> get openAiApiKey => get('OPENAI_API_KEY');
  
  /// Get the Gemini API key
  Future<String?> get geminiApiKey => get('GEMINI_API_KEY');
  
  /// Get the Groq API key
  Future<String?> get groqApiKey => get('GROQ_API_KEY');
  
  /// Get the default LLM provider
  Future<String> get defaultLlmProvider async {
    final provider = await get('DEFAULT_LLM_PROVIDER');
    return provider ?? 'Groq';
  }
  
  /// Set the OpenAI API key in secure storage
  Future<void> setOpenAiApiKey(String apiKey) async {
    await set('OPENAI_API_KEY', apiKey);
  }
  
  /// Set the Gemini API key in secure storage
  Future<void> setGeminiApiKey(String apiKey) async {
    await set('GEMINI_API_KEY', apiKey);
  }
  
  /// Set the Groq API key in secure storage
  Future<void> setGroqApiKey(String apiKey) async {
    await set('GROQ_API_KEY', apiKey);
  }
  
  /// Set the default LLM provider in secure storage
  Future<void> setDefaultLlmProvider(String provider) async {
    await set('DEFAULT_LLM_PROVIDER', provider);
  }
}
