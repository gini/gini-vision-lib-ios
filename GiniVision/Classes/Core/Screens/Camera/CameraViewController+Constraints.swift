//
//  CameraViewController+Constraints.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 1/26/18.
//

import Foundation

extension CameraViewController {
    func addConstraints() {
        addPreviewViewConstraints()
        addControlsViewConstraints()
        addControlsViewButtonsConstraints()
        addStackViewConstraints()
        
        if true {
            addFlashButtonConstraints()
        }
        
    }
    
    fileprivate func addPreviewViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: cameraPreviewViewController.view, attr: .top, relatedBy: .equal,
                               to: self.view, attr: .top)
            Constraints.active(item: cameraPreviewViewController.view, attr: .bottom, relatedBy: .equal,
                               to: self.view, attr: .bottom)
            Constraints.active(item: cameraPreviewViewController.view, attr: .leading, relatedBy: .equal,
                               to: self.view, attr: .leading)
            Constraints.active(item: cameraPreviewViewController.view, attr: .trailing, relatedBy: .equal,
                               to: controlsView, attr: .leading,
                               priority: 750)
        } else {
            // lower priority constraints - will make the preview "want" to get bigger
            Constraints.active(item: cameraPreviewViewController.view, attr: .top, relatedBy: .equal,
                               to: self.view, attr: .top)
            Constraints.active(item: cameraPreviewViewController.view, attr: .leading, relatedBy: .equal,
                               to: self.view, attr: .leading)
            Constraints.active(item: cameraPreviewViewController.view, attr: .trailing, relatedBy: .equal,
                               to: self.view, attr: .trailing)
        }
    }
    
    fileprivate func addControlsViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Constraints.active(item: controlsView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
            Constraints.active(item: controlsView, attr: .bottom, relatedBy: .equal, to: self.view, attr: .bottom)
            Constraints.active(item: controlsView, attr: .leading, relatedBy: .equal,
                               to: cameraPreviewViewController.view, attr: .trailing, priority: 750)
        } else {
            Constraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: cameraPreviewViewController.view,
                               attr: .bottom)
            Constraints.active(item: controlsView, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide,
                               attr: .top)
            Constraints.active(item: controlsView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
            Constraints.active(item: controlsView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        }
    }
    
    fileprivate func addControlsViewButtonsConstraints() {
        Constraints.active(item: captureButton, attr: .width, relatedBy: .equal, to: nil, attr: .width, constant: 70)
        Constraints.active(item: captureButton, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 70)
        
        if UIDevice.current.isIpad {
            Constraints.active(item: captureButton, attr: .centerY, relatedBy: .equal, to: controlsView, attr: .centerY)
            Constraints.active(item: captureButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                               attr: .trailing, constant: -16)
            Constraints.active(item: captureButton, attr: .leading, relatedBy: .equal, to: controlsView, attr: .leading,
                               constant: 16, priority: 750)
        } else {
            Constraints.active(item: captureButton, attr: .centerX, relatedBy: .equal, to: controlsView, attr: .centerX)
            Constraints.active(item: captureButton, attr: .top, relatedBy: .equal, to: controlsView, attr: .top,
                               constant: 16)
            Constraints.active(item: captureButton, attr: .bottom, relatedBy: .equal, to: controlsView, attr: .bottom,
                               constant: -16)
        }
    }
    
    fileprivate func addStackViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: rightStackView, attr: .trailing, relatedBy: .equal, to: controlsView,
                               attr: .trailing)
            Constraints.active(item: rightStackView, attr: .leading, relatedBy: .equal, to: controlsView,
                               attr: .leading)
            Constraints.active(item: rightStackView, attr: .top, relatedBy: .equal,
                               to: controlsView, attr: .top)
            Constraints.active(item: rightStackView, attr: .bottom, relatedBy: .equal, to: captureButton,
                               attr: .top, constant: -50)
            
            Constraints.active(item: leftStackView, attr: .trailing, relatedBy: .equal, to: controlsView,
                               attr: .trailing)
            Constraints.active(item: leftStackView, attr: .leading, relatedBy: .equal, to: controlsView,
                               attr: .leading)
            Constraints.active(item: leftStackView, attr: .bottom, relatedBy: .equal,
                               to: controlsView, attr: .bottom)
            Constraints.active(item: leftStackView, attr: .top, relatedBy: .equal, to: captureButton,
                               attr: .bottom, constant: 50)
        } else {
            Constraints.active(item: rightStackView, attr: .trailing, relatedBy: .equal, to: controlsView,
                               attr: .trailing)
            Constraints.active(item: rightStackView, attr: .top, relatedBy: .equal, to: controlsView,
                               attr: .top)
            Constraints.active(item: rightStackView, attr: .bottom, relatedBy: .equal, to: controlsView,
                               attr: .bottom)
            Constraints.active(item: rightStackView, attr: .leading, relatedBy: .equal, to: captureButton,
                               attr: .trailing, priority: 750)
            
            Constraints.active(item: leftStackView, attr: .leading, relatedBy: .equal, to: controlsView,
                               attr: .leading)
            Constraints.active(item: leftStackView, attr: .top, relatedBy: .equal, to: controlsView,
                               attr: .top)
            Constraints.active(item: leftStackView, attr: .bottom, relatedBy: .equal, to: controlsView,
                               attr: .bottom)
            Constraints.active(item: leftStackView, attr: .trailing, relatedBy: .equal, to: captureButton,
                               attr: .leading, priority: 750)
        }
    }
    
    func addImportButtonConstraints() {
        if UIDevice.current.isIpad {
        } else {
            Constraints.active(item: fileImportButtonView, attr: .height, relatedBy: .equal, to: leftStackView,
                               attr: .height)
        }
    }
    
    fileprivate func addFlashButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: 50)
        } else {
            let height: CGFloat = 60
            let width: CGFloat = height * 11 / 17
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: height)
            Constraints.active(item: flashToggleButton, attr: .width, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: width)
        }
        
    }
}
