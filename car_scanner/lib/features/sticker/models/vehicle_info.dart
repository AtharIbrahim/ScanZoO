import 'package:equatable/equatable.dart';

class VehicleInfo extends Equatable {
  final String make;
  final String model;
  final int year;
  final String color;
  final String plateNumber;

  const VehicleInfo({
    required this.make,
    required this.model,
    required this.year,
    required this.color,
    required this.plateNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'color': color,
      'plateNumber': plateNumber,
    };
  }

  factory VehicleInfo.fromMap(Map<String, dynamic> map) {
    // Handle year as either int or String from database
    int yearValue = 0;
    if (map['year'] != null) {
      if (map['year'] is int) {
        yearValue = map['year'];
      } else if (map['year'] is String) {
        yearValue = int.tryParse(map['year']) ?? 0;
      }
    }
    
    return VehicleInfo(
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      year: yearValue,
      color: map['color'] ?? '',
      plateNumber: map['plateNumber'] ?? '',
    );
  }

  @override
  List<Object?> get props => [make, model, year, color, plateNumber];
}
