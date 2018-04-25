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
    }
    
    fileprivate func addPreviewViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: previewView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Constraints.active(item: previewView, attr: .bottom, relatedBy: .equal, to: self.view, attr: .bottom)
            Constraints.active(item: previewView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
            Constraints.active(item: previewView, attr: .trailing, relatedBy: .equal, to: controlsView, attr: .leading,
                              priority: 750)
        } else {
            // lower priority constraints - will make the preview "want" to get bigger
            Constraints.active(item: previewView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Constraints.active(item: previewView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
            Constraints.active(item: previewView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        }
    }
    
    fileprivate func addControlsViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Constraints.active(item: controlsView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
            Constraints.active(item: controlsView, attr: .bottom, relatedBy: .equal, to: self.view, attr: .bottom)
            Constraints.active(item: controlsView, attr: .leading, relatedBy: .equal, to: previewView, attr: .trailing,
                              priority: 750)
        } else {
            Constraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: previewView, attr: .bottom)
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
            Constraints.active(item: capturedImagesStackView, attr: .bottom, relatedBy: .equal, to: captureButton,
                              attr: .top, constant: -60)
            Constraints.active(item: capturedImagesStackView, attr: .height, relatedBy: .greaterThanOrEqual,
                               to: nil, attr: .notAnAttribute, constant: capturedImagesStackView.thumbnailSize.height)
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
                              attr: .bottom, constant: 60)
        } else {
            Constraints.active(item: importFileButton, attr: .centerY, relatedBy: .equal, to: controlsView,
                              attr: .centerY, priority: 750)
            Constraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Constraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: captureButton,
                              attr: .leading, priority: 750)
        }
    }
}
