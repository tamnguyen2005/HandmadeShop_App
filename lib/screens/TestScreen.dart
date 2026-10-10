import 'package:flutter/material.dart';
import 'package:handmadeshop_app/services/APIClient.dart';
import 'package:handmadeshop_app/services/ProductService.dart';

class TestScreen extends StatefulWidget {
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String id = "";
  APIClient apiClient = APIClient();
  late ProductService service = ProductService(apiClient);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(id),
          ElevatedButton(
            onPressed: () async {
              var product = await service.GetProductDetail(
                "d371f00a-7673-40a0-913b-09b94a3722bc",
              );
              setState(() {
                id = product?.Id ?? "Không gọi được api rùi :((";
              });
            },
            child: const Text("get"),
          ),
        ],
      ),
    );
  }
}
