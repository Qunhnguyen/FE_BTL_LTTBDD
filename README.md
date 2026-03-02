# 🎓 Quiz App - Hệ thống Thi Trắc nghiệm Trực tuyến

**Quiz App** là một ứng dụng di động được xây dựng bằng Flutter, cung cấp giải pháp học tập và thi trắc nghiệm trực tuyến toàn diện cho cả **Sinh viên** và **Giảng viên**. Ứng dụng hỗ trợ trải nghiệm thời gian thực, giao diện hiện đại và tính năng quản lý mạnh mẽ.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Riverpod](https://img.shields.io/badge/Riverpod-%23000000.svg?style=for-the-badge&logo=riverpod&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

---

## ✨ Tính năng chính

### 👨‍🎓 Dành cho Sinh viên
*   **Trang chủ:** Theo dõi các cuộc thi đang diễn ra, sắp tới và đã kết thúc.
*   **Làm bài thi:** Giao diện làm bài chuyên nghiệp với đồng hồ đếm ngược, thanh tiến trình và các vật phẩm trợ giúp (50/50, Bỏ qua).
*   **Kết quả:** Xem điểm số, số câu đúng và thời gian hoàn thành ngay sau khi nộp bài.
*   **Bảng xếp hạng:** Vinh danh Top 3 trên bục podium và theo dõi thứ hạng cá nhân.
*   **Lịch sử:** Xem lại toàn bộ quá trình làm bài được nhóm theo tháng.

### 👩‍🏫 Dành cho Giảng viên (Admin)
*   **Dashboard:** Thống kê tổng quan về số lượng câu hỏi, môn học và bài thi.
*   **Quản lý câu hỏi:** Danh sách câu hỏi đa dạng (Trắc nghiệm, Tự luận, Hình ảnh) với bộ lọc theo độ khó.
*   **Nhập liệu CSV:** Hỗ trợ import hàng loạt câu hỏi từ file CSV nhanh chóng.

---

## 🛠 Công nghệ sử dụng

*   **Framework:** Flutter (Kênh Stable).
*   **Quản lý trạng thái:** [Riverpod](https://riverpod.dev/) (State Management mạnh mẽ, an toàn).
*   **Điều hướng:** [GoRouter](https://pub.dev/packages/go_router) (Quản lý Deep-links và Nested routes).
*   **Giao diện:** 
    *   Hỗ trợ **Dark Mode** & **Light Mode**.
    *   Font chữ chủ đạo: **Lexend** (Google Fonts).
    *   Icon: Material Symbols Outlined.
*   **Kiến trúc:** Layered Architecture (Phân lớp theo Features).

---

## 📂 Cấu trúc thư mục

```
lib/
├── core/               # Chứa các cấu hình dùng chung (Theme, Router, Config)
├── features/           # Chứa các module chức năng
│   ├── auth/           # Đăng nhập và xác thực
│   ├── student/        # Các màn hình dành cho Sinh viên (Home, Quiz, Leaderboard, History)
│   ├── teacher/        # Các màn hình dành cho Giảng viên (Dashboard, Questions)
│   └── _shell/         # Giao diện khung (Bottom Navigation Bar)
└── main.dart           # Điểm khởi chạy ứng dụng
```

---

## 🚀 Bắt đầu

### Điều kiện tiên quyết
*   Flutter SDK: `>=3.2.0`
*   Dart SDK: `>=3.2.0`

### Cài đặt
1. Clone repository:
   ```sh
   git clone <URL_REPO_CUA_BAN>
   ```

2. Cài đặt các thư viện:
   ```sh
   flutter pub get
   ```

3. Chạy ứng dụng:
   ```sh
   flutter run
   ```

### 🔑 Thông tin đăng nhập (Mock Data)
Hiện tại ứng dụng đang sử dụng dữ liệu giả lập (Mock Data), bạn có thể đăng nhập với **bất kỳ tài khoản/mật khẩu nào**:
*   Chọn tab **Sinh viên** để trải nghiệm luồng thi.
*   Chọn tab **Giảng viên** để trải nghiệm luồng quản lý.

---

## 📝 Giấy phép
Dự án được phát hành dưới giấy phép MIT.

---
**Phát triển cho môn học: Phát triển ứng dụng cho các thiết bị di động** - 2024
