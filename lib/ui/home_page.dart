import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import '../app/app_state.dart';
import 'status_view.dart';
import 'login_view.dart';
import 'settings_sheet.dart';
import 'package:lnut_network/l10n/app_localizations.dart';

bool get isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS);

class HomePage extends StatefulWidget {
  final AppState appState;
  const HomePage({super.key, required this.appState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _autoStart = false;
  bool _autoCloseOnConnected = false;
  bool _autoCloseCancelledByUser = false;
  Timer? _autoCloseTimer;
  int _autoCloseSecondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _autoCloseOnConnected = widget.appState.autoCloseOnConnected;
    widget.appState.addListener(_onAppStateChanged);
    if (isDesktop) {
      launchAtStartup.isEnabled().then((v) {
        if (mounted) setState(() => _autoStart = v);
      });
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onAppStateChanged);
    _cancelAutoCloseCountdown(updateUi: false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
          ),
        ),
        child: ListenableBuilder(
          listenable: widget.appState,
          builder: (context, _) {
            return SafeArea(
              top: false,
              child: Column(
                children: [
                  _buildTitleBar(context),
                  if (isDesktop && _autoCloseOnConnected && _autoCloseSecondsLeft > 0)
                    _buildAutoCloseBanner(context),
                  // 全局错误横幅
                  if (widget.appState.errorMessage.isNotEmpty &&
                      widget.appState.status != AppNetworkStatus.loginFailed)
                    _buildErrorBanner(_getTranslatedError(context, widget.appState.errorMessage)),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: _buildContent(widget.appState),
                        ),
                      ),
                    ),
                  ),
                  _buildFooter(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onAppStateChanged() {
    if (!mounted) return;

    final bool nextAutoClose = widget.appState.autoCloseOnConnected;
    if (_autoCloseOnConnected != nextAutoClose) {
      setState(() => _autoCloseOnConnected = nextAutoClose);
    }

    final bool connectedToInternet = widget.appState.status == AppNetworkStatus.connectedCampus ||
        widget.appState.status == AppNetworkStatus.connectedExternal;

    if (isDesktop && nextAutoClose && connectedToInternet && !_autoCloseCancelledByUser) {
      if (_autoCloseTimer == null) {
        _startAutoCloseCountdown();
      }
      return;
    }

    if (!connectedToInternet || !nextAutoClose) {
      _autoCloseCancelledByUser = false;
    }
    _cancelAutoCloseCountdown();
  }

  void _startAutoCloseCountdown() {
    _autoCloseCancelledByUser = false;
    _autoCloseSecondsLeft = 5;
    setState(() {});
    _autoCloseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_autoCloseSecondsLeft <= 1) {
        timer.cancel();
        _autoCloseTimer = null;
        setState(() => _autoCloseSecondsLeft = 0);
        _closeDesktopApp();
        return;
      }

      setState(() => _autoCloseSecondsLeft -= 1);
    });
  }

  void _cancelAutoCloseCountdown({bool updateUi = true}) {
    _autoCloseTimer?.cancel();
    _autoCloseTimer = null;
    if (_autoCloseSecondsLeft == 0) return;
    if (!updateUi || !mounted) {
      _autoCloseSecondsLeft = 0;
      return;
    }
    setState(() => _autoCloseSecondsLeft = 0);
  }

  void _cancelAutoCloseByUser() {
    _autoCloseCancelledByUser = true;
    _cancelAutoCloseCountdown();
  }

  Future<void> _closeDesktopApp() async {
    try {
      await windowManager.close();
    } catch (_) {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        exit(0);
      }
    }
  }

  Widget _buildAutoCloseBanner(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 0, 36, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFBBF24).withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.timer_outlined, size: 16, color: const Color(0xFFFBBF24).withValues(alpha: 0.95)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.autoCloseCountdownHint(_autoCloseSecondsLeft),
                style: TextStyle(fontSize: 12, color: const Color(0xFFFBBF24).withValues(alpha: 0.95)),
              ),
            ),
            TextButton(
              onPressed: _cancelAutoCloseByUser,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFBBF24).withValues(alpha: 0.98),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              child: Text(l10n.autoCloseCancelAction),
            ),
          ],
        ),
      ),
    );
  }

  // ── 标题栏 ──

  Widget _buildTitleBar(BuildContext context) {
    final bool isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final double titleBarHeight = isDesktop ? (isMac ? 34 : 48) : 0;
    return GestureDetector(
      onPanStart: isDesktop ? (_) => windowManager.startDragging() : null,
      child: Container(
        height: titleBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: isDesktop
            ? Row(
                children: [
                  // macOS 下为左侧交通灯预留空间
                  if (Platform.isMacOS) const SizedBox(width: 72),
                  if (!Platform.isMacOS) const SizedBox(width: 10),
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  _titleBarBtn(Icons.settings_outlined, () => _openSettings(), Colors.white.withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  if (!Platform.isMacOS) ...[
                    _titleBarBtn(Icons.remove_rounded, () => windowManager.minimize(), Colors.white.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    _titleBarBtn(Icons.close_rounded, () => windowManager.close(), const Color(0xFFE81123)),
                  ],
                ],
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _titleBarBtn(IconData icon, VoidCallback onTap, Color hoverColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: hoverColor,
        child: SizedBox(
          width: 36, height: 32,
          child: Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ),
    );
  }

  // ── 底栏 ──

  Widget _buildFooter(BuildContext context) {
    final state = widget.appState;
    return Padding(
      padding: EdgeInsets.fromLTRB(36, 8, 36, isDesktop ? 20 : 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _getTranslatedStatusMin(context, state),
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (state.currentIp.isNotEmpty)
            Text(
              state.currentIp,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.2),
                fontFamily: 'monospace',
              ),
            ),
          if (!isDesktop) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.settings_outlined, size: 18, color: Colors.white.withValues(alpha: 0.4)),
              onPressed: _openSettings,
              splashRadius: 18,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 0, 36, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF87171).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF87171).withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 16, color: const Color(0xFFF87171).withValues(alpha: 0.8)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12, color: const Color(0xFFF87171).withValues(alpha: 0.9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 内容路由 ──

  Widget _buildContent(AppState state) {
    final l10n = AppLocalizations.of(context)!;
    switch (state.status) {
      case AppNetworkStatus.checking:
        return StatusView(
          accentColor: const Color(0xFF5B8DEF),
          loading: true,
          title: l10n.statusChecking,
          subtitle: l10n.checkingNetwork,
        );
      case AppNetworkStatus.connectedCampus:
        return StatusView(
          accentColor: const Color(0xFF34D399),
          icon: Icons.check_rounded,
          title: l10n.statusConnectedCampus,
          subtitle: l10n.statusConnectedCampusDesc,
          actionText: l10n.actionDisconnect,
          actionColor: const Color(0xFFF87171),
          onAction: () => state.logout(),
        );
      case AppNetworkStatus.connectedExternal:
        return StatusView(
          accentColor: const Color(0xFFFBBF24),
          icon: Icons.wifi_rounded,
          title: l10n.statusConnectedExternal,
          subtitle: l10n.statusConnectedExternalDesc,
          actionText: l10n.actionRecheck,
          onAction: () => state.checkNetworkStatus(),
        );
      case AppNetworkStatus.campusNetwork:
      case AppNetworkStatus.loginFailed:
        return LoginView(appState: state);
      case AppNetworkStatus.noNetwork:
        return StatusView(
          accentColor: const Color(0xFFF87171),
          icon: Icons.wifi_off_rounded,
          title: l10n.statusNoNetwork,
          subtitle: l10n.statusNoNetworkDesc,
          actionText: l10n.actionRecheck,
          onAction: () => state.checkNetworkStatus(),
        );
    }
  }

  String _getTranslatedStatusMin(BuildContext context, AppState state) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isLoggingOut) return l10n.logoutLoggingOut;
    
    switch (state.status) {
      case AppNetworkStatus.checking:
        return l10n.statusCheckingMin;
      case AppNetworkStatus.connectedCampus:
        return l10n.statusConnectedCampusMin;
      case AppNetworkStatus.connectedExternal:
        return l10n.statusConnectedExternalMin;
      case AppNetworkStatus.campusNetwork:
      case AppNetworkStatus.loginFailed:
        if (state.isLoggingIn) return l10n.statusAutoLoggingInMin;
        return l10n.statusWaitingLoginMin;
      case AppNetworkStatus.noNetwork:
        return l10n.statusNoNetworkMin;
    }
  }

  String _getTranslatedError(BuildContext context, String code) {
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'errorPingTestFailed': return l10n.errorPingTestFailed;
      case 'errorInvalidParams': return l10n.errorInvalidParams;
      case 'errorAccountNotFound': return l10n.errorAccountNotFound;
      case 'errorPasswordIncorrect': return l10n.errorPasswordIncorrect;
      case 'errorLoggedOutFailed': return l10n.errorLoggedOutFailed;
      default: return code; 
    }
  }

  // ── 设置入口 ──

  void _openSettings() {
    SettingsSheet.show(
      context,
      appState: widget.appState,
      autoStartEnabled: _autoStart,
      onAutoStartChanged: (v) => setState(() => _autoStart = v),
      autoCloseOnConnected: _autoCloseOnConnected,
      onAutoCloseOnConnectedChanged: (v) {
        setState(() => _autoCloseOnConnected = v);
        widget.appState.saveAutoCloseOnConnected(v);
        if (!v) {
          _autoCloseCancelledByUser = false;
          _cancelAutoCloseCountdown();
          return;
        }
        _autoCloseCancelledByUser = false;
        _onAppStateChanged();
      },
    );
  }
}
