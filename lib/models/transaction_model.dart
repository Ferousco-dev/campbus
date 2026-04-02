enum TransactionType { credit, debit }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? category;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
  });

  bool get isCredit => type == TransactionType.credit;
}

// Sample data
final List<TransactionModel> sampleTransactions = [
  TransactionModel(
    id: '1',
    title: 'Bus Fare — Route 12',
    subtitle: 'Deducted via Student Card',
    amount: 150.00,
    type: TransactionType.debit,
    date: DateTime.now().subtract(const Duration(hours: 2)),
    category: 'transport',
  ),
  TransactionModel(
    id: '2',
    title: 'Wallet Top-up',
    subtitle: 'Via Bank Transfer',
    amount: 5000.00,
    type: TransactionType.credit,
    date: DateTime.now().subtract(const Duration(days: 1)),
    category: 'topup',
  ),
  TransactionModel(
    id: '3',
    title: 'Bus Fare — Route 7',
    subtitle: 'Deducted via Student Card',
    amount: 150.00,
    type: TransactionType.debit,
    date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    category: 'transport',
  ),
  TransactionModel(
    id: '4',
    title: 'Wallet Top-up',
    subtitle: 'Via Paystack',
    amount: 2000.00,
    type: TransactionType.credit,
    date: DateTime.now().subtract(const Duration(days: 3)),
    category: 'topup',
  ),
  TransactionModel(
    id: '5',
    title: 'Purchase — PHY 107',
    subtitle: 'Campus Shop',
    amount: 9550.00,
    type: TransactionType.debit,
    date: DateTime(2025, 11, 15, 19, 25),
    category: 'purchase',
  ),
];
