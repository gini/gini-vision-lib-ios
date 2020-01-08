//
//  DeselectLineItemActionSheet.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 02.01.20.
//

import Foundation

class DeselectLineItemActionSheet {
    
    func present(from viewController: UIViewController,
                 completion: @escaping (DigitalInvoice.LineItem.SelectedState) -> Void) {
        
        let actionSheet = UIAlertController(title: nil,
                                            message: "Your reasons to return this item",
                                            preferredStyle: .actionSheet)
                
        for reason in DigitalInvoice.LineItem.SelectedState.Reason.allCases {
            
            actionSheet.addAction(UIAlertAction(title: reason.displayString,
                                                style: .default,
                                                handler:
                { _ in
                    completion(.deselected(reason: reason))
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(.selected)
        }))
        
        viewController.present(actionSheet, animated: true, completion: nil)
    }
}
