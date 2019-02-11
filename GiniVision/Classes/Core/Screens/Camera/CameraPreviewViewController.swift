//
//  CameraPreviewViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 8/10/18.
//

import UIKit
import AVFoundation

protocol CameraPreviewViewControllerDelegate: class {
    func cameraPreview(viewController: CameraPreviewViewController,
                       didDetect qrCodeDocument: GiniQRCodeDocument)
}

final class CameraPreviewViewController: UIViewController {
    
    weak var delegate: CameraPreviewViewControllerDelegate?
    
    var documentDetector: DocumentDetectorProtocol?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate typealias FocusIndicator = UIImageView
    fileprivate var camera: Camera?
    fileprivate var cameraState = CameraState.notValid
    fileprivate var documentDetectedInfo: DetectedDocumentInfo?
    fileprivate var defaultImageView: UIImageView?
    fileprivate var focusIndicatorImageView: UIImageView?
    fileprivate let interfaceOrientationsMapping: [UIInterfaceOrientation: AVCaptureVideoOrientation] = [
        .portrait: .portrait,
        .landscapeRight: .landscapeRight,
        .landscapeLeft: .landscapeLeft,
        .portraitUpsideDown: .portraitUpsideDown
    ]
    
    fileprivate var cameraFocusSmall: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusSmall")
    }
    
    fileprivate var cameraFocusLarge: UIImage? {
        return UIImageNamedPreferred(named: "cameraFocusLarge")
    }
    
    fileprivate var defaultImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraDefaultDocumentImage")
    }
    
    fileprivate enum CameraState {
        case valid, notValid
    }

    lazy var previewView: CameraPreviewView = {
        let previewView = CameraPreviewView()
        previewView.translatesAutoresizingMaskIntoConstraints = false
        (previewView.layer as? AVCaptureVideoPreviewLayer)?.videoGravity = .resize
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(focusAndExposeTap))
        previewView.addGestureRecognizer(tapGesture)
        return previewView
    }()
    
    init(giniConfiguration: GiniConfiguration = .shared) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
        
        setupCamera(giniConfiguration: giniConfiguration)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func loadView() {
        super.loadView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let validCamera = camera {
            cameraState = .valid
            previewView.session = validCamera.session
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(subjectAreaDidChange),
                                                   name: NSNotification.Name.AVCaptureDeviceSubjectAreaDidChange,
                                                   object: camera?.videoDeviceInput?.device)
        }
        previewView.drawGuides(withColor: giniConfiguration.cameraPreviewCornerGuidesColor)
        
        view.insertSubview(previewView, at: 0)
        Constraints.pin(view: previewView, toSuperView: view)

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updatePreviewViewOrientation() // Video orientation should be updated once the view has been loaded
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        camera?.start()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera?.stop()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            self.updatePreviewViewOrientation()
        })
    }
    
    fileprivate func updatePreviewViewOrientation() {
        let orientation: AVCaptureVideoOrientation
        if UIDevice.current.isIpad {
            orientation =  interfaceOrientationsMapping[UIApplication.shared.statusBarOrientation] ?? .portrait
        } else {
            orientation = .portrait
        }
        
        let previewLayer = (self.previewView.layer as? AVCaptureVideoPreviewLayer)
        previewLayer?.connection?.videoOrientation = orientation
    }
    
    fileprivate func setupCamera(giniConfiguration: GiniConfiguration) {
        camera = Camera(giniConfiguration: giniConfiguration) { error in
            if let error = error {
                switch error {
                case .notAuthorizedToUseDevice:
                    addNotAuthorizedView()
                default:
                    if GiniConfiguration.DEBUG {
                        cameraState = .valid
                        #if targetEnvironment(simulator)
                        addDefaultImage()
                        #endif
                    }
                }
            }
        }
        
        if giniConfiguration.qrCodeScanningEnabled {
            camera?.setupQRScanningOutput()
            camera?.didDetectQR = { [weak self] qrDocument in
                guard let `self` = self else { return }
                self.delegate?.cameraPreview(viewController: self, didDetect: qrDocument)
            }
        }
        
        if #available(iOS 11.0, *) {
            documentDetector = DocumentDetector()
            documentDetector?.delegate = self
            
            camera?.setupVideoOutput()
            camera?.didCaptureImageBuffer = documentDetector?.detectDocument
        }
        
    }
    
    func captureImage(completion: @escaping (Data?, CameraError?) -> Void) {
        guard let camera = camera else {
            Log(message: "No camera initialized", event: .warning)
            return
        }
        
        if GiniConfiguration.DEBUG {
            // Retrieves the image from default image view to make sure the image
            // was set and therefore the correct states were checked before.
            #if targetEnvironment(simulator)
            if let image = self.defaultImageView?.image,
                let imageData = image.jpegData(compressionQuality: 0.2) {
                completion(imageData, nil)
            }
            #endif
        }
        
        camera.captureStillImage(completion: { data, error in
            if let polyRect = self.documentDetectedInfo?.polyRect,
                let data = data,
                let image = UIImage(data: data)?.withFixedOrientation(),
                let rotatedAndCropped = image.orientedAndCropped(polyRect: polyRect),
                let croppedData = rotatedAndCropped.jpegData(compressionQuality: 0.9) {
                completion(croppedData, error)
            } else {
                completion(data, error)
            }
        })
    }
    
    func showCameraOverlay() {
        guard cameraState == .valid else { return }
        previewView.guidesLayer?.isHidden = false
        previewView.frameLayer?.isHidden = false
    }
    
    func hideCameraOverlay() {
        previewView.guidesLayer?.isHidden = true
        previewView.frameLayer?.isHidden = true
    }
    
}

// MARK: - Default and not authorized views

extension CameraPreviewViewController {
    fileprivate func addNotAuthorizedView() {
        
        // Add not authorized view
        let view = CameraNotAuthorizedView()
        super.view.addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: view, attr: .width, relatedBy: .equal, to: super.view, attr: .width)
        Constraints.active(item: view, attr: .height, relatedBy: .equal, to: super.view, attr: .height)
        Constraints.active(item: view, attr: .centerX, relatedBy: .equal, to: super.view, attr: .centerX)
        Constraints.active(item: view, attr: .centerY, relatedBy: .equal, to: super.view, attr: .centerY)
        
        // Hide camera UI
        hideCameraOverlay()
    }
    
    /// Adds a default image to the canvas when no camera is available (DEBUG mode only)
    fileprivate func addDefaultImage() {
        defaultImageView = UIImageView(image: defaultImage)
        guard let defaultImageView = defaultImageView else { return }
        
        defaultImageView.contentMode = .scaleAspectFit
        previewView.addSubview(defaultImageView)
        
        defaultImageView.translatesAutoresizingMaskIntoConstraints = false
        Constraints.active(item: defaultImageView, attr: .width, relatedBy: .equal, to: previewView, attr: .width)
        Constraints.active(item: defaultImageView, attr: .height, relatedBy: .equal, to: previewView, attr: .height)
        Constraints.active(item: defaultImageView, attr: .centerX, relatedBy: .equal, to: previewView, attr: .centerX)
        Constraints.active(item: defaultImageView, attr: .centerY, relatedBy: .equal, to: previewView, attr: .centerY)
    }
}

// MARK: - Focus handling

extension CameraPreviewViewController {
    
    @objc fileprivate func focusAndExposeTap(_ sender: UITapGestureRecognizer) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: sender.location(in: sender.view))
        camera?.focus(withMode: .autoFocus,
                      exposeWithMode: .autoExpose,
                      atDevicePoint: devicePoint,
                      monitorSubjectAreaChange: true)
        let imageView =
            createFocusIndicator(withImage: cameraFocusSmall,
                                 atPoint: previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint))
        showFocusIndicator(imageView)
    }
    
    fileprivate func createFocusIndicator(withImage image: UIImage?, atPoint point: CGPoint) -> FocusIndicator? {
        guard let image = image else { return nil }
        let imageView = UIImageView(image: image)
        imageView.center = point
        return imageView
    }
    
    fileprivate func showFocusIndicator(_ imageView: FocusIndicator?) {
        guard cameraState == .valid else { return }
        guard let imageView = imageView else { return }
        for subView in self.previewView.subviews {
            if let focusIndicator = subView as? FocusIndicator {
                focusIndicator.removeFromSuperview()
            }
        }
        self.previewView.addSubview(imageView)
        UIView.animate(withDuration: 1.5,
                       animations: {
                        imageView.alpha = 0.0
        },
                       completion: { _ in
                        imageView.removeFromSuperview()
        })
    }
    
    @objc fileprivate func subjectAreaDidChange(_ notification: Notification) {
        guard let previewLayer = previewView.layer as? AVCaptureVideoPreviewLayer else { return }
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        
        camera?.focus(withMode: .continuousAutoFocus,
                      exposeWithMode: .continuousAutoExposure,
                      atDevicePoint: devicePoint,
                      monitorSubjectAreaChange: false)
        
        let imageView =
            createFocusIndicator(withImage: cameraFocusLarge,
                                 atPoint: previewLayer.layerPointConverted(fromCaptureDevicePoint: devicePoint))
        showFocusIndicator(imageView)
    }
    
}

@available(iOS 11.0, *)
extension CameraPreviewViewController: DocumentDetectorDelegate {
    func documentDetector(_ documentDetector: DocumentDetector, didDetect documentsInfo: [DetectedDocumentInfo]) {
        self.previewView.subviews.forEach { if $0 is RectangleView { $0.removeFromSuperview() } }
        self.documentDetectedInfo = nil
        
        if let documentInfo = documentsInfo.first {
            self.drawRectangle(polyRect: documentInfo.polyRect)
            self.documentDetectedInfo = documentInfo
        }
    }
    
    private func drawRectangle(polyRect: PolyRect) {
        let xCoord = polyRect.minX * previewView.frame.size.width
        let yCoord = polyRect.minY * previewView.frame.size.height
        let width = polyRect.width * previewView.frame.size.width + 4
        let height = polyRect.height * previewView.frame.size.height + 4

        let rectangleView = RectangleView(polyRect: polyRect, refRect: previewView.frame)

        rectangleView.frame = CGRect(x: xCoord.rounded(),
                                     y: yCoord.rounded(),
                                     width: width.rounded(),
                                     height: height.rounded())

        let newRatio = width / height
        let threshold = newRatio * 0.25
        if (newRatio < self.previewView.ratio - threshold) ||  (newRatio > self.previewView.ratio + threshold) {
            self.previewView.ratio = width / height
            self.previewView.layoutIfNeeded()
        }

        previewView.addSubview(rectangleView)
        rectangleView.setNeedsDisplay()
    }
    
//    func drawWordBox(box: VNTextObservation) {
//        guard let boxes = box.characterBoxes else {return}
//        var xMin: CGFloat = 9999.0
//        var xMax: CGFloat = 0.0
//        var yMin: CGFloat = 9999.0
//        var yMax: CGFloat = 0.0
//        
//        for char in boxes {
//            if char.bottomLeft.x < xMin {xMin = char.bottomLeft.x}
//            if char.bottomRight.x > xMax {xMax = char.bottomRight.x}
//            if char.bottomRight.y < yMin {yMin = char.bottomRight.y}
//            if char.topRight.y > yMax {yMax = char.topRight.y}
//        }
//        
//        let xCoord = xMin * previewView.frame.size.width
//        let yCoord = (1 - yMax) * previewView.frame.size.height
//        let width = (xMax - xMin) * previewView.frame.size.width
//        let height = (yMax - yMin) * previewView.frame.size.height
//        
//        let layer = TextLayer()
//        layer.frame = CGRect(x: xCoord, y: yCoord, width: width, height: height)
//        layer.borderWidth = 2.0
//        layer.borderColor = UIColor.green.cgColor
//        
//        previewView.layer.addSublayer(layer)
//    }
}
