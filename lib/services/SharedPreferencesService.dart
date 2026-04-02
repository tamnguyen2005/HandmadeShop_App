import 'package:shared_preferences/shared_preferences.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';

class SharedPreferencesService {
  static const String _avatarBase64Key = "AvatarBase64";
  static const String _defaultReceiverKey = "DefaultReceiver";
  static const String _defaultPhoneKey = "DefaultPhone";
  static const String _defaultAddressKey = "DefaultAddress";

  Future<String?> getToken() async {
    SharedPreferences sharePreferences = await SharedPreferences.getInstance();
    return sharePreferences.getString("Token");
  }

  Future<void> setUserInfo(UserInfo user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString("FullName", user.fullname);
    await sharedPreferences.setString("Email", user.email);
    await sharedPreferences.setString("ImageURL", user.imageURL);
    await sharedPreferences.setString(_avatarBase64Key, user.avatarBase64);
    await sharedPreferences.setString("Token", user.token ?? "");
  }

  Future<void> setAvatarBase64(String avatarBase64) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_avatarBase64Key, avatarBase64);
  }

  Future<void> setDefaultShippingInfo({
    required String receiver,
    required String phone,
    required String address,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_defaultReceiverKey, receiver);
    await sharedPreferences.setString(_defaultPhoneKey, phone);
    await sharedPreferences.setString(_defaultAddressKey, address);
  }

  Future<Map<String, String>> getDefaultShippingInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return {
      'receiver': sharedPreferences.getString(_defaultReceiverKey) ?? '',
      'phone': sharedPreferences.getString(_defaultPhoneKey) ?? '',
      'address': sharedPreferences.getString(_defaultAddressKey) ?? '',
    };
  }

  Future<String> getAvatarBase64() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(_avatarBase64Key) ?? "";
  }

  Future<UserInfo> getUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var fullname = sharedPreferences.getString("FullName") ?? "Chưa đăng nhập";
    var email = sharedPreferences.getString("Email") ?? "?@gmail.com";
    var imageURL = sharedPreferences.getString("ImageURL") ?? "";
    var avatarBase64 = sharedPreferences.getString(_avatarBase64Key) ?? "";
    return UserInfo(
      fullname: fullname,
      email: email,
      imageURL: imageURL,
      avatarBase64: avatarBase64,
    );
  }

  Future<void> clearUserInfo() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove("FullName");
    await sharedPreferences.remove("Email");
    await sharedPreferences.remove("ImageURL");
    await sharedPreferences.remove(_avatarBase64Key);
    await sharedPreferences.remove(_defaultReceiverKey);
    await sharedPreferences.remove(_defaultPhoneKey);
    await sharedPreferences.remove(_defaultAddressKey);
    await sharedPreferences.remove("Token");
  }
}
