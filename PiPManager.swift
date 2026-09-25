import AVKit
import AVFoundation
import UIKit

final class PiPManager: NSObject, AVPictureInPictureControllerDelegate {
    private let cameraManager: CameraManager
    private weak var sourceView: UIView?

    private var pipController: AVPictureInPictureController?
    private var pipViewController: AVPictureInPictureVideoCallViewController?
    private var pipPreviewView: CameraPreviewView?

    init(cameraManager: CameraManager, sourceView: UIView) {
        self.cameraManager = cameraManager
        self.sourceView = sourceView
        super.init()
        setupPiP()
    }

    private func setupPiP() {
        guard AVPictureInPictureController.isPictureInPictureSupported() else {
            return
        }

        let callViewController = AVPictureInPictureVideoCallViewController()
        callViewController.preferredContentSize = CGSize(width: 9, height: 16)

        let preview = CameraPreviewView()
        preview.videoPreviewLayer.session = cameraManager.session
        preview.videoPreviewLayer.videoGravity = .resizeAspectFill

        callViewController.view.addSubview(preview)
        preview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            preview.leadingAnchor.constraint(equalTo: callViewController.view.leadingAnchor),
            preview.trailingAnchor.constraint(equalTo: callViewController.view.trailingAnchor),
            preview.topAnchor.constraint(equalTo: callViewController.view.topAnchor),
            preview.bottomAnchor.constraint(equalTo: callViewController.view.bottomAnchor)
        ])

        guard let sourceView else { return }

        let contentSource = AVPictureInPictureController.ContentSource(
            activeVideoCallSourceView: sourceView,
            contentViewController: callViewController
        )

        let controller = AVPictureInPictureController(contentSource: contentSource)
        controller.delegate = self
        controller.canStartPictureInPictureAutomaticallyFromInline = false

        pipViewController = callViewController
        pipPreviewView = preview
        pipController = controller
    }

    func start() {
        guard let pipController else { return }
        guard AVPictureInPictureController.isPictureInPictureSupported() else { return }

        if !pipController.isPictureInPictureActive {
            pipController.startPictureInPicture()
        }
    }

    func stop() {
        pipController?.stopPictureInPicture()
    }

    var isSupported: Bool {
        AVPictureInPictureController.isPictureInPictureSupported()
    }

    func pictureInPictureControllerWillStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {}

    func pictureInPictureControllerDidStartPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {}

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        failedToStartPictureInPictureWithError error: Error
    ) {
        print("PiP failed: \(error.localizedDescription)")
    }

    func pictureInPictureControllerWillStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {}

    func pictureInPictureControllerDidStopPictureInPicture(
        _ pictureInPictureController: AVPictureInPictureController
    ) {}

    func pictureInPictureController(
        _ pictureInPictureController: AVPictureInPictureController,
        restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void
    ) {
        completionHandler(true)
    }
}

final class CameraPreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}
