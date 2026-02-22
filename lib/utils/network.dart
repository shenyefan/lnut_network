import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

final logger = Logger();

class NetworkUtils {
  static const _physicalKeywords = ['wlan', 'wi-fi', 'wifi', 'ethernet', '以太网', 'en0', 'en1', 'eth0', 'eth1', 'wlan0'];
  static const _connectivityEndpoints = [
    'https://cp.cloudflare.com/generate_204',
    'https://www.gstatic.com/generate_204',
    'https://connect.rom.miui.com/generate_204',
    'http://connect.rom.miui.com/generate_204',
  ];

  /// 获取所有可用网卡及其 IPv4 地址列表
  static Future<Map<String, List<String>>> getAllInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list(includeLinkLocal: false, type: InternetAddressType.IPv4);
      return Map.fromEntries(
        interfaces.map((iface) => MapEntry(
              iface.name,
              iface.addresses.where((addr) => !addr.isLoopback).map((a) => a.address).toList(),
            ))
            .where((entry) => entry.value.isNotEmpty),
      );
    } catch (e) {
      logger.e("获取网卡列表失败: $e");
      return {};
    }
  }

  /// 获取本机的有效局域网 IP 地址
  static Future<String?> getIpAddress({String preferredInterface = ''}) async {
    try {
      final allInterfaces = await getAllInterfaces();
      if (allInterfaces.isEmpty) return null;

      // 手动指定网卡
      if (preferredInterface.isNotEmpty && allInterfaces.containsKey(preferredInterface)) {
        final ip = allInterfaces[preferredInterface]!.first;
        logger.i("指定网卡 [$preferredInterface]: $ip");
        return ip;
      }

      // 匹配物理网卡
      for (final entry in allInterfaces.entries) {
        final nameLower = entry.key.toLowerCase();
        if (_physicalKeywords.any((k) => nameLower.contains(k))) {
          logger.i("物理网卡 [${entry.key}]: ${entry.value.first}");
          return entry.value.first;
        }
      }

      // 兜底
      final fallback = allInterfaces.entries.first;
      logger.i("未匹配指定或物理网卡，使用网卡 [${fallback.key}]: ${fallback.value.first}");
      return fallback.value.first;
    } catch (e) {
      logger.e("获取本机 IP 地址失败: $e");
      return null;
    }
  }

  /// 204 测试
  static Future<bool> isNetworkConnected() async {
    final client = http.Client();
    try {
      for (final endpoint in _connectivityEndpoints) {
        try {
          final uri = Uri.parse(endpoint);
          final response = await client.get(uri).timeout(const Duration(seconds: 3));

          if (response.statusCode >= 200 && response.statusCode < 400) {
            return true;
          }

          logger.w("连通性检测失败 [$endpoint]（${response.statusCode}）");
        } catch (e) {
          logger.w("连通性检测异常 [$endpoint]: $e");
          if (Platform.isMacOS && e.toString().contains('Operation not permitted')) {
            logger.w("macOS 沙盒可能缺少网络客户端权限（com.apple.security.network.client）");
          }
        }
      }

      logger.e("外网连通性测试全部失败");
      return false;
    } finally {
      client.close();
    }
  }

  /// 校园网检测 
  static Future<bool> pingTest(String targetIp, {int timeoutSeconds = 2}) async {
    try {
      ProcessResult result;

      if (Platform.isWindows) {
        // Windows
        result = await Process.run(
          'ping', ['-n', '1', '-w', '${timeoutSeconds * 1000}', targetIp],
          stdoutEncoding: systemEncoding,
          stderrEncoding: systemEncoding,
        );
      } else {
        // macOS / Linux / Android
        result = await Process.run(
          'ping', ['-c', '1', '-W', '$timeoutSeconds', targetIp],
        );
      }

      final output = result.stdout.toString().toLowerCase();
      if (result.exitCode == 0 && output.contains('ttl=')) {
        logger.i("Ping $targetIp 成功");
        return true;
      } else {
        logger.w("Ping $targetIp 失败 (exitCode=${result.exitCode})");
        return false;
      }
    } catch (e) {
      logger.e("Ping 执行失败: $e");
      return false;
    }
  }
}
