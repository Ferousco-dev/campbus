import 'package:flutter/material.dart';

// ─── Enums ──────────────────────────────────────────────────────
enum WalletTxType { credit, debit }

enum TxCategory { transport, topup, purchase, subscription, refund, wifi }

enum ReceiptStatus { available, pending, notAvailable }

// ─── Spending Data (for chart) ──────────────────────────────────
class SpendingDataPoint {
  final String label; // "Mon", "Tue" or "Week 1", "Feb"
  final double amount;

  const SpendingDataPoint({required this.label, required this.amount});
}

// ─── Wallet Transaction ─────────────────────────────────────────
class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final WalletTxType type;
  final TxCategory category;
  final DateTime date;
  final ReceiptStatus receiptStatus;
  final String? receiptId;
  final String? reference;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.receiptStatus = ReceiptStatus.notAvailable,
    this.receiptId,
    this.reference,
  });

  bool get isCredit => type == WalletTxType.credit;
  bool get hasReceipt => receiptStatus == ReceiptStatus.available;

  IconData get categoryIcon {
    switch (category) {
      case TxCategory.transport:
        return Icons.directions_bus_rounded;
      case TxCategory.topup:
        return Icons.add_circle_outline_rounded;
      case TxCategory.purchase:
        return Icons.shopping_bag_outlined;
      case TxCategory.subscription:
        return Icons.autorenew_rounded;
      case TxCategory.refund:
        return Icons.replay_rounded;
      case TxCategory.wifi:
        return Icons.wifi_rounded;
    }
  }

  Color get categoryColor {
    switch (category) {
      case TxCategory.transport:
        return const Color(0xFF1A3FD8);
      case TxCategory.topup:
        return const Color(0xFF00B37E);
      case TxCategory.purchase:
        return const Color(0xFF9B5CF6);
      case TxCategory.subscription:
        return const Color(0xFFE08C00);
      case TxCategory.refund:
        return const Color(0xFF00A3CC);
      case TxCategory.wifi:
        return const Color(0xFF5C7CFA);
    }
  }

  Color get categoryBgColor {
    switch (category) {
      case TxCategory.transport:
        return const Color(0xFFEEF2FF);
      case TxCategory.topup:
        return const Color(0xFFE6FAF4);
      case TxCategory.purchase:
        return const Color(0xFFF3EEFF);
      case TxCategory.subscription:
        return const Color(0xFFFFF6E5);
      case TxCategory.refund:
        return const Color(0xFFE5F8FC);
      case TxCategory.wifi:
        return const Color(0xFFEDF1FF);
    }
  }

  String get categoryLabel {
    switch (category) {
      case TxCategory.transport:
        return 'Transport';
      case TxCategory.topup:
        return 'Top-up';
      case TxCategory.purchase:
        return 'Purchase';
      case TxCategory.subscription:
        return 'Subscription';
      case TxCategory.refund:
        return 'Refund';
      case TxCategory.wifi:
        return 'WiFi';
    }
  }
}

// ─── Sample Wallet Transactions (10 items) ──────────────────────
final List<WalletTransaction> walletTransactions = [
  WalletTransaction(
    id: 'w1',
    title: 'Bus Fare — Route 12',
    subtitle: 'Deducted via Student Card',
    amount: 150.00,
    type: WalletTxType.debit,
    category: TxCategory.transport,
    date: DateTime.now().subtract(const Duration(hours: 1)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0401-001',
    reference: 'TXN-BUS12-0401',
  ),
  WalletTransaction(
    id: 'w2',
    title: 'Wallet Top-up',
    subtitle: 'Via Paystack · ****4521',
    amount: 5000.00,
    type: WalletTxType.credit,
    category: TxCategory.topup,
    date: DateTime.now().subtract(const Duration(hours: 4)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0401-002',
    reference: 'PAY-TOP-0401',
  ),
  WalletTransaction(
    id: 'w3',
    title: 'Bus Fare — Route 7',
    subtitle: 'Deducted via Student Card',
    amount: 150.00,
    type: WalletTxType.debit,
    category: TxCategory.transport,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0331-003',
    reference: 'TXN-BUS7-0331',
  ),
  WalletTransaction(
    id: 'w4',
    title: 'Campus WiFi — 7 days',
    subtitle: 'WiFi access package',
    amount: 500.00,
    type: WalletTxType.debit,
    category: TxCategory.wifi,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
    receiptStatus: ReceiptStatus.pending,
    reference: 'WIFI-7D-0331',
  ),
  WalletTransaction(
    id: 'w5',
    title: 'Refund — Route 3 Cancelled',
    subtitle: 'Automatic refund',
    amount: 150.00,
    type: WalletTxType.credit,
    category: TxCategory.refund,
    date: DateTime.now().subtract(const Duration(days: 2)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0330-005',
    reference: 'REF-BUS3-0330',
  ),
  WalletTransaction(
    id: 'w6',
    title: 'PHY 107 Lab Manual',
    subtitle: 'Campus Shop',
    amount: 3500.00,
    type: WalletTxType.debit,
    category: TxCategory.purchase,
    date: DateTime.now().subtract(const Duration(days: 3)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0329-006',
    reference: 'SHOP-PHY107-0329',
  ),
  WalletTransaction(
    id: 'w7',
    title: 'Wallet Top-up',
    subtitle: 'Via Bank Transfer',
    amount: 10000.00,
    type: WalletTxType.credit,
    category: TxCategory.topup,
    date: DateTime.now().subtract(const Duration(days: 4)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0328-007',
    reference: 'BNK-TOP-0328',
  ),
  WalletTransaction(
    id: 'w8',
    title: 'Bus Fare — Route 5',
    subtitle: 'Deducted via Student Card',
    amount: 200.00,
    type: WalletTxType.debit,
    category: TxCategory.transport,
    date: DateTime.now().subtract(const Duration(days: 5)),
    receiptStatus: ReceiptStatus.notAvailable,
    reference: 'TXN-BUS5-0327',
  ),
  WalletTransaction(
    id: 'w9',
    title: 'Monthly Bus Pass',
    subtitle: 'Subscription · Apr 2026',
    amount: 4500.00,
    type: WalletTxType.debit,
    category: TxCategory.subscription,
    date: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0327-009',
    reference: 'SUB-MPASS-0327',
  ),
  WalletTransaction(
    id: 'w10',
    title: 'Wallet Top-up',
    subtitle: 'Via USSD · *737#',
    amount: 2000.00,
    type: WalletTxType.credit,
    category: TxCategory.topup,
    date: DateTime.now().subtract(const Duration(days: 6)),
    receiptStatus: ReceiptStatus.available,
    receiptId: 'RCP-2026-0326-010',
    reference: 'USSD-TOP-0326',
  ),
];

// ─── Weekly Spending Data ─────────────────────────────────────
final List<SpendingDataPoint> weeklySpending = [
  const SpendingDataPoint(label: 'Mon', amount: 150),
  const SpendingDataPoint(label: 'Tue', amount: 650),
  const SpendingDataPoint(label: 'Wed', amount: 300),
  const SpendingDataPoint(label: 'Thu', amount: 4200),
  const SpendingDataPoint(label: 'Fri', amount: 200),
  const SpendingDataPoint(label: 'Sat', amount: 500),
  const SpendingDataPoint(label: 'Sun', amount: 0),
];

// ─── Monthly Spending Data ─────────────────────────────────────
final List<SpendingDataPoint> monthlySpending = [
  const SpendingDataPoint(label: 'Oct', amount: 8200),
  const SpendingDataPoint(label: 'Nov', amount: 12400),
  const SpendingDataPoint(label: 'Dec', amount: 6000),
  const SpendingDataPoint(label: 'Jan', amount: 15300),
  const SpendingDataPoint(label: 'Feb', amount: 9800),
  const SpendingDataPoint(label: 'Mar', amount: 11500),
];
