# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**日计 (DailyCost)** — A Flutter app that tracks expensive items and calculates their daily amortized cost. Core philosophy: "long-termism" — seeing a ¥15,000 laptop used for 3 years as just ¥13.7/day.

All UI text is in Chinese. The app targets Android, iOS, and macOS.

## Build & Development Commands

```bash
flutter pub get                  # Install dependencies
flutter analyze                  # Static analysis (must pass with no issues)
flutter test                     # Run tests
flutter run                      # Run on connected device
flutter build apk --debug        # Build Android debug APK
flutter build apk --release      # Build Android release APK
flutter build ios                # Build iOS
flutter build macos              # Build macOS
```

**Android mirror note:** The project uses Alibaba Cloud mirrors for Gradle dependencies in `android/settings.gradle.kts`. The Gradle distribution URL in `android/gradle/wrapper/gradle-wrapper.properties` points to a Tencent mirror.

## Architecture

Layered architecture with Repository pattern, state managed by Riverpod:

```
Screens (UI) → Providers (Riverpod) → Repositories (abstract + local impl) → Services (SQLite/HTTP) → Models
```

**Key patterns:**
- **Repository pattern:** `ItemRepository` is abstract; `LocalItemRepository` is the SQLite implementation. Designed for easy swap to Supabase/cloud later.
- **Riverpod for everything:** DI (`databaseServiceProvider` → `itemRepositoryProvider`), async state (`AsyncNotifier` for item list), derived state (`Provider.family` for cost summaries).
- **CostCalculator:** Pure static utility class — all business logic for daily cost, usage progress, cost history. No side effects.
- **Navigation:** Imperative `Navigator.push`/`pop` with `MaterialPageRoute`. No routing library.
- **AI Service:** Supports OpenAI-compatible and Anthropic-format vision APIs for image recognition. Configurable base URL, model, and API key stored in SharedPreferences.

## Directory Structure (lib/)

| Directory | Purpose |
|-----------|---------|
| `models/` | Data classes with `fromMap()`/`toMap()` for SQLite serialization |
| `providers/` | Riverpod providers — DI wiring, state management, derived computations |
| `repositories/` | Abstract interfaces + concrete implementations for data access |
| `services/` | Raw database access (sqflite) and AI service for image recognition |
| `utils/` | Pure business logic (CostCalculator) |
| `screens/` | Full-page widgets, each a ConsumerWidget or ConsumerStatefulWidget |
| `widgets/` | Reusable UI components (GlassCard, GradientButton, etc.) |

## Design System

**"Aurora Glass"** — dark OLED base (#13131b) + indigo-to-cyan gradient (#6366f1 → #06b6d4) + glassmorphism cards.

Full design spec is in `design.md`. Theme tokens are defined in `lib/providers/theme_provider.dart` (both dark and light themes). Light/dark mode is toggled via `themeProvider` and persisted with SharedPreferences.

**Key design tokens:**
- Primary: `#6366f1` (Indigo)
- Secondary: `#06b6d4` (Cyan)
- Background: `#13131b` (Dark)
- Surface: `#1e1e2a` / `#252534`
- Text: `#e4e1ed` (Primary), `#c7c4d7` (Secondary)
- Fonts: Sora (headlines), Plus Jakarta Sans (body)

## Database Schema

Single table `items` in `dailycost.db` (sqflite, version 1):
- `id` (INTEGER PK AUTOINCREMENT), `name`, `brand`, `category`, `price` (REAL), `purchase_date` (TEXT ISO8601), `expected_lifespan_months` (INTEGER), `image_path`, `source` (manual/ai_image/ai_voice), `created_at`, `updated_at`

## AI Image Recognition

The app supports extracting item information from photos using AI vision APIs:

- **Service:** `lib/services/ai_service.dart` — Handles API calls to any OpenAI-compatible or Anthropic-format vision endpoint
- **Config:** `lib/providers/ai_provider.dart` — Stores API key, base URL, and model name in SharedPreferences
- **Supported formats:** OpenAI (`/chat/completions`) and Anthropic (`/v1/messages`)
- **Default config:** Xiaomi MiMo API (`https://api.xiaomimimo.com/v1`, model `mimo-v2.5-pro`)
- **User configuration:** Settings page allows users to configure custom API endpoints

## Planned Features (not yet implemented)

- AI voice input for item entry (UI placeholder reserved)
- Cloud sync via Supabase (Repository pattern already supports swap)
