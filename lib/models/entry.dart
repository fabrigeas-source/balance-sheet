enum EntryType {
  expense,
  revenue,
}

class Entry {
  final String id;
  final String description;
  final String? details;
  final double amount;
  final EntryType type;
  final DateTime createdAt;

  Entry({
    required this.id,
    required this.description,
    this.details,
    required this.amount,
    required this.type,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Entry copyWith({
    String? id,
    String? description,
    String? details,
    double? amount,
    EntryType? type,
    DateTime? createdAt,
  }) {
    return Entry(
      id: id ?? this.id,
      description: description ?? this.description,
      details: details ?? this.details,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'details': details,
      'amount': amount,
      'type': type.toString(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      id: json['id'] as String,
      description: json['description'] as String,
      details: json['details'] as String?,
      amount: json['amount'] as double,
      type: EntryType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() =>
      'Entry{id: $id, description: $description, amount: $amount, type: $type}';
}
