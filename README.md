# Hackathon App Template

A professional Flutter mobile app template optimized for hackathon projects, featuring a robust architecture with GetX state management, complete authentication flow, networking layer, and a modern UI.

## Features

- Advanced state management with GetX
- Complete authentication flow (Login, Signup, Forgot Password)
- Networking layer with Dio for API integration
- Local storage with Hive and SharedPreferences
- Environment configuration management
- Comprehensive theming system with light/dark mode support
- Form validation utilities
- Error handling utilities
- Custom reusable UI components
- Professional feature-based folder structure
- Clean, commented code with proper documentation

### Chatbot Integration
The app includes a flexible chatbot feature that can be integrated with various LLM providers:

- **Floating Action Button (FAB)** on the Home screen to quickly access the chatbot
- **Multiple LLM Provider Support**:
  - OpenAI integration (GPT-4, GPT-3.5)
  - Google Gemini integration (Gemini Pro)
  - Groq integration (ultra-fast Llama 3 70B model) - **Default**
- **Easy to extend** with additional LLM providers by implementing the `ChatService` interface
- **Model Selection** dialog allows users to switch between different AI models
- **Message history** with conversation persistence
- **Clear conversations** with a single tap
- **Error handling** for failed API requests and missing API keys
- **Graceful degradation** to local mock responses when API services are unavailable

### Setting up API Keys

The app uses environment variables to securely store API keys. Follow these steps to set up your keys:

1. Create a `.env` file in the root of the project by copying the `.env.example` file
2. Add your API keys to the `.env` file:
   ```
   OPENAI_API_KEY=your_openai_api_key_here
   GEMINI_API_KEY=your_gemini_api_key_here
   GROQ_API_KEY=your_groq_api_key_here
   DEFAULT_LLM_PROVIDER=Groq  # Options: OpenAI, Google Gemini, Groq
   ```
3. The app will read these keys at startup and make them available to the chatbot service

**Important**: The `.env` file is included in `.gitignore` to prevent accidentally committing your API keys to version control. Never share your API keys publicly.

#### Where to get API keys:
- **OpenAI API Key**: [OpenAI Platform](https://platform.openai.com/account/api-keys)
- **Google Gemini API Key**: [Google AI Studio](https://aistudio.google.com/)
- **Groq API Key**: [Groq Console](https://console.groq.com/)

#### API Provider Details:

##### Groq
Groq provides ultra-fast inference for LLMs, featuring:
- Access to Llama 3 70B model
- Extremely low latency responses
- Compatible with OpenAI API format
- Free tier available for development
- Perfect for applications requiring quick responses

##### OpenAI
The industry standard for LLMs:
- Access to GPT-4 and GPT-3.5 models
- Extensive capabilities for various tasks
- Well-documented API
- High-quality responses for complex queries

##### Google Gemini
Google's latest multimodal AI model:
- Access to Gemini Pro model
- Strong at reasoning and problem-solving
- Competitive pricing
- Growing feature set

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Create a `.env` file as described above to set up your API keys
4. Run the app with `flutter run`

## App Structure

The app follows a feature-based structure:

```
lib/
├── core/                 # Core functionality and utilities
│   ├── config/           # App configuration
│   ├── constants/        # App constants
│   ├── middleware/       # Route middleware
│   ├── network/          # Networking utilities
│   ├── storage/          # Local storage utilities
│   ├── theme/            # App theming
│   └── utils/            # Utility functions
├── features/             # App features
│   ├── analytics/        # Analytics feature
│   ├── auth/             # Authentication feature
│   ├── calendar/         # Calendar feature
│   ├── chatbot/          # Chatbot feature
│   ├── home/             # Home screen
│   ├── list/             # List feature
│   ├── messages/         # Messages feature
│   ├── profile/          # User profile
│   ├── settings/         # App settings
│   └── splash/           # Splash screen
├── routes/               # App routes
└── main.dart             # App entry point
```

## Environment Configuration

The app uses the `.env` file for environment configuration, managed by the `AppConfig` class. This approach offers:

- Secure API key storage
- Environment-specific configuration
- Easy switching between development and production settings

## Theme Customization

The app includes a comprehensive theming system with:

- Light and dark mode support
- Material You design principles
- Consistent typography and color schemes
- Easy customization of app appearance

## Extending the Chatbot

To add support for a new LLM provider:

1. Create a new implementation of the `ChatService` interface
2. Register the service in the `ChatbotController._initializeChatServices` method
3. Add any required API keys to the `.env` file and `EnvConfig` class
4. Update the model selection dialog in `ChatbotScreen` if needed

## License

This template is provided for educational purposes and may be used as a starting point for your own projects.
