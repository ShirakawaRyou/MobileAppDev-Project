import Flutter
import UIKit
import AVFoundation
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var frontCameraMethodChannel: FlutterMethodChannel?
  private var frontCameraEventChannel: FlutterEventChannel?
  private var frontCameraEventSink: FlutterEventSink?
  private var frontCameraSession: AVCaptureSession?
  private var frontCameraOutput: AVCaptureVideoDataOutput?
  private var frontCameraDevice: AVCaptureDevice?
  private var streamHandler: FrontCameraStreamHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    
    // Setup method channel for controlling front camera
    frontCameraMethodChannel = FlutterMethodChannel(
      name: "com.csen268_project/front_camera",
      binaryMessenger: controller.binaryMessenger
    )
    
    frontCameraMethodChannel?.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard let self = self else { return }
      
      switch call.method {
      case "startFrontCameraFrameCapture":
        self.startFrontCameraFrameCapture(result: result)
      case "stopFrontCameraFrameCapture":
        self.stopFrontCameraFrameCapture(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    // Setup event channel for streaming frame data
    streamHandler = FrontCameraStreamHandler()
    streamHandler?.onSinkSet = { [weak self] sink in
      self?.frontCameraEventSink = sink
    }
    
    frontCameraEventChannel = FlutterEventChannel(
      name: "com.csen268_project/front_camera_frames",
      binaryMessenger: controller.binaryMessenger
    )
    
    frontCameraEventChannel?.setStreamHandler(streamHandler)
    
    GeneratedPluginRegistrant.register(with: self)
    // Note: Firebase is automatically configured by Flutter plugins
    // No need to call FirebaseApp.configure() here
    
    // 设置 Firebase Messaging 代理
    Messaging.messaging().delegate = self
    
    // 注册通知委托
    UNUserNotificationCenter.current().delegate = self
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
      if let error = error {
        print("Notification authorization error: \(error.localizedDescription)")
      } else {
        print("Notification authorization granted: \(granted)")
        if granted {
          DispatchQueue.main.async {
            application.registerForRemoteNotifications()
          }
        }
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startFrontCameraFrameCapture(result: @escaping FlutterResult) {
    // Check camera permission
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
      guard let self = self, granted else {
        result(FlutterError(code: "PERMISSION_DENIED", message: "Camera permission denied", details: nil))
        return
      }
      
      DispatchQueue.main.async {
        do {
          // Find front camera
          guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            result(FlutterError(code: "NO_CAMERA", message: "Front camera not found", details: nil))
            return
          }
          
          self.frontCameraDevice = frontCamera
          
          // Create capture session
          let session = AVCaptureSession()
          session.sessionPreset = .medium
          
          // Create input
          let input = try AVCaptureDeviceInput(device: frontCamera)
          guard session.canAddInput(input) else {
            result(FlutterError(code: "CANNOT_ADD_INPUT", message: "Cannot add camera input", details: nil))
            return
          }
          session.addInput(input)
          
          // Create output
          let output = AVCaptureVideoDataOutput()
          output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
          ]
          output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "frontCameraQueue"))
          
          guard session.canAddOutput(output) else {
            result(FlutterError(code: "CANNOT_ADD_OUTPUT", message: "Cannot add camera output", details: nil))
            return
          }
          session.addOutput(output)
          
          self.frontCameraSession = session
          self.frontCameraOutput = output
          
          // Start session
          session.startRunning()
          
          result(true)
        } catch {
          result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
        }
      }
    }
  }
  
  private func stopFrontCameraFrameCapture(result: @escaping FlutterResult) {
    frontCameraSession?.stopRunning()
    frontCameraSession = nil
    frontCameraOutput = nil
    frontCameraDevice = nil
    frontCameraEventSink = nil
    result(true)
  }
  
  // MARK: - APNs Token Registration
  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    print("APNs token registered: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    // 将 APNs token 传递给 Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
  }
  
  override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }
}

// MARK: - FCM Delegate
extension AppDelegate: MessagingDelegate {
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print("FCM registration token: \(fcmToken ?? "nil")")
    // 可以将 token 发送到服务器或保存到本地
    if let token = fcmToken {
      // TODO: 如果需要，可以将 token 发送到你的服务器
      UserDefaults.standard.set(token, forKey: "fcm_token")
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate
// Note: FlutterAppDelegate already conforms to UNUserNotificationCenterDelegate
// We just override the methods here
extension AppDelegate {
  // 当应用在前台时收到通知
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    let userInfo = notification.request.content.userInfo
    print("Notification received in foreground: \(userInfo)")
    
    // 即使在前台也显示通知（可选）
    if #available(iOS 14.0, *) {
      completionHandler([.banner, .badge, .sound])
    } else {
      completionHandler([.alert, .badge, .sound])
    }
  }
  
  // 用户点击通知时的处理
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    print("Notification clicked: \(userInfo)")
    
    // 处理通知点击，可以导航到特定页面
    // TODO: 根据 userInfo 中的数据进行页面导航
    
    completionHandler()
  }
}

// Event channel stream handler
class FrontCameraStreamHandler: NSObject, FlutterStreamHandler {
  var onSinkSet: ((FlutterEventSink?) -> Void)?
  
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    onSinkSet?(events)
    return nil
  }
  
  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    onSinkSet?(nil)
    return nil
  }
}

extension AppDelegate: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }
    
    let width = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    
    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
    
    let data = Data(bytes: baseAddress, count: height * bytesPerRow)
    
    // Send frame data to Flutter via event channel
    // Throttle to avoid overwhelming the channel
    DispatchQueue.main.async { [weak self] in
      guard let sink = self?.frontCameraEventSink else { return }
      let typedData = FlutterStandardTypedData(bytes: data)
      sink([
        "data": typedData,
        "width": width,
        "height": height
      ] as [String: Any])
    }
  }
}
