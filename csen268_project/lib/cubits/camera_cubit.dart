import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:csen268_project/cubits/camera_state.dart';

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(const CameraState());

  void initializeCamera() {
    // TODO: initialize the camera
    emit(state.copyWith(isInitialized: true));
  }

  void switchCameraMode(CameraMode mode) {
    emit(state.copyWith(cameraMode: mode));
  }

  void takePicture() {
    // TODO: take picture function
    print('Taking picture...');
  }

  void toggleRecording() {
    if (state.recordingState == RecordingState.idle) {
      emit(state.copyWith(recordingState: RecordingState.recording));
      // TODO: start recording
    } else {
      emit(state.copyWith(recordingState: RecordingState.idle));
      // TODO: stop recording
    }
  }

  void openGallery() {
    // TODO: open gallery
    print('Opening gallery...');
  }

  @override
  Future<void> close() {
    // TODO: release camera resources
    return super.close();
  }
}
