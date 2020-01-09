//
//  CheckboxButton.swift
//  GiniVision
//
//  Created by Maciej Trybilo on 19.12.19.
//

import UIKit

class CheckboxButton: UIButton {

    enum CheckedState {
        case checked
        case unchecked
    }
    
    var checkedState: CheckedState = .checked {
        
        didSet {
            update()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        
        widthAnchor.constraint(equalToConstant: 24).isActive = true
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        layer.cornerRadius = 3
        layer.borderWidth = 1
        
        setImage(UIImage(named: "checkmark", in: Bundle(for: GiniVision.self), compatibleWith: nil),
                 for: .normal)
    }
    
    private func update() {
        
        switch checkedState {
        case .checked:
            backgroundColor = tintColor
            
            layer.borderColor = UIColor.clear.cgColor
            
        case .unchecked:
            backgroundColor = .white
            
            if #available(iOS 13.0, *) {
                layer.borderColor = UIColor.secondaryLabel.cgColor
            } else {
                layer.borderColor = UIColor.gray.cgColor
            }
        }
    }
}
