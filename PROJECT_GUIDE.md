# 🛍️ Atelier Handmade Shop

Ứng dụng mobile bán hàng thủ công - sản phẩm da cao cấp handmade.

## 📱 Tính năng

### ✅ Đã hoàn thành
- **Trang chủ**: Hiển thị danh sách sản phẩm dạng grid
- **Chi tiết sản phẩm**: Xem thông tin chi tiết, hình ảnh, giá cả
- **Giỏ hàng**: Thêm/xóa sản phẩm, tăng/giảm số lượng
- **Yêu thích**: Lưu sản phẩm yêu thích
- **UI/UX**: Theme màu nâu da sang trọng, phù hợp với handmade shop

### 🚧 Chức năng sẽ phát triển
- Tìm kiếm sản phẩm
- Lọc theo danh mục
- Thanh toán
- Quản lý đơn hàng
- Tích hợp backend/API
- Đăng nhập/đăng ký
- Quản lý profile

## 🏗️ Cấu trúc project

```
lib/
├── main.dart                    # Entry point
├── configurations/              # Cấu hình app
│   ├── colors.dart             # Màu sắc
│   └── theme.dart              # Theme
├── models/                      # Data models
│   ├── product.dart            # Model sản phẩm
│   ├── category.dart           # Model danh mục
│   └── cart_item.dart          # Model giỏ hàng
├── components/                  # Reusable widgets
│   ├── product_card.dart       # Card hiển thị sản phẩm
│   ├── cart_item_card.dart     # Card item giỏ hàng
│   └── custom_button.dart      # Button tùy chỉnh
├── screens/                     # Màn hình
│   ├── home_screen.dart        # Trang chủ
│   ├── product_detail_screen.dart  # Chi tiết SP
│   ├── cart_screen.dart        # Giỏ hàng
│   └── favorites_screen.dart   # Yêu thích
└── services/                    # Services (sẽ phát triển)
```

## 🎨 Màu sắc chủ đạo

- **Primary**: `#8B5A3C` (Nâu da)
- **Secondary**: `#D4A574` (Vàng da)
- **Accent**: `#F5E6D3` (Kem nhạt)
- **Background**: `#FAF7F5` (Trắng ấm)

## 🚀 Cách chạy ứng dụng

### Windows (cần Developer Mode)
```powershell
$env:Path += ";C:\flutter\bin"
flutter run -d windows
```

### Chrome (Web)
```powershell
$env:Path += ";C:\flutter\bin"
flutter run -d chrome
```

### Hot Reload
- Nhấn `r` để hot reload
- Nhấn `R` (Shift+R) để hot restart
- Nhấn `q` để thoát

## 📦 Dependencies

- `google_fonts`: Font chữ (Playfair Display, Lato)
- `cached_network_image`: Cache hình ảnh
- `intl`: Format tiền tệ, ngày tháng

## 🎯 Hướng phát triển tiếp theo

1. **Tích hợp Backend**
   - API RESTful hoặc GraphQL
   - Firebase/Supabase cho real-time
   
2. **State Management**
   - Provider/Riverpod
   - Bloc pattern
   
3. **Tính năng nâng cao**
   - Push notifications
   - Payment gateway
   - Chat support
   - Social sharing

4. **Tối ưu hiệu suất**
   - Image optimization
   - Lazy loading
   - Caching strategy

## 💡 Ghi chú

- Dữ liệu hiện tại là mock data (hard-coded)
- Hình ảnh sản phẩm cần thêm vào `assets/images/`
- Logo Atelier cần thêm vào `assets/images/logo.png`

## 📸 Screenshots

_(Thêm screenshots khi hoàn thiện UI)_

## 👨‍💻 Developer

Handmade Shop App - Flutter Project
