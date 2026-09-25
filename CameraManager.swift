import AVFoundation

final class CameraManager: NSObject {
    let session = AVCaptureSession()

    private var currentCameraPosition: AVCaptureDevice.Position = .front
    private var videoInput: AVCaptureDeviceInput?
    private let sessionQueue = DispatchQueue(label: "com.baqir.PIPCamera.camera")

    var isRunning: Bool {
        session.isRunning
    }

    func requestPermissionsAndStart(completion: @escaping (Bool) -> Void) {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraStatus {
        case .authorized:
            configureAndStart(completion: completion)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async { completion(false) }
                    return
                }
                self?.configureAndStart(completion: completion)
            }
        default:
            DispatchQueue.main.async { completion(false) }
        }
    }

    private func configureAndStart(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self else { return }

            if self.session.inputs.isEmpty {
                self.session.beginConfiguration()
                self.session.sessionPreset = .high

                guard let camera = AVCaptureDevice.default(
                    .builtInWideAngleCamera,
                    for: .video,
                    position: self.currentCameraPosition
                ) else {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { completion(false) }
                    return
                }

                do {
                    let input = try AVCaptureDeviceInput(device: camera)
                    if self.session.canAddInput(input) {
                        self.session.addInput(input)
                        self.videoInput = input
                    }

                    if #available(iOS 16.0, *) {
                        self.session.isMultitaskingCameraAccessEnabled = true
                    }

                    self.session.commitConfiguration()
                } catch {
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { completion(false) }
                    return
                }
            }

            if !self.session.isRunning {
                self.session.startRunning()
            }

            DispatchQueue.main.async { completion(true) }
        }
    }

    func switchCamera(completion: @escaping (Bool) -> Void) {
        sessionQueue.async { [weak self] in
            guard let self, let currentInput = self.videoInput else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            let newPosition: AVCaptureDevice.Position =
                self.currentCameraPosition == .front ? .back : .front

            guard let newCamera = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: newPosition
            ) else {
                DispatchQueue.main.async { completion(false) }
                return
            }

            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)

                self.session.beginConfiguration()
                self.session.removeInput(currentInput)

                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoInput = newInput
                    self.currentCameraPosition = newPosition
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { completion(true) }
                } else {
                    self.session.addInput(currentInput)
                    self.session.commitConfiguration()
                    DispatchQueue.main.async { completion(false) }
                }
            } catch {
                DispatchQueue.main.async { completion(false) }
            }
        }
    }
}
