import 'package:flutter/foundation.dart';
import '../utils/network.dart';
import '../utils/login_manager.dart';
import '../utils/config_manager.dart';

enum AppNetworkStatus {
  checking,          // 正在检测
  connectedCampus,   // 已认证校园网，外网畅通 (可下线)
  connectedExternal, // 外网畅通，但不在校园网 (仅信息展示)
  campusNetwork,     // 在校园网，但未认证 (需要登录)
  noNetwork,         // 无任何网络
  loginFailed,       // 登录失败
}

class AppState extends ChangeNotifier {
  final ConfigManager _configManager = ConfigManager();
  final LoginManager _loginManager = LoginManager();
  
  AppNetworkStatus status = AppNetworkStatus.checking;
  
  String currentIp = '';
  String errorMessage = '';
  
  String savedUsername = '';
  String savedPassword = '';
  bool isRememberPassword = false;
  bool isAutoLogin = false;
  bool autoCloseOnConnected = false;
  String preferredInterface = '';
  
  bool isLoggingIn = false;
  bool isLoggingOut = false;

  AppState() {
    _init();
  }

  Future<void> _init() async {
    await loadConfig();
    await checkNetworkStatus(allowAutoLogin: true);
  }

  Future<void> loadConfig() async {
    final credentials = await _configManager.loadCredentials();
    savedUsername = credentials['username'] ?? '';
    savedPassword = credentials['password'] ?? '';
    isRememberPassword = credentials['rememberPassword'] ?? false;
    isAutoLogin = credentials['autoLogin'] ?? false;
    autoCloseOnConnected = credentials['autoCloseOnConnected'] ?? false;
    preferredInterface = credentials['preferredInterface'] ?? '';
    notifyListeners();
  }

  Future<void> saveConfig(
    String username,
    String password,
    bool rememberPassword,
    bool autoLogin,
  ) async {
    final effectiveAutoLogin = rememberPassword && autoLogin;
    savedUsername = username;
    savedPassword = rememberPassword ? password : '';
    isRememberPassword = rememberPassword;
    isAutoLogin = effectiveAutoLogin;
    await _configManager.saveCredentials(username, password, rememberPassword, effectiveAutoLogin);
    notifyListeners();
  }
  
  Future<void> savePreferredInterface(String interfaceName) async {
    preferredInterface = interfaceName;
    await _configManager.savePreferredInterface(interfaceName);
    notifyListeners();
    await checkNetworkStatus();
  }

  Future<void> saveAutoCloseOnConnected(bool enabled) async {
    autoCloseOnConnected = enabled;
    await _configManager.saveAutoCloseOnConnected(enabled);
    notifyListeners();
  }

  Future<void> checkNetworkStatus({bool allowAutoLogin = false}) async {
    status = AppNetworkStatus.checking;
    errorMessage = '';
    notifyListeners();

    final probe = await _probeNetwork();
    currentIp = probe.ip;
    final isConnected = probe.isConnected;
    final isCampus = probe.isCampus;

    if (isConnected && isCampus) {
      status = AppNetworkStatus.connectedCampus;
    } else if (isConnected && !isCampus) {
      status = AppNetworkStatus.connectedExternal;
    } else if (!isConnected && isCampus) {
      status = AppNetworkStatus.campusNetwork;
      if (allowAutoLogin && isAutoLogin && savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
        notifyListeners();
        await login(
          savedUsername,
          savedPassword,
          rememberPassword: isRememberPassword,
          autoLogin: true,
        );
        return;
      }
    } else {
      status = AppNetworkStatus.noNetwork;
    }
    notifyListeners();
  }

  Future<({String ip, bool isConnected, bool isCampus})> _probeNetwork() async {
    final ipFuture = NetworkUtils.getIpAddress(preferredInterface: preferredInterface);
    final isConnectedFuture = NetworkUtils.isNetworkConnected();
    final isCampusFuture = NetworkUtils.pingTest('10.9.18.71', timeoutSeconds: 2);

    final results = await Future.wait<dynamic>([
      ipFuture,
      isConnectedFuture,
      isCampusFuture,
    ]);

    return (
      ip: (results[0] as String?) ?? '',
      isConnected: results[1] as bool,
      isCampus: results[2] as bool,
    );
  }

  Future<bool> _postLoginVerifyStatus() async {
    // 登录成功后给网关一点时间同步路由，再做状态复检，减少误判。
    await Future.delayed(const Duration(milliseconds: 350));
    var probe = await _probeNetwork();
    currentIp = probe.ip;
    var isConnected = probe.isConnected;
    var isCampus = probe.isCampus;

    if (!isConnected && isCampus) {
      await Future.delayed(const Duration(milliseconds: 700));
      probe = await _probeNetwork();
      currentIp = probe.ip;
      isConnected = probe.isConnected;
      isCampus = probe.isCampus;
    }

    if (isConnected && isCampus) {
      status = AppNetworkStatus.connectedCampus;
      return true;
    }
    if (isConnected && !isCampus) {
      status = AppNetworkStatus.connectedExternal;
      return true;
    }
    if (!isConnected && isCampus) {
      status = AppNetworkStatus.campusNetwork;
      errorMessage = 'errorPingTestFailed';
      return false;
    }
    status = AppNetworkStatus.noNetwork;
    errorMessage = 'errorPingTestFailed';
    return false;
  }

  Future<void> login(
    String username,
    String password, {
    bool rememberPassword = false,
    bool autoLogin = false,
  }) async {
    if (status != AppNetworkStatus.campusNetwork && status != AppNetworkStatus.loginFailed) return;
    
    isLoggingIn = true;
    errorMessage = '';
    notifyListeners();

    if (currentIp.isEmpty) {
      currentIp = await NetworkUtils.getIpAddress(preferredInterface: preferredInterface) ?? '0.0.0.0';
    }

    final (success, msg) = await _loginManager.login(username, password, currentIp);
    
    isLoggingIn = false;
    if (success) {
      notifyListeners();
      await saveConfig(username, password, rememberPassword, autoLogin);
      await _postLoginVerifyStatus();
    } else if (msg == 'errorLoginTimeout') {
      // 服务端可能已处理登录请求，但客户端等待响应超时，先复检网络状态。
      final verified = await _postLoginVerifyStatus();
      if (verified) {
        await saveConfig(username, password, rememberPassword, autoLogin);
      } else {
        status = AppNetworkStatus.loginFailed;
        errorMessage = 'errorConnecting';
      }
    } else {
      status = AppNetworkStatus.loginFailed;
      errorMessage = msg;
    }
    notifyListeners();
  }

  Future<void> logout() async {
    isLoggingOut = true;
    errorMessage = '';
    notifyListeners();
    
    final (success, msg) = await _loginManager.logout();
    isLoggingOut = false;
    if (success) {
      await checkNetworkStatus();
    } else if (msg == 'errorLogoutTimeout') {
      // 服务端可能已处理下线请求，但客户端等待响应超时，先复检状态。
      await Future.delayed(const Duration(milliseconds: 500));
      await checkNetworkStatus();
      if (status == AppNetworkStatus.connectedCampus) {
        errorMessage = 'errorLoggedOutFailed';
        notifyListeners();
      }
    } else {
      errorMessage = msg;
      notifyListeners();
    }
  }
}
