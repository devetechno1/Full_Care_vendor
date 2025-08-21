import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart_store/helper/string_ex.dart';

import '../../../helper/price_converter_helper.dart';
import '../../../util/dimensions.dart';
import '../../../util/styles.dart';
import '../domain/models/dev_account_model.dart';

class DevAccountCardWidget extends StatelessWidget {
  final DevAccountItem item;
  const DevAccountCardWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final String mainAmount = (item.value != null)
        ? PriceConverterHelper.convertPrice(item.value, asFixed: 2)
        : '';

    final String orderTotal = (item.orderTotal != null)
        ? PriceConverterHelper.convertPrice(item.orderTotal, asFixed: 2)
        : '';

    final String debtText = (item.debt != null && item.debt! > 0)
        ? PriceConverterHelper.convertPrice(item.debt, asFixed: 2)
        : '';

    final String dateStr = item.dateFormatted ?? item.date ?? '';

    return Card(
      elevation: 1.0,
      margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxChipWidth = constraints.maxWidth - 32;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (item.target != null)
                        _chip(
                          text: item.target!.toString(),
                          color: item.target!.color,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateStr,
                          maxLines: 1,
                          textDirection: dateStr.direction,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: Dimensions.paddingSizeLarge),

                // ===== Main amount =====
                if(mainAmount.trim().isNotEmpty)
                  Text(
                    mainAmount,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                  ),

                if (debtText.isNotEmpty) ...[
                  const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                  Text(
                    '${'deferred_profits'.tr}: $debtText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.error),
                  ),
                ],

                const SizedBox(height: Dimensions.paddingSizeSmall),

                // ===== Meta as chips داخل Wrap (يلف سطور بدون مشاكل) =====
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((item.payMethod ?? '').trim().isNotEmpty)
                      _kvChip('${'payment_method'.tr}: ${item.payMethod!.tr}', context, maxChipWidth),
                    if ((item.orderPayType ?? '').trim().isNotEmpty && item.payMethod != item.orderPayType)
                      _kvChip('${'order_pay_type'.tr}: ${item.orderPayType!.tr}', context, maxChipWidth),
                    if (item.orderId != null)
                      _kvChip('${'order_id'.tr}: ${item.orderId}', context, maxChipWidth),
                    if(orderTotal.trim().isNotEmpty)
                      _kvChip('${'order_total'.tr}: $orderTotal', context, maxChipWidth),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Badge chip
  Widget _chip({required String text, required Color color, Color? textColor}) {
    final fg = textColor ?? color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (textColor == null) ? color.withValues(alpha: 0.12) : color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: robotoMedium.copyWith(color: fg, fontSize: 12),
      ),
    );
  }

  // KV chip مع حد أقصى للعرض لتجنّب overflow حتى لو النص طويل
  Widget _kvChip(String text, BuildContext context, double maxWidth) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.06),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(fontSize: 12),
        ),
      ),
    );
  }
}
