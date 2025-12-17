// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PatientAdapter extends TypeAdapter<Patient> {
  @override
  final int typeId = 0;

  @override
  Patient read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Patient(
      date: fields[0] as String?,
      time: fields[1] as String?,
      name: fields[2] as String,
      edNumber: fields[3] as String,
      age: fields[4] as int,
      gender: fields[5] as String,
      department: fields[6] as String,
      caseType: fields[7] as String,
      diagnosis: fields[8] as String,
      zone: fields[9] as String,
      edOutcome: fields[10] as String,
      treatment: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Patient obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.edNumber)
      ..writeByte(4)
      ..write(obj.age)
      ..writeByte(5)
      ..write(obj.gender)
      ..writeByte(6)
      ..write(obj.department)
      ..writeByte(7)
      ..write(obj.caseType)
      ..writeByte(8)
      ..write(obj.diagnosis)
      ..writeByte(9)
      ..write(obj.zone)
      ..writeByte(10)
      ..write(obj.edOutcome)
      ..writeByte(11)
      ..write(obj.treatment);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatientAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
