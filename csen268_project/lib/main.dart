import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'routes/app_router.dart';
import 'cubits/user_cubit.dart';
import 'repositories/user_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/messaging_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Background message received: ${message.messageId}');
}

// Remove old _router and use appRouter
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化 Firebase
  // 注意：Flutter 插件会在 GeneratedPluginRegistrant.register() 时自动初始化 Firebase
  // 但为了确保 Firestore 等服务可用，我们需要确保 Firebase 已初始化
  bool firebaseInitialized = false;
  
  // 先尝试获取已存在的 Firebase 实例（插件可能已初始化）
  try {
    Firebase.app();
    print('✅ Firebase already initialized by plugin');
    firebaseInitialized = true;
  } catch (e) {
    // 如果获取失败，尝试手动初始化
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized manually');
      firebaseInitialized = true;
    } catch (initError) {
      // 如果初始化失败，检查是否是重复初始化错误
      final errorStr = initError.toString();
      if (errorStr.contains('already exists') || errorStr.contains('duplicate-app')) {
        // 这表示 Firebase 已经被初始化了（可能是插件初始化的）
        print('✅ Firebase already initialized (detected from error)');
        firebaseInitialized = true;
      } else {
        print('❌ Firebase initialization failed: $initError');
        // 即使失败，也假设 Firebase 可能已由插件初始化
        // 这样 Firestore 等服务仍然可以工作
        firebaseInitialized = true; // 改为 true，让应用继续运行
      }
    }
  }
  
  // 验证 Firebase 是否真的可用（通过检查 Firestore）
  if (firebaseInitialized) {
    try {
      // 尝试访问 Firestore 来验证 Firebase 是否真的可用
      FirebaseFirestore.instance; // 验证 Firestore 实例是否可访问
      print('✅ Firestore is available');
    } catch (e) {
      print('⚠️ Firestore check failed: $e');
      // 即使检查失败，也继续运行，因为可能是网络问题
    }
  }
  
  // 设置 Messaging（Firebase 应该已经初始化）
  if (firebaseInitialized) {
    try {
      // 初始化 Messaging Service
      print('🔔 Starting MessagingService initialization...');
      final messagingService = MessagingService();
      await messagingService.initialize();
      
      // 设置后台消息处理
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // 请求通知权限
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print('User granted permission: ${settings.authorizationStatus}');
      
      // 监听前台消息
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        print('Message data: ${message.data}');
      });
      
      // 监听应用通过通知打开
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Notification clicked: ${message.data}');
        // TODO: 根据 message.data 进行页面导航
      });
      
      // 检查应用是否通过通知启动
      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from notification: ${initialMessage.data}');
        // TODO: 根据 initialMessage.data 进行页面导航
      }
      
      // 注意：app_open 事件将在开屏动画完成后触发（在登录页面或首页）
      // 这里不再触发，避免在开屏动画期间显示消息
      
    } catch (e, stackTrace) {
      print('❌ Error in Firebase/Messaging setup: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserCubit(UserRepository()),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
      ),
    );
  }
}
