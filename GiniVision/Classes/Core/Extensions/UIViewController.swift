//
//  UIViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/20/18.
//

import Foundation

extension UIViewController {
    
    enum NavBarItemPosition {
        case left, right
    }
    
    func setupNavigationItem(usingResources preferredResources: PreferredButtonResource,
                             selector: Selector,
                             position: NavBarItemPosition,
                             target: AnyObject?) {
        
        let buttonText = preferredResources.preferredText ?? ""
        
        if !buttonText.isEmpty || preferredResources.preferredImage != nil {
            let navButton = GiniBarButtonItem(
                image: preferredResources.preferredImage,
                title: preferredResources.preferredText,
                style: .plain,
                target: target,
                action: selector
            )
            switch position {
            case .right:
                navigationItem.setRightBarButton(navButton, animated: false)
            case .left:
                navigationItem.setLeftBarButton(navButton, animated: false)
            }
        }
    }
    
    func showErrorDialog(for error: Error, positiveAction: (() -> Void)?) {
        let message: String
        var cancelActionTitle: String = .localized(resource: CameraStrings.errorPopupCancelButton)
        var confirmActionTitle: String? = .localized(resource: CameraStrings.errorPopupPickAnotherFileButton)
        
        switch error {
        case let validationError as DocumentValidationError:
            message = validationError.message
        case let customValidationError as CustomDocumentValidationError:
            message = customValidationError.message
        case let pickerError as FilePickerError:
            message = pickerError.message
            switch pickerError {
            case .maxFilesPickedCountExceeded:
                confirmActionTitle = .localized(resource: CameraStrings.errorPopupReviewPagesButton)
            case .photoLibraryAccessDenied:
                confirmActionTitle = .localized(resource: CameraStrings.errorPopupGrantAccessButton)
            case .mixedDocumentsUnsupported:
                cancelActionTitle = .localized(resource: CameraStrings.mixedArraysPopupCancelButton)
                confirmActionTitle = .localized(resource: CameraStrings.mixedArraysPopupUsePhotosButton)
            }
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
