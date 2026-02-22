import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// 由于 APP 未签名，使用该方法来临时避免 errSecMissingEntitlement (-34018).
class _CompatMacOsOptions extends AppleOptions {
  const _CompatMacOsOptions({
    super.accountName,
    super.groupId,
    super.accessibility,
    super.synchronizable,
    this.useDataProtectionKeyChain = false,
  });

  final bool useDataProtectionKeyChain;

  @override
  Map<String, String> toMap() => <String, String>{
        ...super.toMap(),
        'useDataProtectionKeyChain': '$useDataProtectionKeyChain',
      };
}

class ConfigManager {
  static const _storage = FlutterSecureStorage(
    mOptions: _CompatMacOsOptions(useDataProtectionKeyChain: false),
  );

  /// 加载保存的凭证和状态
  Future<Map<String, dynamic>> loadCredentials() async {
    final username = await _storage.read(key: 'username') ?? '';
    final password = await _storage.read(key: 'password') ?? '';
    final autoLoginStr = await _storage.read(key: 'autoLogin') ?? 'false';
    final autoLogin = autoLoginStr == 'true';
    final autoCloseOnConnectedStr = await _storage.read(key: 'autoCloseOnConnected') ?? 'false';
    final autoCloseOnConnected = autoCloseOnConnectedStr == 'true';
    final preferredInterface = await _storage.read(key: 'preferredInterface') ?? '';

    return {
      'username': username,
      'password': password,
      'autoLogin': autoLogin,
      'autoCloseOnConnected': autoCloseOnConnected,
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

  /// 保存连接成功后自动关闭状态
  Future<void> saveAutoCloseOnConnected(bool enabled) async {
    await _storage.write(key: 'autoCloseOnConnected', value: enabled ? 'true' : 'false');
    logger.i("已保存连接成功后自动关闭状态: $enabled");
  }
}
