#!/bin/bash

# Make the script executable
chmod +x setup.sh

# Create necessary directories if they don't exist
mkdir -p assets/images
mkdir -p assets/fonts
mkdir -p lib/components
mkdir -p lib/screens
mkdir -p lib/enums
mkdir -p lib/typescale

# Get dependencies
flutter pub get

# Run the app
echo "Setup complete! Run 'flutter run' to start the app."
