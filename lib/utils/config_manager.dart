import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ConfigManager {
  static const _storage = FlutterSecureStorage();

  /// 加载保存的凭证和状态
  Future<Map<String, dynamic>> loadCredentials() async {
    final username = await _storage.read(key: 'username') ?? '';
    final password = await _storage.read(key: 'password') ?? '';
    final autoLoginStr = await _storage.read(key: 'autoLogin') ?? 'false';
    final autoLogin = autoLoginStr == 'true';
    final preferredInterface = await _storage.read(key: 'preferredInterface') ?? '';

    return {
      'username': username,
      'password': password,
      'autoLogin': autoLogin,
      'preferredInterface': preferredInterface,
    };
  }

  /// 保存用户名、密码和自动登录状态
  Future<void> saveCredentials(String username, String password, bool autoLogin) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
    await _storage.write(key: 'autoLogin', value: autoLogin ? 'true' : 'false');
    logger.i("已保存用户名: $username, 自动登录状态: $autoLogin");
  }

  /// 保存用户首选的网卡名称
  Future<void> savePreferredInterface(String interfaceName) async {
    await _storage.write(key: 'preferredInterface', value: interfaceName);
    logger.i("已保存首选网卡: $interfaceName");
  }
}
