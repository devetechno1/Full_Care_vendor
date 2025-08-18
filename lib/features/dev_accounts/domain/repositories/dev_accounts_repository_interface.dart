import 'package:get/get.dart';

import '../../../../interface/repository_interface.dart';

abstract class DevAccountsRepositoryInterface implements RepositoryInterface {
  Future<Response> getAccounts({
    required int limit,
    required int offset,
    String? inOut,
    String? target,
    String? payMethod,
    int? orderId,
    String? from,
    String? to,
    String? search,
  });
}
