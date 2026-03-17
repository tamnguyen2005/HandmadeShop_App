import 'package:shared_preferences/shared_preferences.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';

class SharedPreferencesService {
  Future<String?> getToken() async {
    SharedPreferences sharePreferences = await SharedPreferences.getInstance();
    return sharePreferences.getString("Token");
  }

  Future<void> setUserInfo(UserInfo user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("FullName", user.fullname);
    await sharedPreferences.setString("Email", user.email);
    await sharedPreferences.setString("ImageURL", user.imageURL);
    await sharedPreferences.setString("Token", user.token ?? "");
  }

  Future<UserInfo> getUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var fullname = sharedPreferences.getString("FullName") ?? "Chưa đăng nhập";
    var email = sharedPreferences.getString("Email") ?? "?@gmail.com";
    var imageURL = sharedPreferences.getString("ImageURL") ?? "";
    return UserInfo(fullname: fullname, email: email, imageURL: imageURL);
  }
}
