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
  static const _connectivityTimeout = Duration(seconds: 2);

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
      final checks = _connectivityEndpoints.map((endpoint) async {
        try {
          final uri = Uri.parse(endpoint);
          final response = await client.get(uri).timeout(_connectivityTimeout);
          final ok = response.statusCode >= 200 && response.statusCode < 400;
          if (!ok) {
            logger.w("连通性检测失败 [$endpoint]（${response.statusCode}）");
          }
          return ok;
        } catch (e) {
          logger.w("连通性检测异常 [$endpoint]: $e");
          if (Platform.isMacOS && e.toString().contains('Operation not permitted')) {
            logger.w("macOS 沙盒可能缺少网络客户端权限（com.apple.security.network.client）");
          }
          return false;
        }
      });

      final results = await Future.wait(checks);
      final connected = results.any((ok) => ok);
      if (!connected) {
        logger.e("外网连通性测试全部失败");
      }
      return connected;
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
      } else if (Platform.isMacOS) {
        // macOS: -W 单位是毫秒，-o 表示收到一个回复就退出
        result = await Process.run(
          'ping',
          ['-c', '1', '-W', '${timeoutSeconds * 1000}', '-o', targetIp],
          stdoutEncoding: systemEncoding,
          stderrEncoding: systemEncoding,
        );
      } else {
        // Linux / Android: -W 单位是秒
        result = await Process.run(
          'ping',
          ['-c', '1', '-W', '$timeoutSeconds', targetIp],
          stdoutEncoding: systemEncoding,
          stderrEncoding: systemEncoding,
        );
      }

      final output = result.stdout.toString().toLowerCase();
      if (result.exitCode == 0) {
        logger.i("Ping $targetIp 成功");
        return true;
      } else {
        logger.w("Ping $targetIp 失败 (exitCode=${result.exitCode})");
        if (output.isNotEmpty) {
          logger.w("Ping stdout: ${result.stdout}");
        }
        final err = result.stderr.toString();
        if (err.isNotEmpty) {
          logger.w("Ping stderr: $err");
        }
        return false;
      }
    } catch (e) {
      logger.e("Ping 执行失败: $e");
      return false;
    }
  }
}
