// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '校园网认证';

  @override
  String get errorConnecting => '网络环境异常';

  @override
  String get errorInvalidParams => '参数错误';

  @override
  String get errorAccountNotFound => '帐号不存在';

  @override
  String get errorPasswordIncorrect => '密码错误';

  @override
  String get errorUnknown => '未知错误';

  @override
  String get errorLoggedOutFailed => '下线失败';

  @override
  String get errorPingTestFailed => '外网连通性测试未通过';

  @override
  String get errorNoUsernamePassword => '请输入学号和密码';

  @override
  String get checkingNetwork => '正在为您检查网络环境...';

  @override
  String get statusChecking => '正在检测';

  @override
  String get statusCheckingMin => '正在检测...';

  @override
  String get statusConnectedCampus => '已连接';

  @override
  String get statusConnectedCampusDesc => '校园网认证有效，互联网畅通';

  @override
  String get statusConnectedCampusMin => '校园网已认证';

  @override
  String get actionDisconnect => '断开连接';

  @override
  String get statusConnectedExternal => '网络已连接';

  @override
  String get statusConnectedExternalDesc => '非校园网环境，无需认证';

  @override
  String get statusConnectedExternalMin => '非校园网环境';

  @override
  String get actionRecheck => '重新检测';

  @override
  String get statusWaitingLoginMin => '等待登录';

  @override
  String get statusAutoLoggingInMin => '自动登录中...';

  @override
  String get statusNoNetwork => '无网络';

  @override
  String get statusNoNetworkDesc => '请检查网络连接后重试';

  @override
  String get statusNoNetworkMin => '无网络连接';

  @override
  String get loginSubtitle => '登录以连接互联网';

  @override
  String get loginUsernameHint => '学号';

  @override
  String get loginPasswordHint => '密码';

  @override
  String get loginRememberPassword => '记住密码';

  @override
  String get loginAutoLogin => '自动登录';

  @override
  String get loginButton => '登 录';

  @override
  String get loginButtonLoggingIn => '登录中...';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get logoutLoggingOut => '正在下线...';

  @override
  String get logoutSuccess => '已下线';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsAutoStart => '开机自启动';

  @override
  String get settingsAutoStartDesc => '登录系统时自动运行本程序';

  @override
  String get settingsAutoCloseOnConnected => '连接成功后自动关闭';

  @override
  String get settingsAutoCloseOnConnectedDesc => '检测到外网可用后，5 秒倒计时并自动关闭程序';

  @override
  String autoCloseCountdownHint(int seconds) {
    return '已连接到外网，将在 $seconds 秒后自动关闭程序';
  }

  @override
  String get autoCloseCancelAction => '取消';

  @override
  String get settingsNetworkInterface => '网络接口';

  @override
  String get settingsNetworkInterfaceDesc => '手动指定认证网络出口';

  @override
  String get interfaceAutoDetect => '自动检测';

  @override
  String get interfaceAutoDetectDesc => '推荐 · 优先选用物理网卡';
}
