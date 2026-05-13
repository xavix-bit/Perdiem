# Perdiem

A daily cost tracker that reveals the true per-day price of your possessions.

Ever wondered how much that laptop *really* costs you each day? Perdiem takes the purchase price and expected lifespan of your items and calculates their daily amortized cost — turning a $1,500 laptop used for 3 years into just $1.37/day. It's long-termism for your wallet.

## Features

- **Daily Cost Calculation** — See exactly what each item costs you per day
- **Smart Categorization** — Organize items by category with custom icons
- **Photo Recognition** — AI-powered image recognition to quickly add items from photos
- **Visual Statistics** — Charts and breakdowns of your spending patterns
- **Usage Tracking** — Monitor how far along you are in each item's expected lifespan
- **Multi-Platform** — Runs on Android, iOS, and macOS

## Screenshots

> Coming soon

## Getting Started

```bash
# Clone the repository
git clone https://github.com/xavix-bit/Perdiem.git
cd Perdiem

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Tech Stack

- **Framework:** Flutter
- **State Management:** Riverpod
- **Database:** SQLite (sqflite)
- **Fonts:** Google Fonts (Outfit + Plus Jakarta Sans)
- **Design:** Custom "Playful Geometric" design system — Memphis-inspired, hard shadows, vibrant colors

## Design System

Perdiem uses a distinctive **Playful Geometric** visual style:

| Token | Value |
|-------|-------|
| Primary | `#6b38d4` (Vivid Purple) |
| Secondary | `#F472B6` (Hot Pink) |
| Tertiary | `#FBBF24` (Amber) |
| Accent | `#34D399` (Emerald) |
| Background | `#FFFDF5` (Warm Cream) |

Typography: **Outfit** for headlines, **Plus Jakarta Sans** for body text.

## Project Structure

```
lib/
├── models/        # Data classes (Item, etc.)
├── providers/     # Riverpod providers & DI
├── repositories/  # Abstract interfaces + SQLite implementation
├── services/      # Database & AI services
├── utils/         # Business logic (CostCalculator)
├── screens/       # Full-page widgets
└── widgets/       # Reusable UI components
```

## License

MIT
