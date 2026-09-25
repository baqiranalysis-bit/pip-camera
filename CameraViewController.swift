import AVFoundation
import UIKit

final class CameraViewController: UIViewController {
    private let cameraManager = CameraManager()

    private var previewView = CameraPreviewView()
    private var pipManager: PiPManager?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "PIP Camera"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Camera is off"
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private lazy var flipButton = makeButton(title: "↔︎ Flip Camera")
    private lazy var pipButton = makeButton(title: "Start PiP")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()

        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.videoPreviewLayer.session = cameraManager.session

        pipManager = PiPManager(
            cameraManager: cameraManager,
            sourceView: previewView
        )

        flipButton.addTarget(self, action: #selector(flipCamera), for: .touchUpInside)
        pipButton.addTarget(self, action: #selector(startPiP), for: .touchUpInside)

        cameraManager.requestPermissionsAndStart { [weak self] granted in
            guard let self else { return }

            if granted {
                self.statusLabel.text = "Camera ready"
                self.pipButton.isEnabled = self.pipManager?.isSupported ?? false
            } else {
                self.statusLabel.text = "Camera permission is required"
                self.pipButton.isEnabled = false
            }
        }
    }

    private func setupUI() {
        view.addSubview(previewView)
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        view.addSubview(flipButton)
        view.addSubview(pipButton)

        previewView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        flipButton.translatesAutoresizingMaskIntoConstraints = false
        pipButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            flipButton.bottomAnchor.constraint(equalTo: pipButton.topAnchor, constant: -12),
            flipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            flipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            flipButton.heightAnchor.constraint(equalToConstant: 52),

            pipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            pipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            pipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            pipButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }

    private func makeButton(title: String) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .large
        config.baseBackgroundColor = .white
        config.baseForegroundColor = .black

        let button = UIButton(configuration: config)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        return button
    }

    @objc private func flipCamera() {
        cameraManager.switchCamera { [weak self] success in
            if !success {
                self?.statusLabel.text = "Couldn't switch camera"
            }
        }
    }

    @objc private func startPiP() {
        pipManager?.start()
    }
}
