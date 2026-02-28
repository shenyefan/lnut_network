import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// 由于 APP 未签名，使用该方法来临时避免 errSecMissingEntitlement (-34018).
class _CompatMacOsOptions extends AppleOptions {
  const _CompatMacOsOptions({
    super.groupId,
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
    final storedPassword = await _storage.read(key: 'password') ?? '';
    final rememberPasswordStr = await _storage.read(key: 'rememberPassword');
    final rememberPassword =
        rememberPasswordStr == null ? storedPassword.isNotEmpty : rememberPasswordStr == 'true';
    final autoLoginStr = await _storage.read(key: 'autoLogin') ?? 'false';
    final autoLogin = rememberPassword && autoLoginStr == 'true';
    final autoCloseOnConnectedStr = await _storage.read(key: 'autoCloseOnConnected') ?? 'false';
    final autoCloseOnConnected = autoCloseOnConnectedStr == 'true';
    final preferredInterface = await _storage.read(key: 'preferredInterface') ?? '';

    return {
      'username': username,
      'password': rememberPassword ? storedPassword : '',
      'rememberPassword': rememberPassword,
      'autoLogin': autoLogin,
      'autoCloseOnConnected': autoCloseOnConnected,
      'preferredInterface': preferredInterface,
    };
  }

  /// 保存用户名、密码、记住密码和自动登录状态
  Future<void> saveCredentials(
    String username,
    String password,
    bool rememberPassword,
    bool autoLogin,
  ) async {
    final effectiveAutoLogin = rememberPassword && autoLogin;
    await _storage.write(key: 'username', value: username);
    if (rememberPassword) {
      await _storage.write(key: 'password', value: password);
    } else {
      await _storage.delete(key: 'password');
    }
    await _storage.write(key: 'rememberPassword', value: rememberPassword ? 'true' : 'false');
    await _storage.write(key: 'autoLogin', value: effectiveAutoLogin ? 'true' : 'false');
    logger.i("已保存用户名: $username, 记住密码: $rememberPassword, 自动登录: $effectiveAutoLogin");
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
