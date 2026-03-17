import 'APIClient.dart';
import 'package:handmadeshop_app/models/Coupon/Coupon.dart';

class CouponService {
  APIClient apiClient;
  CouponService({required this.apiClient});
  Future<List<Coupon>> GetAllCoupon() async {
    var response = await apiClient.get("/Coupon");
    if (response.isSuccess) {
      return (response.data as List).map((c) => Coupon.fromJson(c)).toList();
    } else {
      return [];
    }
  }
}
