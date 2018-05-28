//
//  UIViewController.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 5/8/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import UIKit
import GiniVision

extension UIViewController {
    func showErrorDialog(for error: Error, positiveAction: (() -> Void)?) {
        let message: String
        var cancelActionTitle: String = NSLocalizedString("ginivision.camera.errorPopup.cancelButton",
                                                          bundle: Bundle(for: GiniVision.self),
                                                          comment: "cancel button title")
        var confirmActionTitle: String? = NSLocalizedString("ginivision.camera.errorPopup.pickanotherfileButton",
                                                            bundle: Bundle(for: GiniVision.self),
                                                            comment: "pick another file button title")
        
        switch error {
        case let validationError as DocumentValidationError:
            message = validationError.message
        case let customValidationError as CustomDocumentValidationError:
            message = customValidationError.message
        case let pickerError as FilePickerError:
            message = pickerError.message
            switch pickerError {
            case .maxFilesPickedCountExceeded:
                confirmActionTitle = NSLocalizedString("ginivision.camera.errorPopup.reviewPages",
                                                       bundle: Bundle(for: GiniVision.self),
                                                       comment: "review pages button title")
            case .photoLibraryAccessDenied:
                cancelActionTitle = NSLocalizedString("ginivision.camera.filepicker.errorPopup.cancelButton",
                                                      bundle: Bundle(for: GiniVision.self),
                                                      comment: "cancel button title")
                confirmActionTitle = NSLocalizedString("ginivision.camera.filepicker.errorPopup.grantAccessButton",
                                                       bundle: Bundle(for: GiniVision.self),
                                                       comment: "cancel button title")
            case .mixedDocumentsUnsupported:
                cancelActionTitle = NSLocalizedString("ginivision.camera.mixedarrayspopup.cancel",
                                                      bundle: Bundle(for: GiniVision.self),
                                                      comment: "cancel button text for popup")
                confirmActionTitle = NSLocalizedString("ginivision.camera.mixedarrayspopup.usePhotos",
                                                       bundle: Bundle(for: GiniVision.self),
                                                       comment: "use photos button text in popup")
            }
        case let visionError as CustomAnalysisError:
            message = visionError.message
            confirmActionTitle = NSLocalizedString("ginivision.analysis.error.actionTitle",
                                                   bundle: Bundle(for: GiniVision.self),
                                                   comment: "Retry analysis")
        default:
            message = DocumentValidationError.unknown.message
        }
        
        let dialog = errorDialog(withMessage: message,
                                 cancelActionTitle: cancelActionTitle,
                                 confirmActionTitle: confirmActionTitle,
                                 confirmAction: positiveAction)
        
        present(dialog, animated: true, completion: nil)
    }
    
    fileprivate func errorDialog(withMessage message: String,
                                 title: String? = nil,
                                 cancelActionTitle: String,
                                 confirmActionTitle: String? = nil,
                                 confirmAction: (() -> Void)? = nil) -> UIAlertController {
        
        let alertViewController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: cancelActionTitle,
                                                    style: .cancel,
                                                    handler: { _ in
                                                        alertViewController.dismiss(animated: true, completion: nil)
        }))
        
        if let confirmActionTitle = confirmActionTitle, let confirmAction = confirmAction {
            alertViewController.addAction(UIAlertAction(title: confirmActionTitle,
                                                        style: .default,
                                                        handler: { _ in
                                                            confirmAction()
            }))
        }
        
        return alertViewController
    }
}
