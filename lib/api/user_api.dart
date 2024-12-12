import 'dart:convert';

import 'package:http/http.dart';
import 'package:myapp/model/auth.dart';
import 'package:myapp/model/config.dart';
import 'package:myapp/model/user_model.dart';

class UserApi {
  Client client = Client();

  Future<User?> getUser() async {
    final headers = await Auth.getHeaders();
    final userId = await Auth.getUserid();
    final response = await client.get(Uri.parse("${Config().baseUrl}/user/$userId"), headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return User.fromJson(data['data']);
    } else {
      return null;
    }
  }
}