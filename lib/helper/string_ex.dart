import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

extension StringHelper on String {
  String get removeZerosInFirst => replaceFirst(RegExp(r'^0+'), '').trim();

  bool get isRTL => intl.Bidi.detectRtlDirectionality(this);

  TextDirection get direction => isRTL ? TextDirection.rtl : TextDirection.ltr;

  String get nameAbbreviation {
    if (trim().isEmpty) return '';
    final List<String> stringList = List.unmodifiable(trim().split(' '));
    String abbreviation =
        stringList.firstOrNull?.substring(0, 1).toUpperCase() ?? '';
    if (stringList.length > 1) {
      abbreviation += stringList.last.substring(0, 1).toUpperCase();
    }
    return abbreviation;
  }
}
