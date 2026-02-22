import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginManager {
  final String loginUrl;

  LoginManager({this.loginUrl = "http://10.9.18.71/quickauth.do"});

  /// 执行登录操作
  Future<(bool, String)> login(String username, String password, String ipAddress) async {
    final Map<String, String> data = {
      "auth_type": "PAP",
      "wlanacname": "NFV-BASE",
      "wlanacIp": "10.9.11.145",
      "wlanuserip": ipAddress,
      "userid": username,
      "passwd": password,
    };

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        body: data,
      ).timeout(const Duration(seconds: 3));

      print(response.body);

      // JSON 响应解析
      final decoded = jsonDecode(response.body);
      final code = decoded["reccode"]?.toString() ?? "-1";
      final recMessage = decoded["rec"]?.toString() ?? "未知错误";

      if (code == "200") {
        return (true, "登录成功");
      } else if (code == "199") {
        return (false, "参数错误");
      } else if (code == "202") {
        return (false, "帐号不存在");
      } else if (code == "203") {
        return (false, "密码错误");
      } else if (code == "205") {
        return (false, "帐号不存在");
      } else if (code == "213") {
        return (false, "密码错误");
      } else {
        return (false, recMessage);
      }
    } catch (e) {
      return (false, "请求失败: $e");
    }
  }

  /// 执行下线操作
  Future<(bool, String)> logout() async {
    const url = "http://10.9.11.145/cgi-bin/wlogout.cgi";
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 1));
      if (response.statusCode == 200) {
        return (true, "下线成功");
      } else {
        return (false, "HTTP状态码: ${response.statusCode}");
      }
    } catch (e) {
      return (false, "请求失败: $e");
    }
  }
}
