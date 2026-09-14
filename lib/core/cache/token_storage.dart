import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  TokenStorage(this._box);
  final GetStorage _box;
  String? get token => _box.read<String>(AppConstants.tokenKey);
  Future<void> save(String value) => _box.write(AppConstants.tokenKey, value);
  Future<void> clear() => _box.remove(AppConstants.tokenKey);
}
