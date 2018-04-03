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
        let buttonText = preferredResources.preferredText
        if buttonText != nil && !buttonText!.isEmpty {
            let navButton = GiniBarButtonItem(
                image: preferredResources.preferredImage,
                title: buttonText,
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
    
    func showErrorDialog(for error: Error, positiveAction: @escaping (() -> Void)) {
        let message: String
        var cancelActionTitle: String = NSLocalizedStringPreferred("ginivision.camera.errorPopup.cancelButton",
                                                                   comment: "cancel button title")
        var confirmActionTitle: String? = NSLocalizedStringPreferred("ginivision.camera.errorPopup.pickanotherfileButton",
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
                confirmActionTitle = NSLocalizedStringPreferred("ginivision.camera.errorPopup.reviewPages",
                                                                comment: "review pages button title")
            case .photoLibraryAccessDenied:
                cancelActionTitle = NSLocalizedStringPreferred("ginivision.camera.filepicker.errorPopup.cancelButton",
                                                                comment: "cancel button title")
                confirmActionTitle = NSLocalizedStringPreferred("ginivision.camera.filepicker.errorPopup.grantAccessButton",
                                                                comment: "cancel button title")
            case .mixedDocumentsUnsupported:
                cancelActionTitle = NSLocalizedStringPreferred("ginivision.camera.mixedarrayspopup.cancel",
                                                               comment: "cancel button text for popup")
                confirmActionTitle = NSLocalizedStringPreferred("ginivision.camera.mixedarrayspopup.usePhotos",
                                                                comment: "use photos button text in popup")
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
        
        if let confirmActionTitle = confirmActionTitle {
            alertViewController.addAction(UIAlertAction(title: confirmActionTitle,
                                                        style: .default,
                                                        handler: { _ in
                                                            confirmAction?()
            }))
        }
        
        return alertViewController
    }
}
