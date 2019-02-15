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
        
        if giniConfiguration.multipageEnabled {
            addMultipageReviewImagesButtonConstraints()
        }
        
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
                              constant: -16, priority: 750)
        }
    }
    
    fileprivate func addMultipageReviewImagesButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: capturedImagesStackView, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Constraints.active(item: capturedImagesStackView, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Constraints.active(item: capturedImagesStackView, attr: .top, relatedBy: .greaterThanOrEqual,
                               to: controlsView, attr: .top)
            
            let viewBelow: UIView
            var distance: CGFloat = -50
            if controlsView.subviews.contains(flashToggleButton) {
                viewBelow = flashToggleButton
                distance += flashToggleButton.imageEdgeInsets.top
            } else {
                viewBelow = captureButton
            }
            
            Constraints.active(item: capturedImagesStackView, attr: .bottom, relatedBy: .equal, to: viewBelow,
                               attr: .top, constant: distance)
        } else {
            Constraints.active(item: capturedImagesStackView, attr: .centerY, relatedBy: .equal, to: controlsView,
                              attr: .centerY, priority: 750)
            Constraints.active(item: capturedImagesStackView, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Constraints.active(item: capturedImagesStackView, attr: .top, relatedBy: .equal, to: controlsView,
                              attr: .top)
            Constraints.active(item: capturedImagesStackView, attr: .bottom, relatedBy: .equal, to: controlsView,
                              attr: .bottom)
            Constraints.active(item: capturedImagesStackView, attr: .leading, relatedBy: .equal, to: captureButton,
                              attr: .trailing, priority: 750)
        }
    }
    
    func addImportButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Constraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Constraints.active(item: importFileButton, attr: .top, relatedBy: .equal, to: captureButton,
                              attr: .bottom, constant: 50)
            Constraints.active(item: importFileSubtitleLabel, attr: .top, relatedBy: .equal, to: importFileButton,
                               attr: .bottom, constant: 6)
        } else {
            Constraints.active(item: importFileButton, attr: .centerY, relatedBy: .equal, to: controlsView,
                              attr: .centerY, priority: 750)
            Constraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Constraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: captureButton,
                              attr: .leading, priority: 750)
            Constraints.active(item: importFileSubtitleLabel, attr: .bottom, relatedBy: .equal, to: controlsView,
                               attr: .bottom, constant: -10)
            Constraints.active(item: importFileSubtitleLabel, attr: .top, relatedBy: .greaterThanOrEqual,
                               to: importFileButton, attr: .bottom)
        }
        
        Constraints.active(item: importFileSubtitleLabel, attr: .centerX, relatedBy: .equal, to: importFileButton,
                           attr: .centerX)
    }
    
    fileprivate func addFlashButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: flashToggleButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                               attr: .trailing)
            Constraints.active(item: flashToggleButton, attr: .leading, relatedBy: .equal, to: controlsView,
                               attr: .leading)
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: 50)
            Constraints.active(item: flashToggleButton, attr: .bottom, relatedBy: .equal, to: captureButton,
                               attr: .top, constant: -50 + flashToggleButton.imageEdgeInsets.bottom)
            
            if !controlsView.subviews.contains(capturedImagesStackView) {
                Constraints.active(item: capturedImagesStackView, attr: .top, relatedBy: .greaterThanOrEqual,
                                   to: controlsView, attr: .top)
            }
        } else {
            Constraints.active(item: flashToggleButton, attr: .trailing, relatedBy: .equal, to: view, attr: .trailing)
            Constraints.active(item: flashToggleButton, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: 40)
        }

    }
}
