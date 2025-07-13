import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func didCaptureImage(_ image: UIImage) {
            parent.onImageCaptured(image)
            parent.dismiss()
        }
        
        func didCancel() {
            parent.dismiss()
        }
    }
}

protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureImage(_ image: UIImage)
    func didCancel()
}

class CameraViewController: UIViewController {
    weak var delegate: CameraViewControllerDelegate?
    
    private var captureSession: AVCaptureSession!
    private var stillImageOutput: AVCapturePhotoOutput!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var currentDevice: AVCaptureDevice?
    private var flashButton: UIButton!
    private var captureButton: UIButton!
    private var isFlashOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCameraPermissions()
    }
    
    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.main.async {
                self.setupCamera()
                self.setupUI()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                        self?.setupUI()
                    } else {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            showPermissionDeniedAlert()
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please allow camera access in Settings to scan food.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.delegate?.didCancel()
        })
        present(alert, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start camera session
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            if let session = self.captureSession, !session.isRunning {
                session.startRunning()
                print("✅ Camera session started")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        // Get the best camera for food photography
        guard let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("❌ Back camera not available")
            showCameraUnavailableAlert()
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            currentDevice = backCamera
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                
                setupPreviewLayer()
                configureCameraSettings(backCamera)
                print("✅ Camera setup completed")
            } else {
                print("❌ Cannot add camera input/output")
                showCameraUnavailableAlert()
            }
        } catch {
            print("❌ Camera input error: \(error.localizedDescription)")
            showCameraUnavailableAlert()
        }
    }
    
    private func showCameraUnavailableAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "Camera Unavailable",
                message: "Unable to access the camera. Please try again.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.delegate?.didCancel()
            })
            self.present(alert, animated: true)
        }
    }
    
    private func configureCameraSettings(_ camera: AVCaptureDevice) {
        // Configure camera for food photography
        do {
            try camera.lockForConfiguration()
            
            // Set focus mode for close-up food shots
            if camera.isFocusModeSupported(.continuousAutoFocus) {
                camera.focusMode = .continuousAutoFocus
            }
            
            // Set exposure mode for consistent lighting
            if camera.isExposureModeSupported(.continuousAutoExposure) {
                camera.exposureMode = .continuousAutoExposure
            }
            
            camera.unlockForConfiguration()
            print("✅ Camera settings configured")
        } catch {
            print("❌ Camera configuration error: \(error)")
        }
    }
    
    private func setupPreviewLayer() {
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        // Fix orientation issue
        if #available(iOS 17.0, *) {
            videoPreviewLayer.connection?.videoRotationAngle = 90
        } else {
            videoPreviewLayer.connection?.videoOrientation = .portrait
        }
        
        view.layer.insertSublayer(videoPreviewLayer, at: 0)
        print("✅ Preview layer setup completed")
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        // Food scanning overlay guide
        let overlayView = createScanningOverlay()
        view.addSubview(overlayView)
        
        // Flash/torch button
        flashButton = UIButton(type: .system)
        flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
        flashButton.tintColor = .white
        flashButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        flashButton.layer.cornerRadius = 25
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        
        // Capture button
        captureButton = UIButton(type: .custom)
        captureButton.backgroundColor = .white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.borderWidth = 4
        captureButton.layer.borderColor = UIColor.orange.cgColor
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        // Add inner circle for better visual feedback
        let innerCircle = UIView()
        innerCircle.backgroundColor = .orange
        innerCircle.layer.cornerRadius = 25
        innerCircle.isUserInteractionEnabled = false
        captureButton.addSubview(innerCircle)
        innerCircle.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerCircle.centerXAnchor.constraint(equalTo: captureButton.centerXAnchor),
            innerCircle.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            innerCircle.widthAnchor.constraint(equalToConstant: 50),
            innerCircle.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Cancel button
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cancelButton.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        cancelButton.layer.cornerRadius = 20
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        // Instructions label
        let instructionsLabel = UILabel()
        instructionsLabel.text = "Position food within the frame"
        instructionsLabel.textColor = .white
        instructionsLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        instructionsLabel.textAlignment = .center
        instructionsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        instructionsLabel.layer.cornerRadius = 15
        instructionsLabel.clipsToBounds = true
        
        // Add tap to focus gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus(_:)))
        view.addGestureRecognizer(tapGesture)
        
        // Add all UI elements
        [overlayView, flashButton, captureButton, cancelButton, instructionsLabel].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Overlay fills the screen
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Flash button (top right)
            flashButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            flashButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            flashButton.widthAnchor.constraint(equalToConstant: 50),
            flashButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Capture button (bottom center)
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            // Cancel button (top left)
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: 80),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Instructions (bottom)
            instructionsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            instructionsLabel.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -20),
            instructionsLabel.widthAnchor.constraint(equalToConstant: 280),
            instructionsLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func createScanningOverlay() -> UIView {
        let overlayView = UIView()
        overlayView.backgroundColor = .clear
        
        // This will be updated in layoutSubviews when we have proper bounds
        return overlayView
    }
    
    private func updateScanningOverlay() {
        // Remove existing overlay layers
        view.subviews.first { $0.backgroundColor == .clear }?.layer.sublayers?.removeAll()
        
        guard let overlayView = view.subviews.first(where: { $0.backgroundColor == .clear }) else { return }
        
        // Create a custom overlay with a transparent rectangle for food scanning
        let overlayLayer = CALayer()
        overlayLayer.frame = overlayView.bounds
        overlayLayer.backgroundColor = UIColor.black.withAlphaComponent(0.3).cgColor
        
        // Create scanning frame - responsive to screen size
        let margin: CGFloat = 50
        let availableWidth = view.bounds.width - (margin * 2)
        let frameSize = min(availableWidth, 280) // Max 280pts, but responsive
        let centerX = view.bounds.width / 2
        let centerY = view.bounds.height / 2
        
        let scanFrame = CGRect(
            x: centerX - frameSize/2,
            y: centerY - frameSize/2 - 50, // Slightly above center
            width: frameSize,
            height: frameSize
        )
        
        let scanPath = UIBezierPath(rect: overlayView.bounds)
        scanPath.append(UIBezierPath(rect: scanFrame).reversing())
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = scanPath.cgPath
        maskLayer.fillRule = .evenOdd
        
        overlayLayer.mask = maskLayer
        overlayView.layer.addSublayer(overlayLayer)
        
        // Remove existing corner guides
        overlayView.subviews.forEach { $0.removeFromSuperview() }
        
        // Add corner guides
        addCornerGuides(to: overlayView, frame: scanFrame)
    }
    
    private func addCornerGuides(to view: UIView, frame: CGRect) {
        let cornerLength: CGFloat = 20
        let cornerWidth: CGFloat = 3
        let orangeColor = UIColor.orange
        
        // Top-left corner
        let topLeftHorizontal = createCornerLine(frame: CGRect(x: frame.minX, y: frame.minY, width: cornerLength, height: cornerWidth), color: orangeColor)
        let topLeftVertical = createCornerLine(frame: CGRect(x: frame.minX, y: frame.minY, width: cornerWidth, height: cornerLength), color: orangeColor)
        
        // Top-right corner  
        let topRightHorizontal = createCornerLine(frame: CGRect(x: frame.maxX - cornerLength, y: frame.minY, width: cornerLength, height: cornerWidth), color: orangeColor)
        let topRightVertical = createCornerLine(frame: CGRect(x: frame.maxX - cornerWidth, y: frame.minY, width: cornerWidth, height: cornerLength), color: orangeColor)
        
        // Bottom-left corner
        let bottomLeftHorizontal = createCornerLine(frame: CGRect(x: frame.minX, y: frame.maxY - cornerWidth, width: cornerLength, height: cornerWidth), color: orangeColor)
        let bottomLeftVertical = createCornerLine(frame: CGRect(x: frame.minX, y: frame.maxY - cornerLength, width: cornerWidth, height: cornerLength), color: orangeColor)
        
        // Bottom-right corner
        let bottomRightHorizontal = createCornerLine(frame: CGRect(x: frame.maxX - cornerLength, y: frame.maxY - cornerWidth, width: cornerLength, height: cornerWidth), color: orangeColor)
        let bottomRightVertical = createCornerLine(frame: CGRect(x: frame.maxX - cornerWidth, y: frame.maxY - cornerLength, width: cornerWidth, height: cornerLength), color: orangeColor)
        
        [topLeftHorizontal, topLeftVertical, topRightHorizontal, topRightVertical,
         bottomLeftHorizontal, bottomLeftVertical, bottomRightHorizontal, bottomRightVertical].forEach {
            view.addSubview($0)
        }
    }
    
    private func createCornerLine(frame: CGRect, color: UIColor) -> UIView {
        let line = UIView(frame: frame)
        line.backgroundColor = color
        return line
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        videoPreviewLayer?.frame = view.bounds
        
        // Update scanning overlay with proper bounds
        updateScanningOverlay()
    }
    
    @objc private func toggleFlash() {
        guard let device = currentDevice, device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if isFlashOn {
                device.torchMode = .off
                flashButton.setImage(UIImage(systemName: "bolt.slash.fill"), for: .normal)
                isFlashOn = false
            } else {
                try device.setTorchModeOn(level: 1.0)
                flashButton.setImage(UIImage(systemName: "bolt.fill"), for: .normal)
                isFlashOn = true
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Flash toggle error: \(error)")
        }
    }
    
    @objc private func capturePhoto() {
        print("📸 Capture button tapped")
        
        guard let output = stillImageOutput else {
            print("❌ Still image output not available")
            return
        }
        
        guard captureSession?.isRunning == true else {
            print("❌ Capture session not running")
            return
        }
        
        // Create photo settings with proper format
        let settings: AVCapturePhotoSettings
        
        // Use HEVC if available, otherwise use default
        if output.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }
        
        // Configure flash for the photo
        if let device = currentDevice, device.hasFlash {
            settings.flashMode = isFlashOn ? .on : .auto
        }
        
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("📸 Starting photo capture...")
        output.capturePhoto(with: settings, delegate: self)
    }
    
    @objc private func handleTapToFocus(_ gesture: UITapGestureRecognizer) {
        let touchPoint = gesture.location(in: view)
        let focusPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        guard let device = currentDevice else { return }
        
        do {
            try device.lockForConfiguration()
            
            // Set focus point
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = focusPoint
                device.focusMode = .autoFocus
            }
            
            // Set exposure point
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = focusPoint
                device.exposureMode = .autoExpose
            }
            
            device.unlockForConfiguration()
            
            // Show focus indicator
            showFocusIndicator(at: touchPoint)
            
        } catch {
            print("Focus error: \(error)")
        }
    }
    
    private func showFocusIndicator(at point: CGPoint) {
        // Remove existing focus indicator
        view.subviews.filter { $0.tag == 999 }.forEach { $0.removeFromSuperview() }
        
        // Create focus indicator
        let focusIndicator = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        focusIndicator.center = point
        focusIndicator.layer.borderColor = UIColor.orange.cgColor
        focusIndicator.layer.borderWidth = 2
        focusIndicator.layer.cornerRadius = 40
        focusIndicator.backgroundColor = .clear
        focusIndicator.tag = 999
        focusIndicator.alpha = 0
        
        view.addSubview(focusIndicator)
        
        // Animate focus indicator
        UIView.animate(withDuration: 0.3, animations: {
            focusIndicator.alpha = 1
            focusIndicator.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                focusIndicator.alpha = 0
            }) { _ in
                focusIndicator.removeFromSuperview()
            }
        }
    }
    
    @objc private func cancelTapped() {
        // Turn off flash when leaving
        if isFlashOn {
            toggleFlash()
        }
        delegate?.didCancel()
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("❌ Photo capture error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Photo Capture Failed",
                    message: "Unable to capture photo. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("❌ Unable to process captured photo")
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Photo Processing Failed",
                    message: "Unable to process the captured photo. Please try again.",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
            return
        }
        
        print("✅ Photo captured successfully")
        delegate?.didCaptureImage(image)
    }
}
