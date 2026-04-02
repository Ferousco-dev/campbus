enum CardStatus { active, inactive }

class StudentCardModel {
  final String studentId;
  final String fullName;
  final String faculty;
  final String department;
  final String level;
  final String session;
  final String cardNumber; // masked card number tied to student ID
  final CardStatus status;

  const StudentCardModel({
    required this.studentId,
    required this.fullName,
    required this.faculty,
    required this.department,
    required this.level,
    required this.session,
    required this.cardNumber,
    required this.status,
  });

  StudentCardModel copyWith({CardStatus? status}) {
    return StudentCardModel(
      studentId: studentId,
      fullName: fullName,
      faculty: faculty,
      department: department,
      level: level,
      session: session,
      cardNumber: cardNumber,
      status: status ?? this.status,
    );
  }

  bool get isActive => status == CardStatus.active;
}

// Sample data — replace with Supabase auth session
final StudentCardModel sampleStudentCard = StudentCardModel(
  studentId: 'STU/2024/00142',
  fullName: 'Oluwaferanmi',
  faculty: 'Faculty of Engineering',
  department: 'Computer Engineering',
  level: '300L',
  session: '2024/2025',
  cardNumber: '**** **** **** 4281',
  status: CardStatus.inactive,
);
