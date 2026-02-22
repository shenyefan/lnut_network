import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:lnut_network/l10n/app_localizations.dart';
import '../app/app_state.dart';
import '../utils/network.dart';

bool get _isDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS);

class SettingsSheet {
  /// 显示设置面板
  static Future<void> show(
    BuildContext context, {
    required AppState appState,
    required bool autoStartEnabled,
    required ValueChanged<bool> onAutoStartChanged,
    required bool autoCloseOnConnected,
    required ValueChanged<bool> onAutoCloseOnConnectedChanged,
  }) async {
    final interfaces = await NetworkUtils.getAllInterfaces();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        bool localAutoStart = autoStartEnabled;
        bool localAutoCloseOnConnected = autoCloseOnConnected;
        final l10n = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E2640),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // ── 开机自启 ──
                    if (_isDesktop) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
                        child: Text(
                          l10n.settingsGeneral,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final newVal = !localAutoStart;
                            if (newVal) {
                              await launchAtStartup.enable();
                            } else {
                              await launchAtStartup.disable();
                            }
                            localAutoStart = newVal;
                            onAutoStartChanged(newVal);
                            setSheetState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.settingsAutoStart, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                                      const SizedBox(height: 2),
                                      Text(l10n.settingsAutoStartDesc, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                  child: Switch(
                                    value: localAutoStart,
                                    activeThumbColor: const Color(0xFF5B8DEF),
                                    onChanged: (v) async {
                                      if (v) {
                                        await launchAtStartup.enable();
                                      } else {
                                        await launchAtStartup.disable();
                                      }
                                      localAutoStart = v;
                                      onAutoStartChanged(v);
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.06), indent: 24, endIndent: 24),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            final newVal = !localAutoCloseOnConnected;
                            localAutoCloseOnConnected = newVal;
                            onAutoCloseOnConnectedChanged(newVal);
                            setSheetState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(l10n.settingsAutoCloseOnConnected, style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.85))),
                                      const SizedBox(height: 2),
                                      Text(l10n.settingsAutoCloseOnConnectedDesc, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 24,
                                  child: Switch(
                                    value: localAutoCloseOnConnected,
                                    activeThumbColor: const Color(0xFF5B8DEF),
                                    onChanged: (v) {
                                      localAutoCloseOnConnected = v;
                                      onAutoCloseOnConnectedChanged(v);
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 1, color: Colors.white.withValues(alpha: 0.06), indent: 24, endIndent: 24),
                    ],
                    // ── 网络接口选择 ──
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
                      child: Text(
                        l10n.settingsNetworkInterface,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        l10n.settingsNetworkInterfaceDesc,
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.35)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildItem(
                      title: l10n.interfaceAutoDetect,
                      subtitle: l10n.interfaceAutoDetectDesc,
                      selected: appState.preferredInterface.isEmpty,
                      onTap: () {
                        appState.savePreferredInterface('');
                        Navigator.pop(ctx);
                      },
                    ),
                    ...interfaces.entries.map((e) => _buildItem(
                      title: e.key,
                      subtitle: e.value.join(', '),
                      selected: appState.preferredInterface == e.key,
                      onTap: () {
                        appState.savePreferredInterface(e.key);
                        Navigator.pop(ctx);
                      },
                    )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildItem({
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? const Color(0xFF5B8DEF) : Colors.transparent,
                  border: Border.all(
                    color: selected ? const Color(0xFF5B8DEF) : Colors.white.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 12, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.85),
                    )),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.35))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
