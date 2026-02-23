import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lnut_network/l10n/app_localizations.dart';
import '../app/app_state.dart';
import 'widgets/dark_input.dart';
import 'widgets/gradient_button.dart';

class LoginView extends StatefulWidget {
  final AppState appState;

  const LoginView({super.key, required this.appState});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _autoLogin = false;
  bool _obscure = true;
  String _localError = '';

  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_syncCredentials);
    _syncCredentials();
  }

  void _syncCredentials() {
    if (_usernameCtrl.text.isEmpty && widget.appState.savedUsername.isNotEmpty) {
      setState(() {
        _usernameCtrl.text = widget.appState.savedUsername;
        _passwordCtrl.text = widget.appState.savedPassword;
        _autoLogin = widget.appState.isAutoLogin;
      });
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_syncCredentials);
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _performLogin() {
    final state = widget.appState;
    if (state.isLoggingIn) return;
    final u = _usernameCtrl.text.trim();
    final p = _passwordCtrl.text.trim();
    if (u.isEmpty || p.isEmpty) {
      setState(() => _localError = 'errorNoUsernamePassword');
      return;
    }
    setState(() => _localError = '');
    state.login(u, p, autoLogin: _autoLogin);
  }

  /// 统一的错误信息：优先显示本地校验错误，其次显示 AppState 的 errorMessage
  String get _displayError {
    if (_localError.isNotEmpty) return _localError;
    final state = widget.appState;
    if (state.status == AppNetworkStatus.loginFailed && state.errorMessage.isNotEmpty) {
      return state.errorMessage;
    }
    return '';
  }

  String _translateError(BuildContext context, String code) {
    if (code.isEmpty) return '';
    final l10n = AppLocalizations.of(context)!;
    switch (code) {
      case 'errorPingTestFailed': return l10n.errorPingTestFailed;
      case 'errorInvalidParams': return l10n.errorInvalidParams;
      case 'errorAccountNotFound': return l10n.errorAccountNotFound;
      case 'errorPasswordIncorrect': return l10n.errorPasswordIncorrect;
      case 'errorLoggedOutFailed': return l10n.errorLoggedOutFailed;
      case 'errorNoUsernamePassword': return l10n.errorNoUsernamePassword;
      default: return code; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    final l10n = AppLocalizations.of(context)!;
    final bool isMac = !kIsWeb && defaultTargetPlatform == TargetPlatform.macOS;
    final error = _translateError(context, _displayError);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF5B8DEF).withValues(alpha: 0.15),
              border: Border.all(color: const Color(0xFF5B8DEF).withValues(alpha: 0.4), width: 2),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 32, color: Color(0xFF5B8DEF)),
          ),
        ),
        SizedBox(height: isMac ? 14 : 28),
        if (!isMac) ...[
          Text(
            l10n.appTitle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
        ],
        Text(
          l10n.loginSubtitle,
          style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.4)),
          textAlign: TextAlign.center,
        ),

        // 统一的错误横幅
        if (error.isNotEmpty) ...[
          const SizedBox(height: 20),
          _errorBanner(error),
        ],
        const SizedBox(height: 32),

        DarkInput(
          controller: _usernameCtrl,
          hint: l10n.loginUsernameHint,
          icon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: 14),

        DarkInput(
          controller: _passwordCtrl,
          hint: l10n.loginPasswordHint,
          icon: Icons.lock_outline_rounded,
          obscure: _obscure,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              size: 18,
              color: Colors.white.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 16),

        GestureDetector(
          onTap: () => setState(() => _autoLogin = !_autoLogin),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 18, height: 18,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: _autoLogin ? const Color(0xFF5B8DEF) : Colors.transparent,
                  border: Border.all(
                    color: _autoLogin ? const Color(0xFF5B8DEF) : Colors.white.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: _autoLogin
                    ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 10),
              Text(
                l10n.loginAutoLogin,
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.45)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        GradientButton(
          text: state.isLoggingIn ? l10n.loginButtonLoggingIn : l10n.loginButton,
          disabled: state.isLoggingIn,
          onTap: _performLogin,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _errorBanner(String text) {
    return Container(
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
    );
  }
}
