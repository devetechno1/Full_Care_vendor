import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/widgets/custom_app_bar_widget.dart';
import '../../../common/widgets/paginated_list_view_widget.dart';
import '../../../helper/responsive_helper.dart';
import '../../../util/dimensions.dart';
import '../controllers/dev_accounts_controller.dart';
import '../domain/models/dev_account_model.dart';
import '../widgets/dev_account_card_widget.dart';
// import '../widgets/dev_accounts_filter_bar_widget.dart';

class DevAccountsScreen extends StatefulWidget {
  final String? inOut;
  final String? target;
  final String? payMethod;
  final int? orderId;
  final String? from;
  final String? to;
  final String? search;

  const DevAccountsScreen({
    super.key,
    this.inOut,
    this.target,
    this.payMethod,
    this.orderId,
    this.from,
    this.to,
    this.search,
  });

  @override
  State<DevAccountsScreen> createState() => _DevAccountsScreenState();
}

class _DevAccountsScreenState extends State<DevAccountsScreen> {
  final ScrollController _scrollController = ScrollController();

  final Set<String> paymentsMethod = {};

  @override
  void initState() {
    super.initState();
    final c = Get.find<DevAccountsController>();
    c.loadFirstPage(
      inOut: widget.inOut,
      target: widget.target,
      payMethod: widget.payMethod,
      orderId: widget.orderId,
      from: widget.from,
      to: widget.to,
      search: widget.search,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
        title: 'dev_accounts'.tr,
        isBackButtonExist: false,
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _openFilters,
      //   icon: const Icon(Icons.filter_alt_outlined),
      //   label: Text('filters'.tr),
      // ),
      body: GetBuilder<DevAccountsController>(
        builder: (c) {
          if (c.items == null && c.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if ((c.items ?? const []).isEmpty) {
            return RefreshIndicator(
              onRefresh: c.refreshList,
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                children: [
                  SizedBox(height: MediaQuery.sizeOf(context).height * 0.20),
                  Icon(Icons.receipt_long_outlined, size: 56, color: Theme.of(context).hintColor),
                  const SizedBox(height: Dimensions.paddingSizeSmall),
                  Center(child: Text('no_transactions_available'.tr)),
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                  // Center(
                  //   child: ElevatedButton.icon(
                  //     onPressed: _openFilters,
                  //     icon: const Icon(Icons.filter_alt_outlined),
                  //     label: Text('filters'.tr),
                  //   ),
                  // ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: c.refreshList,
            child: PaginatedListViewWidget(
              scrollController: _scrollController,
              onPaginate: (int? page) => c.loadNextPage(),
              totalSize: c.totalSize,
              offset: c.offset,
              limit: c.defaultLimit,
              productView: Expanded(
                child: Builder(
                  builder: (context) {
                    final bool isWide = ResponsiveHelper.isDesktop(context) || ResponsiveHelper.isTab(context);

                    if (isWide) {
                      final crossAxisCount = _columnsForWidth(MediaQuery.sizeOf(context).width);
                      return GridView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(bottom: 80),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: c.items!.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: Dimensions.paddingSizeSmall,
                          mainAxisSpacing: Dimensions.paddingSizeSmall,
                          childAspectRatio: _cardAspectRatioForWidth(MediaQuery.sizeOf(context).width),
                        ),
                        itemBuilder: (context, index) {
                          getPaymentsData(c.items![index]);
                          return DevAccountCardWidget(item: c.items![index]);
                        },
                      );
                    } else {
                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall).copyWith(bottom: 80),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: c.items!.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Dimensions.paddingSizeSmall),
                        itemBuilder: (context, index) {
                          getPaymentsData(c.items![index]);
                          return DevAccountCardWidget(item: c.items![index]);
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Future<void> _openFilters() async {
  //   final c = Get.find<DevAccountsController>();

  //   if (ResponsiveHelper.isDesktop(context) ||
  //       ResponsiveHelper.isTab(context)) {
  //     await showDialog(
  //       context: context,
  //       builder: (ctx) {
  //         return Dialog(
  //           insetPadding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
  //           child: ConstrainedBox(
  //             constraints: const BoxConstraints(maxWidth: 720),
  //             child: SingleChildScrollView(
  //               padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
  //               child: DevAccountsFilterBarWidget(
  //                 inOut: c.inOut,
  //                 target: c.target,
  //                 payMethod: c.payMethod,
  //                 orderId: c.orderId,
  //                 from: c.from,
  //                 to: c.to,
  //                 search: c.search,
  //                 paymentsMethod: paymentsMethod,
  //                 onApply: ({
  //                   String? inOut,
  //                   String? target,
  //                   String? payMethod,
  //                   int? orderId,
  //                   String? from,
  //                   String? to,
  //                   String? search,
  //                 }) {
  //                   Navigator.of(ctx).pop();
  //                   c.inOut = inOut;
  //                   c.target = target;
  //                   c.payMethod = payMethod;
  //                   c.orderId = orderId;
  //                   c.from = from;
  //                   c.to = to;
  //                   c.search = search;
  //                   c.loadFirstPage(
  //                     inOut: inOut,
  //                     target: target,
  //                     payMethod: payMethod,
  //                     orderId: orderId,
  //                     from: from,
  //                     to: to,
  //                     search: search,
  //                   );
  //                 },
  //                 onReset: () {
  //                   Navigator.of(ctx).pop();
  //                   c.inOut = null;
  //                   c.target = null;
  //                   c.payMethod = null;
  //                   c.orderId = null;
  //                   c.from = null;
  //                   c.to = null;
  //                   c.search = null;
  //                   c.loadFirstPage();
  //                 },
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     await showModalBottomSheet(
  //       context: context,
  //       isScrollControlled: true,
  //       useSafeArea: true,
  //       builder: (ctx) {
  //         return FractionallySizedBox(
  //           heightFactor: 0.9,
  //           child: SafeArea(
  //             child: SingleChildScrollView(
  //               padding: EdgeInsets.only(
  //                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
  //               ),
  //               child: DevAccountsFilterBarWidget(
  //                 inOut: c.inOut,
  //                 target: c.target,
  //                 payMethod: c.payMethod,
  //                 orderId: c.orderId,
  //                 from: c.from,
  //                 to: c.to,
  //                 search: c.search,
  //                 paymentsMethod: paymentsMethod,
  //                 onApply: ({
  //                   String? inOut,
  //                   String? target,
  //                   String? payMethod,
  //                   int? orderId,
  //                   String? from,
  //                   String? to,
  //                   String? search,
  //                 }) {
  //                   Navigator.of(ctx).pop();
  //                   c.inOut = inOut;
  //                   c.target = target;
  //                   c.payMethod = payMethod;
  //                   c.orderId = orderId;
  //                   c.from = from;
  //                   c.to = to;
  //                   c.search = search;
  //                   c.loadFirstPage(
  //                     inOut: inOut,
  //                     target: target,
  //                     payMethod: payMethod,
  //                     orderId: orderId,
  //                     from: from,
  //                     to: to,
  //                     search: search,
  //                   );
  //                 },
  //                 onReset: () {
  //                   Navigator.of(ctx).pop();
  //                   c.inOut = null;
  //                   c.target = null;
  //                   c.payMethod = null;
  //                   c.orderId = null;
  //                   c.from = null;
  //                   c.to = null;
  //                   c.search = null;
  //                   c.loadFirstPage();
  //                 },
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }

  int _columnsForWidth(double width) {
    if (ResponsiveHelper.isDesktop(context)) return 4;
    if (ResponsiveHelper.isTab(context)) return 3;
    return 2;
  }

  double _cardAspectRatioForWidth(double width) {
    if (ResponsiveHelper.isDesktop(context)) return 1.5;
    if (ResponsiveHelper.isTab(context)) return 0.91;
    return 1.0;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void getPaymentsData(DevAccountItem dmAccountItem) {
    if(dmAccountItem.payMethod?.trim().isNotEmpty == true){ 
      paymentsMethod.add(dmAccountItem.payMethod!);
    }
  }
}
