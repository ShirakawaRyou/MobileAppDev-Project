## About This App ##

This is a Flutter-based mobile media editing application that allows users to capture, edit, and manage photos and videos. The app features comprehensive image and video editing tools, camera integration, project management, and cloud synchronization using Firebase.

## Contribution ##
Kaicheng Luo: Editor Page, also the idea originator

Yu Cheng Wu: Export Page

Yitang Li: Home Page, Login & Registration Page, User Page, User and Project Firebase database, Android Firebase notification

Yunjia Zheng: Animated splash screen, Media Selection Page, Camera Page, iOS Firebase notification

## External APIs ##
By opening console.firebase.google.com, log in and open the project in your workspace, then it will work.

## Execution Guide ##

### Prerequisites
1. Install Flutter SDK (version 3.9.2 or higher)
2. Install Android Studio / Xcode (for Android/iOS development)
3. Configure Firebase project (see instructions below)

### Running Steps
1. **Clone the project and navigate to the directory**
   ```bash
   cd csen268_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Ensure `android/app/google-services.json` is configured (Android)
   - Ensure iOS project is configured with Firebase (iOS)
   - Enable Authentication and Firestore in Firebase Console

4. **Run the application**
   ```bash
   # Android
   flutter run
   
   # iOS (macOS only)
   flutter run -d ios
   
   # Specify device
   flutter devices  # View available devices
   flutter run -d <device_id>
   ```

5. **Build release version**
   ```bash
   # Android APK
   flutter build apk
   
   # iOS (requires macOS and Xcode)
   flutter build ios
   ```

## App Architecture Overview ##

This application is developed using Flutter framework with the following architecture patterns and technology stack:

### Architecture Patterns
- **State Management**: BLoC (Business Logic Component) pattern using `flutter_bloc` package
- **Routing Management**: Declarative routing management using `go_router`
- **Data Layer**: Repository pattern to separate data fetching logic

### Technology Stack
- **Frontend Framework**: Flutter (Dart)
- **Backend Services**: Firebase (Authentication, Firestore, Cloud Messaging)
- **State Management**: BLoC/Cubit
- **Routing**: GoRouter
- **Media Processing**: 
  - `camera`: Camera functionality
  - `image_picker`: Image selection
  - `photo_manager`: Photo album management
  - `video_player`: Video playback
  - `video_editor`: Video editing
  - `image_cropper`: Image cropping

### Project Structure
```
lib/
├── cubits/          # State management (BLoC/Cubit)
├── models/          # Data models
├── pages/           # Page components
├── repositories/    # Data repository layer
├── routes/          # Routing configuration
├── services/        # Service layer (e.g., messaging)
└── widgets/         # Reusable components
```

### Data Flow
1. **User Authentication**: Firebase Authentication → UserCubit → UI
2. **Project Management**: Firestore → ProjectRepository → ProjectCubit → UI
3. **Media Processing**: Local file system → Editor → Export → Firestore/Local storage

## Feature Overview ##

### Features Developed by Yitang Li

#### Home Page
- Display all user projects list
- Support creating new projects
- Project card display, click to view details
- Integrated Firebase real-time data synchronization
- Support project search and filtering

#### Login & Registration Page
- User registration functionality using Firebase Authentication
- User login functionality supporting email/password authentication
- Form validation and error handling
- User session management

#### User Page
- Display user personal information
- User settings and preference configuration
- Account management functionality

#### User and Project Firebase Database
- Firestore database design
- User data model and CRUD operations
- Project data model and CRUD operations
- Data synchronization and real-time updates

#### Android Firebase Notification
- Firebase Cloud Messaging integration
- Android platform push notification configuration
- Background message handling
- Notification click event handling

### Features Developed by Yunjia Zheng

#### Animated Splash Screen
- Animation effects when the application starts
- Automatic navigation to the home page

#### Media Selection Page
- Select images and videos from device photo album
- Support multi-select media files
- Media preview functionality
- Add selected photos to new project

#### Camera Page
- Real-time camera preview
- Photo capture and video recording functionality
- Camera permission management
- Store captured photos/videos to local photo album

#### iOS Firebase Notification
- Firebase Cloud Messaging integration
- iOS platform push notification configuration
- APNs certificate configuration
- iOS notification permission request and handling

### Features Developed by Kaicheng Luo

#### Editor Page
- **Image Editing Features**:
  - Rotation, brightness, contrast, saturation adjustment
  - Color temperature adjustment
  - Image cropping
- **Video Editing Features**:
  - Video playback control
  - Video cropping and trimming
  - Video filters and effects
- Real-time preview of editing effects
- Support undo and redo operations
- Export to export page after editing completion

### Features Developed by Yu Cheng Wu

#### Export Page
- Final preview after editing completion
- Project naming and saving
- Save to local photo album
- Share functionality (using system share)
- Save project to Firebase Firestore
- Support export of both image and video media types
