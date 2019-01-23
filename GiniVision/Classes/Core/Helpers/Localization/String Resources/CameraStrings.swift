//
//  CameraStrings.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 7/31/18.
//

import Foundation

enum CameraStrings: LocalizableStringResource {
    
    case captureButton, captureFailedMessage, capturedImagesStackSubtitleLabel, errorPopupCancelButton,
    errorPopupGrantAccessButton, errorPopupPickAnotherFileButton, errorPopupReviewPagesButton,
    exceededFileSizeErrorMessage, documentValidationGeneralErrorMessage, fileImportTipLabel, importFileButtonLabel,
    mixedArraysPopupCancelButton, mixedArraysPopupUsePhotosButton, mixedDocumentsErrorMessage, notAuthorizedButton,
    notAuthorizedMessage, photoLibraryAccessDeniedMessage, qrCodeDetectedPopupMessage, qrCodeDetectedPopupButton,
    tooManyPagesErrorMessage, unknownErrorMessage, wrongFormatErrorMessage, popupTitleImportPDF, popupOptionPhotos,
    popupOptionFiles, popupTitleImportPDForPhotos, popupCancel
    
    var tableName: String {
        return "camera"
    }
    
    var tableEntry: LocalizationEntry {
        switch self {
        case .captureButton:
            return ("captureButton",
                    "Title for capture button in camera screen will be used exclusively for accessibility label")
        case .captureFailedMessage:
            return ("captureFailed", "This message is shown when the camera access was denied")
        case .capturedImagesStackSubtitleLabel:
            return ("capturedImagesStackLabel", "label shown below images stack")
        case .errorPopupCancelButton:
            return ("errorPopup.cancelButton", "cancel button title")
        case .errorPopupGrantAccessButton:
            return ("filepicker.errorPopup.grantAccessButton", "grant access button title")
        case .errorPopupPickAnotherFileButton:
            return ("errorPopup.pickanotherfileButton", "pick another file button title")
        case .errorPopupReviewPagesButton:
            return ("errorPopup.reviewPages", "review pages button title")
        case .exceededFileSizeErrorMessage:
            return ("documentValidationError.excedeedFileSize",
                    "Message text error shown in camera screen when a file size is higher than 10MB")
        case .documentValidationGeneralErrorMessage:
            return ("documentValidationError.general",
                    "Message text of a general document validation error shown in camera screen")
        case .fileImportTipLabel:
            return ("fileImportTip", "tooltip text indicating new file import feature")
        case .mixedArraysPopupCancelButton:
            return ("mixedarrayspopup.cancel", "cancel button text for popup")
        case .mixedArraysPopupUsePhotosButton:
            return ("mixedarrayspopup.usePhotos", "use photos button text in popup")
        case .mixedDocumentsErrorMessage:
            return ("filepicker.mixedDocumentsUnsupported",
                    "Message text error when a more than one file type is selected")
        case .importFileButtonLabel:
            return ("fileImportButtonLabel", "label shown below import button")
        case .notAuthorizedButton:
            return ("notAuthorizedButton", "Button title to open the settings app")
        case .notAuthorizedMessage:
            return ("notAuthorized", "This message is shown when the camera access was denied")
        case .photoLibraryAccessDeniedMessage:
            return ("filepicker.photoLibraryAccessDenied",
                    "This message is shown when Photo library permission is denied")
        case .qrCodeDetectedPopupMessage:
            return ("qrCodeDetectedPopup.message", "Proceed button message")
        case .qrCodeDetectedPopupButton:
            return ("qrCodeDetectedPopup.buttonTitle", "Proceed button title")
        case .tooManyPagesErrorMessage:
            return ("documentValidationError.tooManyPages",
                    "Message text error shown in camera screen when a pdf length is higher than 10 pages" )
        case .unknownErrorMessage:
            return ("unknownError", "This message is shown when" +
                "there is an unknown error in the camera")
        case .wrongFormatErrorMessage:
            return ("documentValidationError.wrongFormat",
                "Message text error shown in camera screen when a file " +
                "has a wrong format (neither PDF, JPEG, GIF, TIFF or PNG)")
        case .popupTitleImportPDF:
            return ("popupTitleImportPDF", "This message is shown when" +
                "there is an unknown error in the camera")
        case .popupOptionFiles:
            return ("popupOptionFiles", "This message is shown when" +
                "there is an unknown error in the camera")
        case .popupCancel:
            return ("popupCancel", "This message is shown when" +
                "there is an unknown error in the camera")
        case .popupOptionPhotos:
            return ("popupOptionPhotos", "This message is shown when" +
                "there is an unknown error in the camera")
        case .popupTitleImportPDForPhotos:
            return ("popupTitleImportPDForPhotos", "This message is shown when" +
                "there is an unknown error in the camera")
        }
    }
    
    var customizable: Bool {
        switch self {
        case .captureButton, .captureFailedMessage, .errorPopupCancelButton,
             .errorPopupGrantAccessButton, .errorPopupPickAnotherFileButton, .errorPopupReviewPagesButton,
             .exceededFileSizeErrorMessage, .documentValidationGeneralErrorMessage,
             .mixedArraysPopupCancelButton, .mixedArraysPopupUsePhotosButton, .mixedDocumentsErrorMessage,
             .notAuthorizedButton, .notAuthorizedMessage, .photoLibraryAccessDeniedMessage, .qrCodeDetectedPopupMessage,
             .qrCodeDetectedPopupButton, .tooManyPagesErrorMessage, .unknownErrorMessage, .wrongFormatErrorMessage:
            return true
        case .capturedImagesStackSubtitleLabel, .fileImportTipLabel, .importFileButtonLabel, .popupTitleImportPDF,
             .popupTitleImportPDForPhotos, .popupOptionPhotos, .popupOptionFiles, .popupCancel:
            return false
        }
    }
}
