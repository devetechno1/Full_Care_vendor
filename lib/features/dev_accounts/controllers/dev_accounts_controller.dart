import 'package:get/get.dart';

import '../domain/models/dev_account_model.dart';
import '../domain/services/dev_accounts_service_interface.dart';

class DevAccountsController extends GetxController implements GetxService {
  final DevAccountsServiceInterface service;
  DevAccountsController({required this.service});

  final int defaultLimit = 25;

  List<DevAccountItem>? _items;
  List<DevAccountItem>? get items => _items;

  int _totalSize = 0;
  int get totalSize => _totalSize;

  int _offset = 1;
  int get offset => _offset;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Active filters (optional)
  String? inOut, target, payMethod, from, to, search;
  int? orderId;

  Future<void> loadFirstPage({
    String? inOut,
    String? target,
    String? payMethod,
    int? orderId,
    String? from,
    String? to,
    String? search,
  }) async {
    this.inOut = inOut;
    this.target = target;
    this.payMethod = payMethod;
    this.orderId = orderId;
    this.from = from;
    this.to = to;
    this.search = search;

    await _load(page: 1);
  }

  Future<void> loadNextPage() async {
    if (_items == null) return;
    final int currentlyLoaded = _items!.length;
    if (currentlyLoaded >= _totalSize) return;
    await _load(page: _offset + 1);
  }

  Future<void> refreshList() async {
    await _load(page: 1);
  }

  Future<void> _load({required int page}) async {
    _isLoading = true;
    update();

    final res = await service.getAccounts(
      limit: defaultLimit,
      offset: page,
      inOut: inOut,
      target: target,
      payMethod: payMethod,
      orderId: orderId,
      from: from,
      to: to,
      search: search,
    );

    _isLoading = false;

    if (res.statusCode == 200) {
      final pageData = DevAccountPage.fromJson(res.body);
      if (page == 1) {
        _items = pageData.items;
      } else {
        _items ??= <DevAccountItem>[];
        _items!.addAll(pageData.items);
      }
      _totalSize = pageData.totalSize;
      _offset = pageData.offset;
    } else {
    }
    update();
  }
}
