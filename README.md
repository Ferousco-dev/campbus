# Campus Wallet - Student Transport Wallet App

A production-grade Flutter frontend for a campus transport wallet system. This repo is UI-only; backend services are mocked or stubbed.

---

## Project Structure

```
lib/
|-- main.dart
|-- theme/
|-- models/
|   |-- transaction_model.dart
|   |-- wallet_models.dart
|   |-- shop_item_model.dart
|   |-- student_card_model.dart
|   |-- notification_model.dart
|   `-- admin/
|       `-- admin_models.dart
|-- services/
|   `-- admin/
|       `-- admin_service.dart
|-- screens/
|   |-- auth/
|   |-- wallet/
|   |-- card/
|   |-- shop/
|   |-- profile/
|   |-- admin/
|   `-- shared/
`-- widgets/
    |-- auth/
    |-- wallet/
    |-- card/
    |-- shop/
    |-- profile/
    |-- notifications/
    `-- shared/
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

### 4. Firebase Setup (Auth + Firestore)
1. Create a Firebase project: https://console.firebase.google.com
2. Add an Android app
   - Package name: `com.community.campuswallet` (or your own)
   - Download `google-services.json` → place in `android/app/`
3. Add an iOS app
   - Bundle ID: `com.community.campuswallet` (or your own)
   - Download `GoogleService-Info.plist` → place in `ios/Runner/`
   - Open `ios/Runner.xcworkspace` in Xcode and add the plist to the Runner target
4. Enable **Authentication → Email/Password** in the Firebase console
5. Create a **Firestore** database (start in test mode for development)
6. (Optional) If you need web/macos config, run:
```bash
flutterfire configure
```
7. Note: Firebase Auth sends a reset **link** by default. If you need email OTPs,
   you'll need a backend (Cloud Functions + email provider). The UI can be wired
   once that service exists.

### 5. Run
```bash
flutter run
```

---

## Backend Integration Guide (for backend dev)

This app currently uses mock data and stubbed services. Replace these with real API calls and wire responses into the UI.

### Current Stubbed Sources
- `lib/services/admin/admin_service.dart` contains TODO endpoints for the Admin console.
- `lib/models/transaction_model.dart` uses `sampleTransactions`.
- `lib/models/wallet_models.dart` uses `walletTransactions`, `weeklySpending`, `monthlySpending`.
- `lib/models/shop_item_model.dart` uses `sampleShopItems`.
- `lib/models/student_card_model.dart` uses `sampleStudentCard`.
- `lib/models/notification_model.dart` uses `sampleNotifications`.
- `lib/models/admin/admin_models.dart` contains admin mock data lists.

### UI Connection Points (by feature)
- Auth and onboarding: `lib/screens/auth/*`
- Profile and settings: `lib/screens/profile/*`, `lib/widgets/profile/*`
- Wallet summary and history: `lib/screens/home_screen.dart`, `lib/screens/wallet_screen.dart`, `lib/screens/transactions_screen.dart`
- Top-up and transfers: `lib/widgets/wallet/add_funds_sheet.dart`, `lib/screens/wallet/payment_provider_screen.dart`, `lib/screens/wallet/send_money_screen.dart`, `lib/widgets/shared/pin_confirmation_sheet.dart`
- Card and transport: `lib/screens/card_screen.dart`, `lib/screens/card/pay_bus_screen.dart`, `lib/models/student_card_model.dart`
- Shop and checkout: `lib/screens/shop_screen.dart`, `lib/screens/shop/checkout_screen.dart`, `lib/screens/shop/cart_screen.dart`, `lib/screens/shop/wifi_ticket_screen.dart`
- Notifications: `lib/screens/notifications_screen.dart`
- Admin console: `lib/screens/admin/*`, `lib/services/admin/admin_service.dart`

### Suggested API Surface (User App)

Auth and onboarding:
- Register user (fields from `CreateAccountScreen`): fullName, matricNumber, email, phone, dateOfBirth, gender
- Set login code (6 digits) from `SetCodeScreen`
- Login with 6-digit code from `LoginScreen` (device-based or username + code)
- Forgot password flow: send 4-digit OTP, verify OTP, reset login code

Profile and settings:
- Fetch profile summary (name, nickname, studentId, tier, verification status)
- Update nickname (`EditNicknameScreen`)
- Update address (`EditAddressScreen`)
- Upload or remove avatar (`ProfileHeaderCard`)
- Security settings: biometricEnabled, loginAlertsEnabled (`SecurityCenterScreen`)
- Change transaction PIN (4 digits) and login password (`SecurityCenterScreen`)
- Active sessions list (`SecurityCenterScreen`)
- Referral code and share link (`InviteFriendsScreen`)

Wallet:
- Wallet summary (balance, monthlyIncome, monthlySpent)
- Wallet transactions list (see `WalletTransaction` model)
- Spending chart data (weekly/monthly `SpendingDataPoint`)
- Top-up initiation (card, bank transfer, USSD) and verification
- Transfer to nickname or studentId with PIN verification
- Receipt metadata (receiptStatus, receiptId, reference)

Transport and card:
- Student card details and status (active/inactive)
- Card activation/deactivation
- Available vehicles/routes list for Pay Transport
- Fare payment (creates transport transaction and receipt)

Shop and purchases:
- Shop items list with category, availability, stockCount, pricing
- Checkout using wallet balance
- Purchases list for `My Purchases`
- WiFi ticket issuance (username, password, planName, duration, issueDate)

Notifications:
- List notifications with filter by type
- Mark single notification read
- Mark all read
- Delete notification

### Admin API Surface (already stubbed in code)

`lib/services/admin/admin_service.dart` defines these endpoints:
- GET `/api/admin/users`
- GET `/api/admin/users/:id`
- PATCH `/api/admin/users/:id/card-status`
- PATCH `/api/admin/users/:id/tier`
- GET `/api/admin/transactions?page=&filter=&category=`
- POST `/api/admin/transactions/refund`
- GET `/api/admin/routes`
- PATCH `/api/admin/routes/:id`
- GET `/api/admin/vehicles`
- PATCH `/api/admin/vehicles/:id/status`
- GET `/api/admin/shop/items`
- POST `/api/admin/shop/items`
- PATCH `/api/admin/shop/items/:id`
- DELETE `/api/admin/shop/items/:id`
- GET `/api/admin/support/tickets`
- POST `/api/admin/support/tickets/:id/reply`
- PATCH `/api/admin/support/tickets/:id/resolve`
- GET `/api/admin/notifications`
- POST `/api/admin/notifications/send`
- GET `/api/admin/roles`
- PATCH `/api/admin/roles/:id`
- GET `/api/admin/audit-log`
- GET `/api/admin/dashboard/kpis`

---

## Model Reference (fields used by UI)

User profile:
- id, fullName, nickname, studentId, email, phone, faculty, department, level, tier
- isVerified, isEmailVerified, avatarUrl, address (street, city), referralCode

Wallet summary:
- balance, monthlyIncome, monthlySpent

WalletTransaction (see `lib/models/wallet_models.dart`):
- id, title, subtitle, amount, type, category, date
- receiptStatus, receiptId, reference

SpendingDataPoint:
- label, amount

StudentCard:
- studentId, fullName, faculty, department, level, session, cardNumber, status

ShopItem (see `lib/models/shop_item_model.dart`):
- id, name, description, price, category, availability
- tag, originalPrice, stockCount, isRecurring, imageUrl or iconKey

Notification:
- id, title, message, timestamp, isRead, type, amount, isCredit

AdminUser:
- id, fullName, nickname, studentId, email, phone, faculty, department, level
- tier, walletBalance, cardStatus, isVerified, isEmailVerified
- joinDate, totalTransactions, totalSpent

AdminRoute:
- id, name, from, to, fare, status, vehicleCount
- dailyRevenue, monthlyRevenue, dailyPassengers, operatingHours

AdminVehicle:
- id, plateNumber, routeId, routeName, capacity, status, driverName, driverPhone

SupportTicket:
- id, userId, userName, subject, status, priority, createdAt, resolvedAt
- messages: { sender, senderName, message, timestamp }

AdminNotification:
- id, title, message, type, audience, sentAt, delivered, total

AuditLogEntry:
- id, adminName, action, target, timestamp, ipAddress, module

---

## Enum Values (as used in UI)

- TransactionType: credit, debit
- WalletTxType: credit, debit
- TxCategory: transport, topup, purchase, subscription, refund, wifi
- ReceiptStatus: available, pending, notAvailable
- NotificationType: transaction, system, promo, trip
- CardStatus: active, inactive
- ShopCategory: wifi, campusLife, academic
- AvailabilityStatus: available, limited, unavailable, comingSoon
- AdminUserTier: tier1, tier2, tier3
- AdminCardStatus: active, inactive, blocked
- RouteStatus: active, inactive, underMaintenance
- VehicleStatus: active, inactive, maintenance
- TicketStatus: open, inProgress, resolved, closed
- TicketPriority: low, medium, high, urgent
- AdminRole: superAdmin, moderator, supportAgent, shopManager

---

## Data Conventions

- Amounts are numeric in NGN; the UI handles formatting.
- Dates should be ISO-8601 strings and parsed into `DateTime`.
- IDs are treated as strings across the UI.
- For shop icons, backend can provide an `iconKey` (mapped in the app) or an `imageUrl`.

---

## Design System

- Primary: `#1A3FD8` (Deep Blue)
- Background: `#F5F7FF`
- Success: `#00B37E`
- Error: `#E03E3E`
- Font: Sora (Google Fonts)
