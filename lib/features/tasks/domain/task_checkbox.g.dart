// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_checkbox.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskCheckbox _$TaskCheckboxFromJson(Map<String, dynamic> json) =>
    _TaskCheckbox(
      id: json['id'] as String,
      label: json['label'] as String,
      isChecked: json['isChecked'] as bool? ?? false,
    );

Map<String, dynamic> _$TaskCheckboxToJson(_TaskCheckbox instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'isChecked': instance.isChecked,
    };
