import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NetworkUtils {
  /// 获取本机的有效 WiFi IP 地址或者网络接口 IP，失败返回 null
  static Future<String?> getIpAddress() async {
    try {
      final info = NetworkInfo();
      String? wifiIP = await info.getWifiIP();
      if (wifiIP != null && wifiIP.isNotEmpty) {
        logger.i("WiFi IP: $wifiIP");
        return wifiIP;
      }
      
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            logger.i("Network IP: ${addr.address}");
            return addr.address;
          }
        }
      }
      return null;
    } catch (e) {
      logger.e("获取IP地址失败: $e");
      return null;
    }
  }

  /// 检查网络连接是否正常
  static Future<bool> isNetworkConnected() async {
    try {
      final response = await http.get(Uri.parse('https://www.gstatic.com/generate_204')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 204) {
        return true;
      } else {
        logger.w("网络未连接，HTTP状态码: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      logger.e("网络请求异常: $e");
      return false;
    }
  }

  /// 执行Ping测试
  static Future<bool> pingTest(String target, {int timeoutSeconds = 2}) async {
    bool success = false;
    for (int i = 0; i < 5; i++) {
      try {
        final socket = await Socket.connect(target, 80, timeout: Duration(seconds: timeoutSeconds));
        socket.destroy();
        logger.i("第 ${i + 1} 次 Ping $target 成功");
        success = true;
        break;
      } catch (e) {
        logger.e("第 ${i + 1} 次 Ping $target 失败: $e");
      }
    }
    return success;
  }
}
