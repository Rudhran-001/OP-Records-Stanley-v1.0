import 'package:hive/hive.dart';

part 'patient.g.dart';  // Ensure this line is present

@HiveType(typeId: 0)  // Ensure typeId is unique
class Patient extends HiveObject {
  @HiveField(0)
  String? date;  // New field

  @HiveField(1)
  String? time;  // New field

  @HiveField(2)
  String name;

  @HiveField(3)
  String edNumber;

  @HiveField(4)
  int age;

  @HiveField(5)
  String gender;

  @HiveField(6)
  String department;

  @HiveField(7)
  String caseType;

  @HiveField(8)
  String diagnosis;

  @HiveField(9)
  String zone;

  @HiveField(10)
  String edOutcome;

  @HiveField(11)
  String treatment;  // New field

  Patient({
    required this.date,
    required this.time,
    required this.name,
    required this.edNumber,
    required this.age,
    required this.gender,
    required this.department,
    required this.caseType,
    required this.diagnosis,
    required this.zone,
    required this.edOutcome,
    required this.treatment,
  });
}
