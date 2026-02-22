// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LNUT Network Authentication';

  @override
  String get errorConnecting => 'Network environment error';

  @override
  String get errorInvalidParams => 'Invalid parameters';

  @override
  String get errorAccountNotFound => 'Account not found';

  @override
  String get errorPasswordIncorrect => 'Incorrect password';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get errorLoggedOutFailed => 'Failed to log out';

  @override
  String get errorPingTestFailed => 'Failed to connect to Internet';

  @override
  String get errorNoUsernamePassword => 'Username and password required';

  @override
  String get checkingNetwork => 'Checking network environment...';

  @override
  String get statusChecking => 'Checking';

  @override
  String get statusCheckingMin => 'Checking...';

  @override
  String get statusConnectedCampus => 'Connected';

  @override
  String get statusConnectedCampusDesc =>
      'Campus network authenticated, Internet is available';

  @override
  String get statusConnectedCampusMin => 'Campus network authenticated';

  @override
  String get actionDisconnect => 'Disconnect';

  @override
  String get statusConnectedExternal => 'Network Connected';

  @override
  String get statusConnectedExternalDesc =>
      'Not in campus network, authentication not required';

  @override
  String get statusConnectedExternalMin => 'External network environment';

  @override
  String get actionRecheck => 'Recheck';

  @override
  String get statusWaitingLoginMin => 'Waiting for login';

  @override
  String get statusAutoLoggingInMin => 'Auto-logging in...';

  @override
  String get statusNoNetwork => 'No Network';

  @override
  String get statusNoNetworkDesc =>
      'Please check your network connection and try again';

  @override
  String get statusNoNetworkMin => 'No network connection';

  @override
  String get loginSubtitle => 'Login to connect to the Internet';

  @override
  String get loginUsernameHint => 'Student ID';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginAutoLogin => 'Auto login';

  @override
  String get loginButton => 'Login';

  @override
  String get loginButtonLoggingIn => 'Logging in...';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get logoutLoggingOut => 'Logging out...';

  @override
  String get logoutSuccess => 'Logged out';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsAutoStart => 'Auto Start';

  @override
  String get settingsAutoStartDesc =>
      'Automatically run this program when logging into the system';

  @override
  String get settingsNetworkInterface => 'Network Interface';

  @override
  String get settingsNetworkInterfaceDesc =>
      'Manually specify the authentication network interface';

  @override
  String get interfaceAutoDetect => 'Auto Detect';

  @override
  String get interfaceAutoDetectDesc =>
      'Recommended · Prefer physical network card';
}
