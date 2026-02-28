import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'校园网认证'**
  String get appTitle;

  /// No description provided for @errorConnecting.
  ///
  /// In zh, this message translates to:
  /// **'网络环境异常'**
  String get errorConnecting;

  /// No description provided for @errorInvalidParams.
  ///
  /// In zh, this message translates to:
  /// **'参数错误'**
  String get errorInvalidParams;

  /// No description provided for @errorAccountNotFound.
  ///
  /// In zh, this message translates to:
  /// **'帐号不存在'**
  String get errorAccountNotFound;

  /// No description provided for @errorPasswordIncorrect.
  ///
  /// In zh, this message translates to:
  /// **'密码错误'**
  String get errorPasswordIncorrect;

  /// No description provided for @errorUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知错误'**
  String get errorUnknown;

  /// No description provided for @errorLoggedOutFailed.
  ///
  /// In zh, this message translates to:
  /// **'下线失败'**
  String get errorLoggedOutFailed;

  /// No description provided for @errorPingTestFailed.
  ///
  /// In zh, this message translates to:
  /// **'外网连通性测试未通过'**
  String get errorPingTestFailed;

  /// No description provided for @errorNoUsernamePassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入学号和密码'**
  String get errorNoUsernamePassword;

  /// No description provided for @checkingNetwork.
  ///
  /// In zh, this message translates to:
  /// **'正在为您检查网络环境...'**
  String get checkingNetwork;

  /// No description provided for @statusChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检测'**
  String get statusChecking;

  /// No description provided for @statusCheckingMin.
  ///
  /// In zh, this message translates to:
  /// **'正在检测...'**
  String get statusCheckingMin;

  /// No description provided for @statusConnectedCampus.
  ///
  /// In zh, this message translates to:
  /// **'已连接'**
  String get statusConnectedCampus;

  /// No description provided for @statusConnectedCampusDesc.
  ///
  /// In zh, this message translates to:
  /// **'校园网认证有效，互联网畅通'**
  String get statusConnectedCampusDesc;

  /// No description provided for @statusConnectedCampusMin.
  ///
  /// In zh, this message translates to:
  /// **'校园网已认证'**
  String get statusConnectedCampusMin;

  /// No description provided for @actionDisconnect.
  ///
  /// In zh, this message translates to:
  /// **'断开连接'**
  String get actionDisconnect;

  /// No description provided for @statusConnectedExternal.
  ///
  /// In zh, this message translates to:
  /// **'网络已连接'**
  String get statusConnectedExternal;

  /// No description provided for @statusConnectedExternalDesc.
  ///
  /// In zh, this message translates to:
  /// **'非校园网环境，无需认证'**
  String get statusConnectedExternalDesc;

  /// No description provided for @statusConnectedExternalMin.
  ///
  /// In zh, this message translates to:
  /// **'非校园网环境'**
  String get statusConnectedExternalMin;

  /// No description provided for @actionRecheck.
  ///
  /// In zh, this message translates to:
  /// **'重新检测'**
  String get actionRecheck;

  /// No description provided for @statusWaitingLoginMin.
  ///
  /// In zh, this message translates to:
  /// **'等待登录'**
  String get statusWaitingLoginMin;

  /// No description provided for @statusAutoLoggingInMin.
  ///
  /// In zh, this message translates to:
  /// **'自动登录中...'**
  String get statusAutoLoggingInMin;

  /// No description provided for @statusNoNetwork.
  ///
  /// In zh, this message translates to:
  /// **'无网络'**
  String get statusNoNetwork;

  /// No description provided for @statusNoNetworkDesc.
  ///
  /// In zh, this message translates to:
  /// **'请检查网络连接后重试'**
  String get statusNoNetworkDesc;

  /// No description provided for @statusNoNetworkMin.
  ///
  /// In zh, this message translates to:
  /// **'无网络连接'**
  String get statusNoNetworkMin;

  /// No description provided for @loginSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'登录以连接互联网'**
  String get loginSubtitle;

  /// No description provided for @loginUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'学号'**
  String get loginUsernameHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get loginPasswordHint;

  /// No description provided for @loginRememberPassword.
  ///
  /// In zh, this message translates to:
  /// **'记住密码'**
  String get loginRememberPassword;

  /// No description provided for @loginAutoLogin.
  ///
  /// In zh, this message translates to:
  /// **'自动登录'**
  String get loginAutoLogin;

  /// No description provided for @loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登 录'**
  String get loginButton;

  /// No description provided for @loginButtonLoggingIn.
  ///
  /// In zh, this message translates to:
  /// **'登录中...'**
  String get loginButtonLoggingIn;

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

  /// No description provided for @logoutLoggingOut.
  ///
  /// In zh, this message translates to:
  /// **'正在下线...'**
  String get logoutLoggingOut;

  /// No description provided for @logoutSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已下线'**
  String get logoutSuccess;

  /// No description provided for @settingsGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneral;

  /// No description provided for @settingsAutoStart.
  ///
  /// In zh, this message translates to:
  /// **'开机自启动'**
  String get settingsAutoStart;

  /// No description provided for @settingsAutoStartDesc.
  ///
  /// In zh, this message translates to:
  /// **'登录系统时自动运行本程序'**
  String get settingsAutoStartDesc;

  /// No description provided for @settingsAutoCloseOnConnected.
  ///
  /// In zh, this message translates to:
  /// **'连接成功后自动关闭'**
  String get settingsAutoCloseOnConnected;

  /// No description provided for @settingsAutoCloseOnConnectedDesc.
  ///
  /// In zh, this message translates to:
  /// **'检测到外网可用后，5 秒倒计时并自动关闭程序'**
  String get settingsAutoCloseOnConnectedDesc;

  /// No description provided for @autoCloseCountdownHint.
  ///
  /// In zh, this message translates to:
  /// **'已连接到外网，将在 {seconds} 秒后自动关闭程序'**
  String autoCloseCountdownHint(int seconds);

  /// No description provided for @autoCloseCancelAction.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get autoCloseCancelAction;

  /// No description provided for @settingsNetworkInterface.
  ///
  /// In zh, this message translates to:
  /// **'网络接口'**
  String get settingsNetworkInterface;

  /// No description provided for @settingsNetworkInterfaceDesc.
  ///
  /// In zh, this message translates to:
  /// **'手动指定认证网络出口'**
  String get settingsNetworkInterfaceDesc;

  /// No description provided for @interfaceAutoDetect.
  ///
  /// In zh, this message translates to:
  /// **'自动检测'**
  String get interfaceAutoDetect;

  /// No description provided for @interfaceAutoDetectDesc.
  ///
  /// In zh, this message translates to:
  /// **'推荐 · 优先选用物理网卡'**
  String get interfaceAutoDetectDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
