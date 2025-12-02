# iOS Firebase In-App Messaging 配置和测试指南

## 📋 已完成的功能

### 1. iOS 原生配置
- ✅ 完善了 `AppDelegate.swift`，添加了完整的 APNs token 处理
- ✅ 实现了 `MessagingDelegate` 和 `UNUserNotificationCenterDelegate`
- ✅ 配置了通知权限请求
- ✅ 处理了前台和后台通知

### 2. Flutter 端集成
- ✅ 创建了 `MessagingService` 统一管理消息功能
- ✅ 在应用启动时自动触发 `app_open` 事件
- ✅ 在首页加载时触发 `home_page_viewed` 事件
- ✅ 添加了完善的错误处理和日志记录

### 3. 代码文件
- `ios/Runner/AppDelegate.swift` - iOS 原生配置
- `lib/services/messaging_service.dart` - Flutter 消息服务
- `lib/main.dart` - 应用启动时的初始化
- `lib/pages/home_page.dart` - 首页事件触发

## 🔧 Firebase Console 配置检查清单

在开始测试之前，请确认以下配置：

### 1. APNs 证书配置
1. 在 Apple Developer 创建 APNs 证书（开发/生产环境）
2. 在 Firebase Console → 项目设置 → Cloud Messaging → iOS 应用配置
3. 上传 APNs 证书（.p8 文件或 .p12 文件）
4. 确认 Bundle ID 匹配：`com.example.csen268Project`

### 2. Campaign 配置
1. 进入 Firebase Console → Engage → In-App Messaging
2. 确认你的 campaign 配置：
   - **触发事件**：`app_open`（或其他你配置的事件）
   - **目标平台**：包含 iOS
   - **时间安排**：已启用
   - **消息内容**：已配置

### 3. 测试 Campaign 创建
建议创建一个测试 campaign：
- **名称**：Test Campaign
- **触发事件**：`app_open`
- **目标**：所有用户或特定测试用户
- **消息类型**：Modal、Banner 或 Image
- **状态**：启用

## 🧪 测试步骤

### 1. 准备工作
```bash
# 1. 确保依赖已安装
cd csen268_project
flutter pub get

# 2. 更新 iOS Pods
cd ios
pod install
cd ..

# 3. 清理构建
flutter clean
flutter pub get
```

### 2. 在真实设备上测试
⚠️ **重要**：推送通知和 In-App Messaging 必须在真实 iOS 设备上测试，模拟器不支持。

1. **连接 iOS 设备**
   ```bash
   flutter devices  # 确认设备已连接
   ```

2. **运行应用**
   ```bash
   flutter run --release  # 或 flutter run
   ```

3. **检查日志**
   - 查看控制台输出，应该看到：
     - `✅ MessagingService initialized successfully`
     - `✅ FCM Token obtained: ...`
     - `✅ Triggered In-App Messaging event: app_open`

4. **验证消息显示**
   - 应用启动后，如果 campaign 配置正确，应该会显示 In-App 消息
   - 检查消息是否正确显示
   - 测试消息的点击行为

### 3. 调试技巧

#### 查看 FCM Token
在应用启动后，查看控制台日志中的 FCM Token。你可以在 Firebase Console 中：
- 进入项目设置 → Cloud Messaging
- 使用 "Send test message" 功能
- 输入 FCM Token 发送测试消息

#### 检查事件触发
在 Firebase Console → Analytics → Events 中查看：
- `app_open` 事件是否被记录
- `home_page_viewed` 事件是否被记录

#### 常见问题排查

**问题 1：消息不显示**
- ✅ 检查 FCM Token 是否获取成功
- ✅ 检查 Firebase Console 中 campaign 是否启用
- ✅ 检查触发事件名称是否匹配（`app_open`）
- ✅ 检查 campaign 的时间安排是否在有效期内
- ✅ 检查频次限制（可能已经显示过，需要等待或重置）

**问题 2：APNs Token 注册失败**
- ✅ 检查设备是否连接到网络
- ✅ 检查 Firebase Console 中 APNs 证书是否已上传
- ✅ 检查 Bundle ID 是否匹配
- ✅ 检查设备是否允许通知权限

**问题 3：权限被拒绝**
- ✅ 在 iOS 设置 → 你的应用 → 通知，检查权限状态
- ✅ 如果被拒绝，需要引导用户到设置中开启

## 📝 代码使用示例

### 触发自定义事件
```dart
import 'package:csen268_project/services/messaging_service.dart';

// 在任何页面触发事件
MessagingService().triggerEvent('custom_event_name');
```

### 临时抑制消息
```dart
// 抑制消息显示（例如在特定页面）
MessagingService().setMessagesSuppressed(true);

// 恢复消息显示
MessagingService().setMessagesSuppressed(false);
```

### 获取 FCM Token
```dart
final token = await MessagingService().getFCMToken();
print('FCM Token: $token');
```

## 🚀 下一步优化建议

1. **用户属性设置**
   - 如果需要精准投放，可以集成 `firebase_analytics` 设置用户属性
   - 例如：用户等级、订阅状态等

2. **消息点击处理**
   - 在 Firebase Console 中配置消息的 action URL
   - 在应用中处理 deep link 导航

3. **A/B 测试**
   - 在 Firebase Console 中创建多个 campaign 变体
   - 测试不同消息内容的效果

4. **Analytics 集成**
   - 跟踪消息展示次数
   - 跟踪消息点击率
   - 分析用户行为

## 📚 相关文档

- [Firebase In-App Messaging 文档](https://firebase.google.com/docs/in-app-messaging)
- [Flutter Firebase In-App Messaging 插件](https://pub.dev/packages/firebase_in_app_messaging)
- [Firebase Cloud Messaging 文档](https://firebase.google.com/docs/cloud-messaging)

## ⚠️ 注意事项

1. **测试环境**：必须在真实 iOS 设备上测试，模拟器不支持推送通知
2. **证书配置**：确保 APNs 证书已正确上传到 Firebase Console
3. **Bundle ID**：确保 Firebase 项目中的 Bundle ID 与应用配置一致
4. **权限**：首次运行需要用户授权通知权限
5. **网络**：确保设备连接到互联网，以便获取消息配置

