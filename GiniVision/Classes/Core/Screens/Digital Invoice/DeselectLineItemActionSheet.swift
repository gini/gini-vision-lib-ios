//
//  DeselectLineItemActionSheet.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 02.01.20.
//

import Foundation
import Gini

class DeselectLineItemActionSheet {
    
    func present(from viewController: UIViewController,
                 source: UIView?,
                 returnReasons: [ReturnReason],
                 completion: @escaping (DigitalInvoice.LineItem.SelectedState) -> Void) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: NSLocalizedString("ginivision.digitalinvoice.deselectreasonactionsheet.message",
                                                                       bundle: Bundle(for: GiniVision.self),
                                                                       comment: ""),
                                            preferredStyle: .actionSheet)
        
        for reason in returnReasons {
            
            actionSheet.addAction(UIAlertAction(title: reason.labelInLocalLanguageOrGerman,
                                                style: .default,
                                                handler:
                { _ in
                    completion(.deselected(reason: reason))
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("ginivision.digitalinvoice.deselectreasonactionsheet.action.cancel",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: ""),
                                            style: .cancel,
                                            handler: { _ in
                                                completion(.selected)
        }))
        
        actionSheet.popoverPresentationController?.sourceView = source
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}
