import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DevAccountPage {
  final List<DevAccountItem> items;
  final int totalSize;
  final int offset;

  DevAccountPage({
    required this.items,
    required this.totalSize,
    required this.offset,
  });

  factory DevAccountPage.fromJson(dynamic json) {
    if (json is String) json = jsonDecode(json);

    final List dataList = (json['transactions'] ?? []) as List;
    final int total = (json['total_size'] ?? dataList.length) as int;
    final int off = (json['offset'] ?? 1) as int;

    return DevAccountPage(
      items: dataList.map((e) => DevAccountItem.fromJson(e)).toList(),
      totalSize: total,
      offset: off,
    );
  }
}

enum DevItemTarget {
  wallet("wallet_top_up"),
  debt("settle_deferred_profits"),
  order("order");

  final String _name;
  String get name => _name.tr;

  const DevItemTarget(this._name);

  
  factory DevItemTarget.fromJson(String? string) {
    for (DevItemTarget e in values) {
      if (e.name == string) return e;
    }
    return order;
  }

  String? get toJson {
    if(this == order) return null;
    return name;
  }

  Color get color {
    switch (this) {
      case wallet:
        return Colors.green;
      case debt:
        return Colors.red;
      case order:
        return Get.theme.primaryColor;
    }
  }

}

class DevAccountItem {
  final int? id;
  final String? inOut;            // "in" | "out"
  final DevItemTarget? target;    // "wallet" | "debt" | null
  final String? payMethod;        // "cash_on_delivery" | "digital_payment" | "vc" | ...
  final String? orderPayType;     // قد تكون null
  final int? orderId;             // قد تكون null
  final double? orderTotal;       // قد تكون null
  final double? value;            // المبلغ الأساسي
  final double? debt;             // مديونية الحركة
  final String? date;             // raw
  final String? dateFormatted;    // localized string

  DevAccountItem({
    this.id,
    this.inOut,
    this.target,
    this.payMethod,
    this.orderPayType,
    this.orderId,
    this.orderTotal,
    this.value,
    this.debt,
    this.date,
    this.dateFormatted,
  });

  factory DevAccountItem.fromJson(Map<String, dynamic> json) {
    double? _d(v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? _i(v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    return DevAccountItem(
      id: _i(json['id']),
      inOut: json['in_out']?.toString(),
      target: DevItemTarget.fromJson("${json['target']}"),
      payMethod: json['pay_method']?.toString(),
      orderPayType: json['order_pay_type']?.toString(),
      orderId: _i(json['order_id']),
      orderTotal: _d(json['order_total']),
      value: _d(json['value']),
      debt: _d(json['debt']),
      date: json['date']?.toString(),
      dateFormatted: json['date_formatted']?.toString(),
    );
  }
}
