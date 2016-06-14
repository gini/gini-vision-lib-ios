//
//  GINICamera.swift
//  Gini Pay 2.0
//
//  Created by Peter Pult on 15/02/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

extension AVCaptureVideoOrientation {
    
    public init(_ interface: UIInterfaceOrientation) {
        switch interface {
        case .PortraitUpsideDown: self = .PortraitUpsideDown
        case .LandscapeLeft: self = .LandscapeLeft
        case .LandscapeRight: self = .LandscapeRight
        default: self = .Portrait
        }
    }
    
    public init?(_ device: UIDeviceOrientation?) {
        guard let orientation = device else { return nil }
        switch orientation {
        case .Portrait: self = .Portrait
        case .PortraitUpsideDown: self = .PortraitUpsideDown
        case .LandscapeLeft: self = .LandscapeRight
        case .LandscapeRight: self = .LandscapeLeft
        default: return nil
        }
    }
    
}

extension AVCaptureDevice {
    
    func setFlashModeSecurely(mode: AVCaptureFlashMode) {
        guard hasFlash && isFlashModeSupported(mode) else { return }
        guard case .Some = try? lockForConfiguration() else { return print("Could not lock device for configuration") }
        flashMode = mode
        unlockForConfiguration()
    }
    
}

class GINICamera {
    
    // Session management
    var session: AVCaptureSession = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput?
    var stillImageOutput: AVCaptureStillImageOutput?
    var hasValidInput = true
    private lazy var sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    
    private lazy var motionManager = GINIMotionManager()
    
    init() {
        setupSession()
    }
    
    // MARK: Public methods
    func start() {
        dispatch_async(sessionQueue, {
            self.session.startRunning()
            self.motionManager.startDetection()
        })
    }
    
    func stop() {
        dispatch_async(sessionQueue, {
            self.session.stopRunning()
            self.motionManager.stopDetection()
        })
    }
    
    func focusWithMode(focusMode: AVCaptureFocusMode, exposeWithMode exposureMode: AVCaptureExposureMode, atDevicePoint point: CGPoint, monitorSubjectAreaChange: Bool) {
        dispatch_async(sessionQueue, {
            guard let device = self.videoDeviceInput?.device else { return }
            guard case .Some = try? device.lockForConfiguration() else { return print("Could not lock device for configuration") }
            
            if device.focusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = point
                device.focusMode = focusMode
            }
            
            if device.exposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = point
                device.exposureMode = exposureMode
            }
            
            device.subjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
            device.unlockForConfiguration()
        })
    }
    
    func captureStillImage(result: (imageData: NSData?) -> ()) {
        dispatch_async(sessionQueue, {
            // Connection will be `nil` when there is no valid input device; for example on iOS simulator
            guard let connection = self.stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) else {
                return result(imageData: nil)
            }
            // Set the orientation accoding to the current orientation of the device
            if let orientation = AVCaptureVideoOrientation(self.motionManager.currentOrientation) {
                connection.videoOrientation = orientation
            } else {
                connection.videoOrientation = .Portrait
            }
            self.videoDeviceInput?.device.setFlashModeSecurely(.On)
            self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(connection, completionHandler: { (imageDataSampleBuffer: CMSampleBuffer!, error: NSError!) -> Void in
                guard error == nil else { return }
                var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
//#if DEBUG
                GINICamera.saveImageFromData(imageData)
//#endif
                result(imageData: imageData)
            })
        })
    }
    
//#if DEBUG
    class func saveImageFromData(data: NSData) {
        PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
            guard status == .Authorized else { return print("No access to photo library granted") }
            
            // Check for iOS to make sure `PHAssetCreationRequest` class is available
            if #available(iOS 9.0, *) {
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    PHAssetCreationRequest.creationRequestForAsset().addResourceWithType(.Photo, data: data, options: nil)
                    },
                    completionHandler: { (success: Bool, error: NSError?) -> Void in
                        guard success else { return print("Could not save image to photo library") }
                })
            } else {
                // TODO: Add option for older iOS
            }
        })
    }
//#endif
    
    // MARK: Private methods
    private func setupSession() {
        // Setup is not performed asynchronously because of KVOs
        func deviceWithMediaType(mediaType: String, preferringPosition position: AVCaptureDevicePosition) -> AVCaptureDevice? {
            let devices = AVCaptureDevice.devicesWithMediaType(mediaType).filter { $0.position == position }
            guard let device = devices.first as? AVCaptureDevice else { return nil }
            return device
        }
        
        let videoDevice = deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .Back)
        do {
            self.videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
        } catch let error as NSError {
            hasValidInput = false
            print("Could not create video device input \(error)")
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