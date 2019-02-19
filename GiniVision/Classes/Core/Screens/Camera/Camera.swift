//
//  Camera.swift
//  GiniVision
//
//  Created by Peter Pult on 15/02/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

protocol CameraProtocol: class {
    var session: AVCaptureSession { get }
    var videoDeviceInput: AVCaptureDeviceInput? { get }
    var didDetectQR: ((GiniQRCodeDocument) -> Void)? { get set }
    var isFlashSupported: Bool { get }
    var isFlashOn: Bool { get set }

    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void)
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool)
    func setup(completion: ((CameraError?) -> Void))
    func setupQRScanningOutput()
    func start()
    func stop()
}

final class Camera: NSObject, CameraProtocol {
    
    // Session management
    var session: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var didDetectQR: ((GiniQRCodeDocument) -> Void)?
    var giniConfiguration: GiniConfiguration
    
    lazy var isFlashSupported: Bool = {
        #if targetEnvironment(simulator)
        return true
        #else
        return videoDeviceInput?.device.hasFlash ?? false
        #endif
    }()
    var isFlashOn: Bool = true
    
    fileprivate let application: UIApplication
    fileprivate lazy var sessionQueue: DispatchQueue = DispatchQueue(label: "session queue",
                                                                     attributes: [])
    
    init(application: UIApplication = UIApplication.shared,
         giniConfiguration: GiniConfiguration) {
        self.application = application
        self.giniConfiguration = giniConfiguration
        super.init()
    }
    
    func setup(completion: ((CameraError?) -> Void)) {
        do {
            try setupSession()
            
            self.session.beginConfiguration()
            self.setupInput()
            self.setupPhotoCaptureOutput()
            self.session.commitConfiguration()
        } catch let error as CameraError {
            completion(error)
        } catch {
            completion(.unknown)
        }
    }
    
    func start() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    func stop() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    func focus(withMode mode: AVCaptureDevice.FocusMode,
               exposeWithMode exposureMode: AVCaptureDevice.ExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
            guard case .some = try? device.lockForConfiguration() else {
                Log(message: "Could not lock device for configuration", event: .error)
                return
            }
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(mode) {
                device.focusPointOfInterest = point
                device.focusMode = mode
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device.unlockForConfiguration()
        }
    }
    
    func captureStillImage(completion: @escaping (Data?, CameraError?) -> Void) {
        sessionQueue.async {
            // Connection will be `nil` when there is no valid input device; for example on iOS simulator
            guard let connection = self.stillImageOutput?.connection(with: .video) else {
                return completion(nil, .noInputDevice)
            }
            
            // Set the orientation according to the current orientation of the interface
            DispatchQueue.main.sync { [weak self] in
                guard let `self` = self else { return }
                connection.videoOrientation = AVCaptureVideoOrientation(self.application.statusBarOrientation)
            }
            
            self.videoDeviceInput?.device.setFlashModeSecurely(self.isFlashOn ? .on : .off)
            self.stillImageOutput?
                .captureStillImageAsynchronously(from: connection) { (buffer: CMSampleBuffer?, error: Error?) in
                    if let buffer = buffer, error == nil {
                        completion(AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), nil)
                    } else {
                        completion(nil, .captureFailed)
                    }
            }
        }
    }
    
    // MARK: Private methods
    
    func setupQRScanningOutput() {
        self.session.beginConfiguration()
        let qrOutput = AVCaptureMetadataOutput()
        
        if self.session.canAddOutput(qrOutput) {
            self.session.addOutput(qrOutput)
            qrOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
            
            if qrOutput.availableMetadataObjectTypes.contains(.qr) {
                qrOutput.metadataObjectTypes = [.qr]
            }
        } else {
            Log(message: "Could not add metadata output to the session", event: .error)
        }
        
        self.session.commitConfiguration()
    }
}

// MARK: - Fileprivate

fileprivate extension Camera {
    func setupSession() throws {
        var videoDevice: AVCaptureDevice? {
            let devices = AVCaptureDevice.devices(for: .video).filter {
                $0.position == .back
            }
            guard let device = devices.first else { return nil }
            return device
        }
        
        do {
            guard let videoDevice = videoDevice else { throw CameraError.unknown }
            self.videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error as NSError {
            if error.code == AVError.Code.applicationIsNotAuthorizedToUseDevice.rawValue {
                throw CameraError.notAuthorizedToUseDevice
            } else {
                throw CameraError.unknown
            }
        }
    }
    
    func setupInput() {
        // Specify that we are capturing a photo, this will reset the format to be 4:3
        self.session.sessionPreset = .photo
        if self.session.canAddInput(self.videoDeviceInput!) {
            self.session.addInput(self.videoDeviceInput!)
        } else {
            Log(message: "Could not add video device input to the session", event: .error)
        }
    }
    
    func setupPhotoCaptureOutput() {
        let output = AVCaptureStillImageOutput()
        
        if self.session.canAddOutput(output) {
            output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.session.addOutput(output)
            self.stillImageOutput = output
        } else {
            Log(message: "Could not add still image output to the session", event: .error)
        }
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension Camera: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if metadataObjects.isEmpty {
            return
        }
        
        if let metadataObj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            metadataObj.type == AVMetadataObject.ObjectType.qr {
            let qrDocument = GiniQRCodeDocument(scannedString: metadataObj.stringValue!)
            do {
                try GiniVisionDocumentValidator.validate(qrDocument, withConfig: giniConfiguration)
                DispatchQueue.main.async { [weak self] in
                    self?.didDetectQR?(qrDocument)
                }
            } catch {
                
            }
            
        }
    }
}

