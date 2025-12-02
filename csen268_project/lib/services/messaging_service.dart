import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase In-App Messaging 服务
/// 负责管理应用内消息的触发、显示和回调处理
class MessagingService {
  static final MessagingService _instance = MessagingService._internal();
  factory MessagingService() => _instance;
  MessagingService._internal();

  final FirebaseInAppMessaging _inAppMessaging = FirebaseInAppMessaging.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// 初始化消息服务
  Future<void> initialize() async {
    try {
      debugPrint('🔔 Initializing MessagingService...');
      
      // 启用消息显示
      _inAppMessaging.setMessagesSuppressed(false);
      debugPrint('✅ In-App Messaging display enabled (suppressed: false)');
      
      // 启用自动数据收集（用于 Analytics）
      _inAppMessaging.setAutomaticDataCollectionEnabled(true);
      debugPrint('✅ Automatic data collection enabled');
      
      // 获取 FCM token
      try {
        final token = await _firebaseMessaging.getToken();
        if (token != null) {
          debugPrint('✅ FCM Token obtained: ${token.substring(0, 20)}...');
          debugPrint('📋 Full FCM Token (for testing): $token');
          debugPrint('💡 You can use this token in Firebase Console to send test messages');
        } else {
          debugPrint('⚠️ FCM Token is null - this may prevent In-App Messaging from working');
        }
      } catch (tokenError) {
        debugPrint('⚠️ Error getting FCM token: $tokenError');
        debugPrint('⚠️ In-App Messaging may not work without FCM token');
        // Token 获取失败不影响应用运行，继续执行
      }
      
      debugPrint('✅ MessagingService initialized successfully');
      debugPrint('🔔 Ready to trigger events. Make sure:');
      debugPrint('   1. Campaign is enabled in Firebase Console');
      debugPrint('   2. Trigger event name matches (e.g., "app_open")');
      debugPrint('   3. Campaign time schedule is active');
      debugPrint('   4. Device is connected to internet');
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error initializing MessagingService: $e');
      debugPrint('Stack trace: $stackTrace');
      // 即使初始化失败，也不应该阻止应用启动
    }
  }

  /// 触发应用打开事件
  /// 这通常用于在应用启动时触发 In-App Messaging
  Future<void> triggerAppOpen() async {
    await triggerEvent('app_open');
  }

  /// 触发自定义事件
  /// [eventName] 事件名称，需要在 Firebase Console 中配置
  Future<void> triggerEvent(String eventName) async {
    try {
      debugPrint('🔔 Attempting to trigger event: $eventName');
      
      // 确保消息没有被抑制
      _inAppMessaging.setMessagesSuppressed(false);
      debugPrint('🔔 Messages suppressed status: false');
      
      // 触发事件
      await _inAppMessaging.triggerEvent(eventName);
      debugPrint('✅ Successfully triggered In-App Messaging event: $eventName');
      debugPrint('🔔 Note: Message may take a few seconds to appear if campaign is configured correctly');
      
      // 额外调试：检查消息是否被抑制
      // 注意：Firebase In-App Messaging SDK 没有直接的方法检查抑制状态
      // 但我们可以通过日志确认事件已触发
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error triggering event $eventName: $e');
      debugPrint('Stack trace: $stackTrace');
      // 事件触发失败不应该影响应用功能
    }
  }

  /// 设置用户属性
  /// 用于精准投放消息
  Future<void> setUserProperty(String property, String? value) async {
    try {
      // 注意：Firebase In-App Messaging 使用 Analytics 的用户属性
      // 这里需要通过 Firebase Analytics 设置
      debugPrint('Setting user property: $property = $value');
      // TODO: 如果需要设置用户属性，需要导入 firebase_analytics
    } catch (e) {
      debugPrint('Error setting user property: $e');
    }
  }

  /// 临时抑制消息显示
  /// [suppressed] true 表示抑制，false 表示允许显示
  void setMessagesSuppressed(bool suppressed) {
    _inAppMessaging.setMessagesSuppressed(suppressed);
    debugPrint('Messages suppressed: $suppressed');
  }

  /// 获取 FCM token
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token retrieved: ${token.substring(0, 20)}...');
      }
      return token;
    } catch (e, stackTrace) {
      debugPrint('❌ Error getting FCM token: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
  
  /// 删除 FCM token（用于登出等场景）
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      debugPrint('✅ FCM Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  /// 监听消息点击事件
  /// 注意：Firebase In-App Messaging 的点击事件需要通过 Analytics 监听
  /// 或者通过消息内容中的 action URL 处理
  void setupMessageClickHandler() {
    // In-App Messaging 的点击处理通常通过消息内容中的 action 处理
    // 如果需要自定义处理，可以在消息配置中设置 action URL
    debugPrint('Message click handler setup');
  }
}

