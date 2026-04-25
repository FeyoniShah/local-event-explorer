#!/bin/bash
# Run this from inside your local_event_explorer folder

echo "📁 Creating folder structure..."

# Core lib folders
mkdir -p lib/core/theme
mkdir -p lib/core/constants
mkdir -p lib/core/utils
mkdir -p lib/core/errors
mkdir -p lib/core/network

# Features
mkdir -p lib/features/auth/data/models
mkdir -p lib/features/auth/data/repositories
mkdir -p lib/features/auth/presentation/screens
mkdir -p lib/features/auth/presentation/providers

mkdir -p lib/features/events/data/models
mkdir -p lib/features/events/data/repositories
mkdir -p lib/features/events/data/datasources
mkdir -p lib/features/events/presentation/screens
mkdir -p lib/features/events/presentation/widgets
mkdir -p lib/features/events/presentation/providers

mkdir -p lib/features/map/presentation/screens
mkdir -p lib/features/map/presentation/widgets
mkdir -p lib/features/map/presentation/providers

mkdir -p lib/features/notifications/data
mkdir -p lib/features/notifications/presentation

mkdir -p lib/features/profile/data/models
mkdir -p lib/features/profile/presentation/screens
mkdir -p lib/features/profile/presentation/providers

mkdir -p lib/features/onboarding/presentation/screens

# Shared widgets
mkdir -p lib/shared/widgets
mkdir -p lib/shared/extensions

# Routing
mkdir -p lib/routing

# Asset folders
mkdir -p assets/images
mkdir -p assets/icons
mkdir -p assets/animations
mkdir -p assets/fonts

echo "✅ Folder structure created!"
echo ""
echo "📦 Now run: flutter pub get"