# CampusRide — Student Transport Wallet App

A clean, production-grade Flutter frontend for a campus transport wallet system.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme/
│   └── app_theme.dart           # Colors, typography, theme config
├── models/
│   └── transaction_model.dart   # Transaction data model + sample data
├── utils/
│   └── app_utils.dart           # Currency & date formatters
├── screens/
│   ├── main_shell.dart          # Bottom nav shell
│   ├── home_screen.dart         # Home / dashboard
│   └── transactions_screen.dart # Full transaction history
└── widgets/
    ├── balance_card.dart              # Hero balance card
    ├── stats_row.dart                 # Credits / Debits stat tiles
    ├── quick_actions_grid.dart        # 2x2 action grid
    ├── recent_transactions_section.dart # Transactions preview
    ├── transaction_list_item.dart     # Single transaction row
    └── app_bottom_nav_bar.dart        # Bottom navigation bar
```

---

## Setup

### 1. Add Sora Font
Download Sora from Google Fonts: https://fonts.google.com/specimen/Sora

Place the font files in `assets/fonts/`:
- `Sora-Regular.ttf`
- `Sora-Medium.ttf`
- `Sora-SemiBold.ttf`
- `Sora-Bold.ttf`

### 2. Create Assets Folders
```bash
mkdir -p assets/fonts assets/images
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run
```bash
flutter run
```

---

## Backend Integration Notes (for your dev)

The app uses placeholder/sample data. Replace these with real API calls:

| Widget / Screen | Replace with |
|---|---|
| `sampleTransactions` in `transaction_model.dart` | Supabase query from `transactions` table |
| `balance: 50.00` in `home_screen.dart` | Supabase user wallet balance |
| `userName: 'Oluwaferanmi'` | Auth session user name |
| `STU/2024/00142` in `balance_card.dart` | Student ID from user profile |
| `onTap: () {}` on Deposit/Transfer buttons | Navigate to deposit/transfer screens |

---

## Design System

- **Primary**: `#1A3FD8` (Deep Blue)
- **Background**: `#F5F7FF`  
- **Success**: `#00B37E`
- **Error**: `#E03E3E`
- **Font**: Sora (Google Fonts)
