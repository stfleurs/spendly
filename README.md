# Receet Pro — Envelope-Based Budgeting That Gives You Answers

**Stop wondering if you can afford it. Know exactly what's available.**

Receet Pro is a cross-platform personal finance app built with Flutter and Firebase that uses the proven envelope budgeting method. Instead of asking you to track every penny after you spend it, Receet Pro helps you decide *before* you spend — by putting money into digital envelopes and showing you real-time balances across every category of your life.

---

## Features

### 📨 Envelope Budgeting
Divide your income into spending categories (envelopes) for groceries, gas, dining, fun, savings, and more. Each envelope shows a live balance. When it hits zero, you stop spending in that category. Simple, honest, and effective.

### 📷 Smart Receipt Scanning
Snap a photo of any receipt. The built-in OCR engine (powered by Google ML Kit) reads the merchant, total, and line items, then automatically categorizes the transaction into the right envelope. No manual data entry needed.

### 📊 Insights & Reports
Beautiful, interactive charts powered by fl_chart. See where your money goes, compare month-over-month spending, track net worth over time, and export detailed reports in CSV or PDF format.

### 💳 Multi-Account Support
Track checking accounts, savings accounts, credit cards, and cash all in one place. Get a complete picture of your finances with automatic net worth calculations and real-time balance updates across all accounts.

### 🔄 Recurring Bills & Upcoming Payments
Set up bills and subscriptions that repeat on any schedule. Get push notifications before payments are due. Track planned spending alongside your envelope balances so nothing catches you off guard.

### 📁 Import & Export
Import existing transaction history from CSV or PDF bank statements. Export your data anytime in CSV or PDF format. You own your financial data — always.

### 💱 Multi-Currency & Localization
Full support for USD, EUR, HTG, and CAD with real-time exchange rate conversion. The app is localized in English, French, and Haitian Creole.

### 🔒 Security & Privacy
Optional PIN/biometric lock. End-to-end encryption for sensitive data. Firebase Authentication with Google Sign-In support. Bank-level 256-bit encryption in transit and at rest.

---

## Free Online Calculators

No signup needed. Use these tools right now in your browser:

| Calculator | Description |
|---|---|
| [Budget Planner](https://stfleurs.github.io/spendly/budget-calculator) | Plan spending across 8+ categories with live charts |
| [Paycheck Budget Calculator](https://stfleurs.github.io/spendly/paycheck-calculator) | Budget by paycheck with envelope allocations |
| [Emergency Fund Calculator](https://stfleurs.github.io/spendly/emergency-fund-calculator) | Calculate your safety net and time to goal |
| [Debt Payoff Calculator](https://stfleurs.github.io/spendly/debt-payoff-calculator) | Compare snowball vs avalanche payoff methods |
| [Subscription Cost Calculator](https://stfleurs.github.io/spendly/subscription-calculator) | See the true cost of your subscriptions |
| [50/30/20 Calculator](https://stfleurs.github.io/spendly/50-30-20-calculator) | Apply the popular budgeting rule |
| [Envelope Budgeting Guide](https://stfleurs.github.io/spendly/envelope-budgeting-guide) | Learn how envelope budgeting works |

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (3.x, Dart) |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Data Models** | Freezed + `json_serializable` |
| **Backend** | Firebase Auth, Cloud Firestore, Cloud Storage |
| **Observability** | Firebase Crashlytics, Analytics, Performance |
| **Monetization** | RevenueCat (`purchases_flutter`) |
| **OCR** | Google ML Kit Text Recognition |
| **Charts** | fl_chart |
| **Localization** | Flutter l10n (English, French, Haitian Creole) |
| **CI/CD** | GitHub Actions |

---

## Architecture

The project follows a **feature-based** architecture with clear separation of concerns:

```
lib/
├── core/           # Shared models, providers, services, utils
│   ├── models/     # Freezed data models (Account, Transaction, Budget, etc.)
│   ├── providers/  # Global providers (auth, locale, currency, etc.)
│   ├── services/   # Business logic (OCR, export, subscriptions, etc.)
│   └── utils/      # Formatters, converters
├── features/       # Feature modules
│   ├── accounts/   # Account management (repository + views)
│   ├── auth/       # Authentication, onboarding
│   ├── budget/     # Envelope budget management
│   ├── home/       # Dashboard, main navigation
│   ├── import/     # CSV/PDF import
│   ├── ocr/        # Receipt scanning and parsing
│   ├── reports/    # Financial reports
│   ├── settings/   # App settings, premium paywall
│   ├── transactions/ # Transaction management
│   └── upcoming/   # Bills and recurring payments
├── shared/         # Shared UI components
│   ├── themes/     # App theme (colors, typography)
│   └── widgets/    # Reusable widgets (header, lock screen, cards)
└── generated/      # Generated code (localizations)
```

Each feature module follows a `Repository → Provider → View` pattern, making the codebase predictable and easy to navigate.

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Firebase CLI
- Android Studio / Xcode (for platform builds)

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Freezed/JSON code
dart run build_runner build

# 3. Configure Firebase
firebase login
flutterfire configure

# 4. Run the app
flutter run
```

---

## Website

The marketing website and free budgeting tools are in the `docs/` directory (live at [receetpro.web.app](https://receetpro.web.app)):

```
docs/
├── index.html                    # Landing page with Spending Capacity Calculator
├── budget-calculator.html        # Full budget planner
├── paycheck-calculator.html      # Paycheck-based budgeting
├── emergency-fund-calculator.html
├── debt-payoff-calculator.html   # Snowball vs Avalanche
├── subscription-calculator.html  # Subscription cost tracker
├── 50-30-20-calculator.html      # 50/30/20 rule calculator
├── envelope-budgeting-guide.html # Educational guide
├── css/style.css                 # Design system
└── js/main.js                    # Interactive calculator logic
```

The site is fully static — no build step, no framework. Open `index.html` in any browser.

---

## Testing

```bash
flutter test
```

Test coverage includes:
- Account repository logic
- Category/budget repository
- Currency formatting utilities
- Exchange rate calculations
- Historical stability analysis
- Receipt text parsing
- Transaction ledger integrity
- Resilience and error handling
- Localization audit

---

## License

Private project. All rights reserved.
