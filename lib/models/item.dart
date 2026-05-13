class Item {
  final int? id;
  final String name;
  final String? brand;
  final String? category;
  final double price;
  final DateTime purchaseDate;
  final int expectedLifespanMonths;
  final String? imagePath;
  final String source; // 'manual' | 'ai_image' | 'ai_voice'
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    this.id,
    required this.name,
    this.brand,
    this.category,
    required this.price,
    required this.purchaseDate,
    required this.expectedLifespanMonths,
    this.imagePath,
    this.source = 'manual',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Item copyWith({
    int? id,
    String? name,
    String? brand,
    String? category,
    double? price,
    DateTime? purchaseDate,
    int? expectedLifespanMonths,
    String? imagePath,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      price: price ?? this.price,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expectedLifespanMonths:
          expectedLifespanMonths ?? this.expectedLifespanMonths,
      imagePath: imagePath ?? this.imagePath,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'] as int?,
      name: map['name'] as String,
      brand: map['brand'] as String?,
      category: map['category'] as String?,
      price: (map['price'] as num).toDouble(),
      purchaseDate: DateTime.parse(map['purchase_date'] as String),
      expectedLifespanMonths: map['expected_lifespan_months'] as int,
      imagePath: map['image_path'] as String?,
      source: map['source'] as String? ?? 'manual',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'price': price,
      'purchase_date': purchaseDate.toIso8601String(),
      'expected_lifespan_months': expectedLifespanMonths,
      'image_path': imagePath,
      'source': source,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'Item(id: $id, name: $name, price: $price)';
}
