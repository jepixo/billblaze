// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_properties_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DocumentPropertiesAdapter extends TypeAdapter<DocumentProperties> {
  @override
  final int typeId = 0;

  @override
  DocumentProperties read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DocumentProperties(
      pageNumberController: fields[0] as TextEditingController,
      marginAllController: fields[1] as TextEditingController,
      marginLeftController: fields[2] as TextEditingController,
      marginRightController: fields[3] as TextEditingController,
      marginBottomController: fields[4] as TextEditingController,
      marginTopController: fields[5] as TextEditingController,
      orientationController: fields[6] as PageOrientation,
      pageFormatController: fields[7] as PdfPageFormat,
      useIndividualMargins: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DocumentProperties obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.pageNumberController)
      ..writeByte(1)
      ..write(obj.marginAllController)
      ..writeByte(2)
      ..write(obj.marginLeftController)
      ..writeByte(3)
      ..write(obj.marginRightController)
      ..writeByte(4)
      ..write(obj.marginBottomController)
      ..writeByte(5)
      ..write(obj.marginTopController)
      ..writeByte(6)
      ..write(obj.orientationController)
      ..writeByte(7)
      ..write(obj.pageFormatController)
      ..writeByte(8)
      ..write(obj.useIndividualMargins);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentPropertiesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
