class AhpResultDetailDto {
  final String? id;
  final String name;
  final double value;

  AhpResultDetailDto({
    required this.id,
    required this.name,
    required this.value,
  });

  factory AhpResultDetailDto.fromMap(Map<String, dynamic> map) {
    return AhpResultDetailDto(
      id: map['id'],
      name: map['name'],
      value: (map['value'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }
}
