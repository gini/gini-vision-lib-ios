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

internal class Camera {
    
    // Session management
    var session: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    fileprivate lazy var sessionQueue:DispatchQueue = DispatchQueue(label: "session queue", attributes: [])
    
    fileprivate lazy var motionManager = MotionManager()
    
    init() throws {
        try setupSession()
    }
    
    // MARK: Public methods
    func start() {
        sessionQueue.async {
            self.session.startRunning()
            self.motionManager.startDetection()
        }
    }
    
    func stop() {
        sessionQueue.async {
            self.session.stopRunning()
            self.motionManager.stopDetection()
        }
    }
    
    func focusWithMode(_ focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            guard let device = self.videoDeviceInput?.device else { return }
            guard case .some = try? device.lockForConfiguration() else { return print("Could not lock device for configuration") }
            
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = point
                device.focusMode = focusMode
            }
            
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }
            
            device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device.unlockForConfiguration()
        }
    }
    
    func captureStillImage(_ completion: @escaping (_ inner: () throws -> Data) -> ()) {
        sessionQueue.async {
            // Connection will be `nil` when there is no valid input device; for example on iOS simulator
            guard let connection = self.stillImageOutput?.connection(withMediaType: AVMediaTypeVideo) else {
                return completion({ _ in throw CameraError.noInputDevice })
            }
            
            // Set the orientation according to the current orientation of the interface
            connection.videoOrientation = AVCaptureVideoOrientation(UIApplication.shared.statusBarOrientation)
            
            self.videoDeviceInput?.device.setFlashModeSecurely(.on)
            self.stillImageOutput?.captureStillImageAsynchronously(from: connection) { (imageDataSampleBuffer: CMSampleBuffer?, error: Error?) -> Void in
                guard error == nil else { return completion({ _ in throw CameraError.captureFailed }) }
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                completion({ _ in
                    guard let data = imageData else {
                        throw CameraError.captureFailed
                    }
                    return data
                })
            }
        }
    }
    
    class func saveImageFromData(_ data: Data) {
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            guard status == .authorized else { return print("No access to photo library granted") }
            
            // Check for iOS to make sure `PHAssetCreationRequest` class is available
            if #available(iOS 9.0, *) {
                PHPhotoLibrary.shared().performChanges({
                    PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
                },
                                                       completionHandler: { (success: Bool, error: Error?) -> Void in
                                                        guard success else { return print("Could not save image to photo library") }
                })
            } else {
                // TODO: Add option for older iOS
            }
        })
    }
    
    // MARK: Private methods
    fileprivate func setupSession() throws {
        // Setup is not performed asynchronously because of KVOs
        func deviceWithMediaType(_ mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
            let devices = AVCaptureDevice.devices(withMediaType: mediaType).filter { ($0 as? AVCaptureDevice)?.position == position }
            guard let device = devices.first as? AVCaptureDevice else { return nil }
            return device
        }
        
        let videoDevice = deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
        do {
            self.videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error as NSError {
            print("Could not create video device input \(error)")
            if error.code == AVError.Code.applicationIsNotAuthorizedToUseDevice.rawValue {
                throw CameraError.notAuthorizedToUseDevice
            } else {
                throw CameraError.unknown
            }
        }
        
        self.session.beginConfiguration()
        // Specify that we are capturing a photo, this will reset the format to be 4:3
        self.session.sessionPreset = AVCaptureSessionPresetPhoto
        if self.session.canAddInput(self.videoDeviceInput) {
            self.session.addInput(self.videoDeviceInput)
        } else {
            print("Could not add video device input to the session")
        }
        
        let output = AVCaptureStillImageOutput()
        if self.session.canAddOutput(output) {
            output.outputSettings = [ AVVideoCodecKey: AVVideoCodecJPEG ];
            self.session.addOutput(output)
            self.stillImageOutput = output
        } else {
            print("Could not add still image output to the session")
        }
        
        self.session.commitConfiguration()
    }
}
