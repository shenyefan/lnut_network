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
    await checkNetworkStatus();
  }

  Future<void> loadConfig() async {
    final credentials = await _configManager.loadCredentials();
    savedUsername = credentials['username'] ?? '';
    savedPassword = credentials['password'] ?? '';
    isAutoLogin = credentials['autoLogin'] ?? false;
    autoCloseOnConnected = credentials['autoCloseOnConnected'] ?? false;
    preferredInterface = credentials['preferredInterface'] ?? '';
    notifyListeners();
  }

  Future<void> saveConfig(String username, String password, bool autoLogin) async {
    savedUsername = username;
    savedPassword = password;
    isAutoLogin = autoLogin;
    await _configManager.saveCredentials(username, password, autoLogin);
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

  Future<void> checkNetworkStatus() async {
    status = AppNetworkStatus.checking;
    errorMessage = '';
    notifyListeners();

    currentIp = await NetworkUtils.getIpAddress(preferredInterface: preferredInterface) ?? '';
    
    bool isConnected = await NetworkUtils.isNetworkConnected();
    bool isCampus = await NetworkUtils.pingTest('10.9.18.71', timeoutSeconds: 2);

    if (isConnected && isCampus) {
      status = AppNetworkStatus.connectedCampus;
    } else if (isConnected && !isCampus) {
      status = AppNetworkStatus.connectedExternal;
    } else if (!isConnected && isCampus) {
      status = AppNetworkStatus.campusNetwork;
      if (isAutoLogin && savedUsername.isNotEmpty && savedPassword.isNotEmpty) {
        notifyListeners();
        await login(savedUsername, savedPassword, autoLogin: true);
        return;
      }
    } else {
      status = AppNetworkStatus.noNetwork;
    }
    notifyListeners();
  }

  Future<void> login(String username, String password, {bool autoLogin = false}) async {
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
      await saveConfig(username, password, autoLogin);
      
      bool isConnected = await NetworkUtils.isNetworkConnected();
      if (isConnected) {
        status = AppNetworkStatus.connectedCampus;
      } else {
        status = AppNetworkStatus.connectedCampus;
        errorMessage = 'errorPingTestFailed';
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
    } else {
      errorMessage = msg;
      notifyListeners();
    }
  }
}
