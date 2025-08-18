import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_button_widget.dart';
import '../../../common/widgets/custom_dropdown_widget.dart';
import '../../../common/widgets/text_field_widget.dart';
import '../../../util/dimensions.dart';
import '../../language/controllers/language_controller.dart';

class DevAccountsFilterBarWidget extends StatefulWidget {
  final void Function({
    String? inOut,
    String? target,
    String? payMethod,
    int? orderId,
    String? from,
    String? to,
    String? search,
  }) onApply;

  final VoidCallback onReset;

  final String? inOut;
  final String? target;
  final String? payMethod;
  final int? orderId;
  final String? from;
  final String? to;
  final String? search;
  final Set<String> paymentsMethod;


  const DevAccountsFilterBarWidget({
    super.key,
    required this.onApply,
    required this.onReset,
    this.inOut,
    this.target,
    this.payMethod,
    this.orderId,
    this.from,
    this.to,
    this.search,
    this.paymentsMethod = const {},
  });

  @override
  State<DevAccountsFilterBarWidget> createState() => _DevAccountsFilterBarWidgetState();
}

class _DevAccountsFilterBarWidgetState extends State<DevAccountsFilterBarWidget> {
  final _orderIdCtrl = TextEditingController();
  final _fromCtrl = TextEditingController();
  final _toCtrl = TextEditingController();

  DateTime? fromDate;
  DateTime? toDate;

  String? _inOut;
  String? _target;
  String? _payMethod;

  Set<(String?, String)> paymentsMethods = {
    (null, 'all'.tr),
  };

  final Set<String> _payments = {
    'cash_on_delivery',
    'digital_payment',
    'vc',
  };


  @override
  void initState() {
    super.initState();
    _inOut = widget.inOut;
    _target = widget.target;
    _payMethod = widget.payMethod;
    if (widget.orderId != null) _orderIdCtrl.text = widget.orderId.toString();
    if (widget.from != null) _fromCtrl.text = widget.from!;
    if (widget.to != null) _toCtrl.text = widget.to!;

    _payments.addAll(widget.paymentsMethod);

    for (String element in _payments) {
      paymentsMethods.add((element.toLowerCase(), element.tr));
    }

  }

  @override
  void dispose() {
    _orderIdCtrl.dispose();
    _fromCtrl.dispose();
    _toCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller, {DateTime? first, DateTime? last, void Function(DateTime)? onChanged}) async {
    final now = DateTime.now();
    final firstTemp = first ?? DateTime(now.year - 2);
    final initial = DateTime.tryParse(controller.text) ?? first ?? last ?? now;
    final picked = await showDatePicker(
      locale: Get.find<LocalizationController>().locale,
      context: context,
      initialDate: initial,
      firstDate: firstTemp,
      lastDate: last ?? now,
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T').first;
      onChanged?.call(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    const gapH = SizedBox(height: Dimensions.paddingSizeSmall);
    const gapW = SizedBox(width: Dimensions.paddingSizeSmall);

    return Card(
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('filters'.tr, style: Theme.of(context).textTheme.titleMedium),

            // Row 1: in_out, target, pay_method
            const SizedBox(height: Dimensions.paddingSizeSmall),
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth > 700;

                final inOutDrop = _buildDropdown(
                  label: 'in_out'.tr,
                  value: _inOut,
                  options: [
                    (null, 'all'.tr),
                    ('in', 'in'.tr),
                    ('out', 'out'.tr),
                  ],
                  onChanged: (v) => setState(() => _inOut = v),
                );

                final targetDrop = _buildDropdown(
                  label: 'target'.tr,
                  value: _target,
                  options: [
                    (null, 'all'.tr),
                    ('wallet', 'wallet'.tr),
                    ('debt', 'deferred_profits'.tr),
                  ],
                  onChanged: (v) => setState(() => _target = v),
                );

                final payMethodDrop = _buildDropdown(
                  label: 'payment_method'.tr,
                  value: _payMethod,
                  options: paymentsMethods.toList(),
                  onChanged: (v) => setState(() => _payMethod = v),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Flexible(fit: FlexFit.loose, child: inOutDrop), gapW,
                      Flexible(fit: FlexFit.loose, child: targetDrop), gapW,
                      Flexible(fit: FlexFit.loose, child: payMethodDrop),
                    ],
                  );
                }
                // عمودي بدون أي flex
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    inOutDrop, gapH, targetDrop, gapH, payMethodDrop,
                  ],
                );
              },
            ),

            // Row 2: order_id, search
            const SizedBox(height: Dimensions.paddingSizeSmall),
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth > 700;

                final orderIdField = TextFieldWidget(
                  title: true, titleName: 'order_id'.tr,
                  hintText: 'order_id'.tr,
                  controller: _orderIdCtrl,
                  inputType: TextInputType.number,
                );

                if (isWide) {
                  return Row(
                    children: [
                      Flexible(fit: FlexFit.loose, child: orderIdField), gapW,
                    ],
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [orderIdField, gapH],
                );
              },
            ),

            // Row 3: from, to
            const SizedBox(height: Dimensions.paddingSizeSmall),
            LayoutBuilder(
              builder: (context, c) {
                final isWide = c.maxWidth > 700;

                final fromField = TextFieldWidget(
                  title: true, titleName: 'from'.tr,
                  hintText: 'YYYY-MM-DD',
                  controller: _fromCtrl,
                  isEnabled: true,
                  readOnly: true,
                  onTap: () => _pickDate(
                    _fromCtrl, 
                    last: toDate,
                    onChanged: (val) => fromDate = val,
                  ),
                );

                final toField = TextFieldWidget(
                  title: true, titleName: 'to'.tr,
                  hintText: 'YYYY-MM-DD',
                  controller: _toCtrl,
                  isEnabled: true,
                  readOnly: true,
                  onTap: () => _pickDate(
                    _toCtrl, 
                    first: fromDate,
                    onChanged: (val) => toDate = val,
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Flexible(fit: FlexFit.loose, child: fromField), gapW,
                      Flexible(fit: FlexFit.loose, child: toField),
                    ],
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [fromField, gapH, toField],
                );
              },
            ),

            const SizedBox(height: Dimensions.paddingSizeLarge),

            Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(
                    buttonText: 'apply'.tr,
                    onPressed: () {
                      widget.onApply(
                        inOut: _inOut,
                        target: _target,
                        payMethod: _payMethod,
                        orderId: int.tryParse(_orderIdCtrl.text.trim()),
                        from: _fromCtrl.text.trim().isEmpty ? null : _fromCtrl.text.trim(),
                        to: _toCtrl.text.trim().isEmpty ? null : _toCtrl.text.trim(),
                      );
                    },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: CustomButtonWidget(
                    transparent: true,
                    buttonText: 'reset'.tr,
                    onPressed: () {
                      setState(() {
                        _inOut = null; _target = null; _payMethod = null;
                        _orderIdCtrl.clear(); _fromCtrl.clear(); _toCtrl.clear();
                      });
                      widget.onReset();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<(String?, String)> options,
    required void Function(String?) onChanged,
  }) {
    final items = options.map((e) => DropdownItem<String?>(
      value: e.$1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(e.$2, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    )).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: Dimensions.paddingSizeSmall),
        CustomDropdown<String?>(
          items: items,
          onChange: (v, _) => onChanged(v),
          child: Text(
            options.firstWhere((opt) => opt.$1 == value, orElse: ()=> (null, 'all'.tr)).$2,
            maxLines: 1, overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
