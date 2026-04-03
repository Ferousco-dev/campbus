import 'package:cloud_firestore/cloud_firestore.dart';
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

  factory WalletTransaction.fromFirestore(Map<String, dynamic> data, String id) {
    final rawType = (data['type'] as String?)?.toLowerCase();
    final rawCategory = (data['category'] as String?)?.toLowerCase();
    final rawStatus = (data['receiptStatus'] as String?)?.toLowerCase();
    final rawDate = data['date'];

    DateTime date;
    if (rawDate is Timestamp) {
      date = rawDate.toDate();
    } else if (rawDate is DateTime) {
      date = rawDate;
    } else {
      date = DateTime.now();
    }

    return WalletTransaction(
      id: id,
      title: data['title'] as String? ?? 'Transaction',
      subtitle: data['subtitle'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: _txTypeFromString(rawType),
      category: _categoryFromString(rawCategory),
      date: date,
      receiptStatus: _receiptStatusFromString(rawStatus),
      receiptId: data['receiptId'] as String?,
      reference: data['reference'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'subtitle': subtitle,
      'amount': amount,
      'type': _txTypeToString(type),
      'category': _categoryToString(category),
      'date': Timestamp.fromDate(date),
      'receiptStatus': _receiptStatusToString(receiptStatus),
      if (receiptId != null) 'receiptId': receiptId,
      if (reference != null) 'reference': reference,
    };
  }

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

WalletTxType _txTypeFromString(String? value) {
  switch (value) {
    case 'credit':
      return WalletTxType.credit;
    case 'debit':
      return WalletTxType.debit;
    default:
      return WalletTxType.debit;
  }
}

String _txTypeToString(WalletTxType type) {
  return type == WalletTxType.credit ? 'credit' : 'debit';
}

TxCategory _categoryFromString(String? value) {
  switch (value) {
    case 'transport':
      return TxCategory.transport;
    case 'topup':
      return TxCategory.topup;
    case 'purchase':
      return TxCategory.purchase;
    case 'subscription':
      return TxCategory.subscription;
    case 'refund':
      return TxCategory.refund;
    case 'wifi':
      return TxCategory.wifi;
    default:
      return TxCategory.transport;
  }
}

String _categoryToString(TxCategory category) {
  switch (category) {
    case TxCategory.transport:
      return 'transport';
    case TxCategory.topup:
      return 'topup';
    case TxCategory.purchase:
      return 'purchase';
    case TxCategory.subscription:
      return 'subscription';
    case TxCategory.refund:
      return 'refund';
    case TxCategory.wifi:
      return 'wifi';
  }
}

ReceiptStatus _receiptStatusFromString(String? value) {
  switch (value) {
    case 'available':
      return ReceiptStatus.available;
    case 'pending':
      return ReceiptStatus.pending;
    case 'notavailable':
    case 'not_available':
    case 'notAvailable':
      return ReceiptStatus.notAvailable;
    default:
      return ReceiptStatus.notAvailable;
  }
}

String _receiptStatusToString(ReceiptStatus status) {
  switch (status) {
    case ReceiptStatus.available:
      return 'available';
    case ReceiptStatus.pending:
      return 'pending';
    case ReceiptStatus.notAvailable:
      return 'notAvailable';
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
