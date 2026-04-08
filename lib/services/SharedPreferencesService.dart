import 'package:shared_preferences/shared_preferences.dart';
import 'package:handmadeshop_app/models/User/UserInfo.dart';

class SharedPreferencesService {
  static const String _avatarBase64Key = "AvatarBase64";
  static const String _defaultReceiverKey = "DefaultReceiver";
  static const String _defaultPhoneKey = "DefaultPhone";
  static const String _defaultAddressKey = "DefaultAddress";
  static const String _favoriteProductIdsKey = "FavoriteProductIds";

  String _shippingKey(String email, String suffix) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      return suffix;
    }
    return '${suffix}_$normalizedEmail';
  }

  Future<String?> getToken() async {
    SharedPreferences sharePreferences = await SharedPreferences.getInstance();
    return sharePreferences.getString("Token");
  }

  Future<void> setUserInfo(UserInfo user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final existingImageUrl = sharedPreferences.getString("ImageURL") ?? "";
    final existingToken = sharedPreferences.getString("Token") ?? "";
    await sharedPreferences.setString("FullName", user.fullname);
    await sharedPreferences.setString("Email", user.email);
    await sharedPreferences.setString(
      "ImageURL",
      user.imageURL.trim().isNotEmpty ? user.imageURL : existingImageUrl,
    );
    final existingAvatarBase64 = sharedPreferences.getString(_avatarBase64Key) ?? "";
    final nextAvatarBase64 = user.avatarBase64.trim().isNotEmpty
        ? user.avatarBase64
        : existingAvatarBase64;
    await sharedPreferences.setString(_avatarBase64Key, nextAvatarBase64);
    await sharedPreferences.setString(
      "Token",
      (user.token ?? "").trim().isNotEmpty ? user.token! : existingToken,
    );
  }

  Future<void> setAvatarBase64(String avatarBase64) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_avatarBase64Key, avatarBase64);
  }

  Future<void> setDefaultShippingInfo({
    required String receiver,
    required String phone,
    required String address,
    String? userEmail,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final receiverKey = userEmail == null ? _defaultReceiverKey : _shippingKey(userEmail, _defaultReceiverKey);
    final phoneKey = userEmail == null ? _defaultPhoneKey : _shippingKey(userEmail, _defaultPhoneKey);
    final addressKey = userEmail == null ? _defaultAddressKey : _shippingKey(userEmail, _defaultAddressKey);
    await sharedPreferences.setString(receiverKey, receiver);
    await sharedPreferences.setString(phoneKey, phone);
    await sharedPreferences.setString(addressKey, address);
  }

  Future<Map<String, String>> getDefaultShippingInfo({String? userEmail}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final receiverKey = userEmail == null ? _defaultReceiverKey : _shippingKey(userEmail, _defaultReceiverKey);
    final phoneKey = userEmail == null ? _defaultPhoneKey : _shippingKey(userEmail, _defaultPhoneKey);
    final addressKey = userEmail == null ? _defaultAddressKey : _shippingKey(userEmail, _defaultAddressKey);

    final receiver = sharedPreferences.getString(receiverKey) ?? sharedPreferences.getString(_defaultReceiverKey) ?? '';
    final phone = sharedPreferences.getString(phoneKey) ?? sharedPreferences.getString(_defaultPhoneKey) ?? '';
    final address = sharedPreferences.getString(addressKey) ?? sharedPreferences.getString(_defaultAddressKey) ?? '';

    return {
      'receiver': receiver,
      'phone': phone,
      'address': address,
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
    await sharedPreferences.remove("Token");
  }

  Future<List<String>> getFavoriteProductIds() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getStringList(_favoriteProductIdsKey) ?? [];
  }

  Future<void> setFavoriteProductIds(List<String> ids) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uniqueIds = ids.where((id) => id.trim().isNotEmpty).toSet().toList();
    await sharedPreferences.setStringList(_favoriteProductIdsKey, uniqueIds);
  }

  Future<void> clearFavoriteProductIds() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove(_favoriteProductIdsKey);
  }
}
