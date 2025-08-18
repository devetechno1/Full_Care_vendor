import 'package:get/get.dart';

import '../repositories/dev_accounts_repository_interface.dart';
import 'dev_accounts_service_interface.dart';

class DmAccountsService implements DevAccountsServiceInterface {
  final DevAccountsRepositoryInterface repo;
  DmAccountsService({required this.repo});

  @override
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
  }) {
    return repo.getAccounts(
      limit: limit,
      offset: offset,
      inOut: inOut,
      target: target,
      payMethod: payMethod,
      orderId: orderId,
      from: from,
      to: to,
      search: search,
    );
  }
}
