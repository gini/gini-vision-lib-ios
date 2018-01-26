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
        addReviewImagesButtonConstraints()
    }
    
    fileprivate func addPreviewViewConstraints() {
        if UIDevice.current.isIpad {
            Contraints.active(item: previewView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Contraints.active(item: previewView, attr: .bottom, relatedBy: .equal, to: self.view, attr: .bottom)
            Contraints.active(item: previewView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
            Contraints.active(item: previewView, attr: .trailing, relatedBy: .equal, to: controlsView, attr: .leading,
                              priority: 750)
        } else {
            // lower priority constraints - will make the preview "want" to get bigger
            Contraints.active(item: previewView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Contraints.active(item: previewView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
            Contraints.active(item: previewView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        }
    }
    
    fileprivate func addControlsViewConstraints() {
        if UIDevice.current.isIpad {
            Contraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: self.view, attr: .top)
            Contraints.active(item: controlsView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
            Contraints.active(item: controlsView, attr: .bottom, relatedBy: .equal, to: self.view, attr: .bottom)
            Contraints.active(item: controlsView, attr: .leading, relatedBy: .equal, to: previewView, attr: .trailing,
                              priority: 750)
        } else {
            Contraints.active(item: controlsView, attr: .top, relatedBy: .equal, to: previewView, attr: .bottom)
            Contraints.active(item: controlsView, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide,
                              attr: .top)
            Contraints.active(item: controlsView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
            Contraints.active(item: controlsView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
        }
    }
    
    fileprivate func addControlsViewButtonsConstraints() {
        Contraints.active(item: captureButton, attr: .width, relatedBy: .equal, to: nil, attr: .width, constant: 70)
        Contraints.active(item: captureButton, attr: .height, relatedBy: .equal, to: nil, attr: .height, constant: 70)
        
        if UIDevice.current.isIpad {
            Contraints.active(item: captureButton, attr: .centerY, relatedBy: .equal, to: controlsView, attr: .centerY)
            Contraints.active(item: captureButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing, constant: -16)
            Contraints.active(item: captureButton, attr: .leading, relatedBy: .equal, to: controlsView, attr: .leading,
                              constant: 16, priority: 750)
        } else {
            Contraints.active(item: captureButton, attr: .centerX, relatedBy: .equal, to: controlsView, attr: .centerX)
            Contraints.active(item: captureButton, attr: .top, relatedBy: .equal, to: controlsView, attr: .top,
                              constant: 16)
            Contraints.active(item: captureButton, attr: .bottom, relatedBy: .equal, to: controlsView, attr: .bottom,
                              constant: -16, priority: 750)
        }
    }
    
    fileprivate func addReviewImagesButtonConstraints() {
        if UIDevice.current.isIpad {
            Contraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Contraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Contraints.active(item: importFileButton, attr: .top, relatedBy: .equal, to: captureButton,
                              attr: .bottom, constant: 60)
        } else {
            Contraints.active(item: reviewContentView, attr: .centerY, relatedBy: .equal, to: controlsView,
                              attr: .centerY, priority: 750)
            Contraints.active(item: reviewContentView, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Contraints.active(item: reviewContentView, attr: .leading, relatedBy: .equal, to: captureButton,
                              attr: .trailing, priority: 750)
            
            Contraints.active(item: reviewImagesButton, attr: .centerY, relatedBy: .equal, to: reviewContentView,
                              attr: .centerY)
            Contraints.active(item: reviewImagesButton, attr: .centerX, relatedBy: .equal, to: reviewContentView,
                              attr: .centerX)
            Contraints.active(item: reviewImagesButton, attr: .height, relatedBy: .equal, to: nil,
                              attr: .notAnAttribute, constant: 60)
            Contraints.active(item: reviewImagesButton, attr: .width, relatedBy: .equal, to: nil,
                              attr: .notAnAttribute, constant: 40)
            
            Contraints.active(item: reviewBackgroundView, attr: .centerY, relatedBy: .equal, to: reviewImagesButton,
                              attr: .centerY, constant: 5)
            Contraints.active(item: reviewBackgroundView, attr: .centerX, relatedBy: .equal, to: reviewImagesButton,
                              attr: .centerX, constant: -5)
            Contraints.active(item: reviewBackgroundView, attr: .height, relatedBy: .equal, to: nil,
                              attr: .notAnAttribute, constant: 60)
            Contraints.active(item: reviewBackgroundView, attr: .width, relatedBy: .equal, to: nil,
                              attr: .notAnAttribute, constant: 40)
        }
    }
    
    func addImportButtonConstraints() {
        if UIDevice.current.isIpad {
            Contraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: controlsView,
                              attr: .trailing)
            Contraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Contraints.active(item: importFileButton, attr: .top, relatedBy: .equal, to: captureButton,
                              attr: .bottom, constant: 60)
        } else {
            Contraints.active(item: importFileButton, attr: .centerY, relatedBy: .equal, to: controlsView,
                              attr: .centerY, priority: 750)
            Contraints.active(item: importFileButton, attr: .leading, relatedBy: .equal, to: controlsView,
                              attr: .leading)
            Contraints.active(item: importFileButton, attr: .trailing, relatedBy: .equal, to: captureButton,
                              attr: .leading, priority: 750)
        }
    }
}
