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

internal class Camera: NSObject {
    
    // Session management
    var session: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var didDetectQR: ((GiniVisionDocument) -> Void)?
    fileprivate lazy var sessionQueue: DispatchQueue = DispatchQueue(label: "session queue",
                                                                     attributes: [])
    fileprivate let application: UIApplication
    
    init(application: UIApplication = UIApplication.shared, completion: ((CameraError?) -> Void)) {
        self.application = application
        super.init()
        do {
            try setupSession()
            
            self.session.beginConfiguration()
            self.setupInput()
            self.setupPhotoCaptureOutput()
            self.setupQRScanningOutput()
            self.session.commitConfiguration()
        } catch let error as CameraError {
            completion(error)
        } catch {
            completion(.unknown)
        }
    }
    
    // MARK: Public methods
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
    
    func focus(withMode mode: AVCaptureFocusMode,
               exposeWithMode exposureMode: AVCaptureExposureMode,
               atDevicePoint point: CGPoint,
               monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
            guard case .some = try? device.lockForConfiguration() else {
                return print("Could not lock device for configuration")
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
            guard let connection = self.stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) else {
                return completion(nil, .noInputDevice)
            }
            
            // Set the orientation according to the current orientation of the interface
            DispatchQueue.main.sync { [weak self] in
                guard let `self` = self else { return }
                connection.videoOrientation = AVCaptureVideoOrientation(self.application.statusBarOrientation)
            }
            
            self.videoDeviceInput?.device.setFlashModeSecurely(.on)
            self.stillImageOutput?
                .captureStillImageAsynchronously(from: connection) { (buffer: CMSampleBuffer?, error: Error?) in
                    guard error != nil else {
                        completion(AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer), nil)
                        return
                    }
                    completion(nil, .captureFailed)
            }
        }
    }
    
    // MARK: Private methods
    fileprivate func setupSession() throws {
        var videoDevice: AVCaptureDevice? {
            let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).filter {
                ($0 as? AVCaptureDevice)?.position == .back
            }
            guard let device = devices.first as? AVCaptureDevice else { return nil }
            return device
        }
        
        do {
            self.videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error as NSError {
            if error.code == AVError.Code.applicationIsNotAuthorizedToUseDevice.rawValue {
                throw CameraError.notAuthorizedToUseDevice
            } else {
                throw CameraError.unknown
            }
        }
    }
    
    fileprivate func setupInput() {
        // Specify that we are capturing a photo, this will reset the format to be 4:3
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        if self.session.canAddInput(self.videoDeviceInput) {
            self.session.addInput(self.videoDeviceInput)
        } else {
            print("Could not add video device input to the session")
        }
    }
    
    fileprivate func setupPhotoCaptureOutput() {
        let output = AVCaptureStillImageOutput()
        
        if self.session.canAddOutput(output) {
            output.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            self.session.addOutput(output)
            self.stillImageOutput = output
        } else {
            print("Could not add still image output to the session")
        }
    }
    
    fileprivate func setupQRScanningOutput() {
        let qrOutput = AVCaptureMetadataOutput()
        
        if self.session.canAddOutput(qrOutput) {
            self.session.addOutput(qrOutput)
            
            qrOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
            qrOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            print("Could not add metadata output to the session")
        }
    }
}

// MARK: AVCaptureMetadataOutputObjectsDelegate

extension Camera: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ output: AVCaptureOutput!,
                       didOutputMetadataObjects metadataObjects: [Any]!,
                       from connection: AVCaptureConnection!) {
        if metadataObjects.isEmpty {
            return
        }
        
        if let metadataObj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject,
            metadataObj.type == AVMetadataObjectTypeQRCode {
            // Create Gini Document
            print(metadataObj.stringValue)
        }
    }
}
