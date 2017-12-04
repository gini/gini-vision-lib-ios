//
//  OpenWithTutorialCollectionHeader.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/24/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

final class OpenWithTutorialCollectionHeader: UICollectionReusableView {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (20, 20, 20, 20)
    
    lazy var headerContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = .black
        let textSize: CGFloat = UIDevice.current.isIpad ? 16 : 14
        label.font = label.font.withSize(textSize)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 12 / textSize
        return label
    }()
    
    lazy var bottomLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = nil
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        headerContainer.addSubview(headerTitle)
        addSubview(headerContainer)
        addSubview(bottomLine)
        
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstraints() {
        Contraints.active(item: headerContainer, attr: .top, relatedBy: .equal, to: self, attr: .top, multiplier: 1.0)
        Contraints.active(item: headerContainer, attr: .leading, relatedBy: .equal, to: self, attr: .leading, multiplier: 1.0)
        Contraints.active(item: headerContainer, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing, multiplier: 1.0)
        
        Contraints.active(item: headerTitle, attr: .top, relatedBy: .equal, to: headerContainer, attr: .top, multiplier: 1.0, constant: padding.top)
        Contraints.active(item: headerTitle, attr: .leading, relatedBy: .equal, to: headerContainer, attr: .leading, multiplier: 1.0, constant: padding.left)
        Contraints.active(item: headerTitle, attr: .trailing, relatedBy: .equal, to: headerContainer, attr: .trailing, multiplier: 1.0, constant: -padding.right)
        Contraints.active(item: headerTitle, attr: .bottom, relatedBy: .equal, to: headerContainer, attr: .bottom, multiplier: 1.0, constant: -padding.bottom)
        
        Contraints.active(item: bottomLine, attr: .top, relatedBy: .equal, to: headerContainer, attr: .bottom, multiplier: 1.0)
        Contraints.active(item: bottomLine, attr: .leading, relatedBy: .equal, to: self, attr: .leading, multiplier: 1.0)
        Contraints.active(item: bottomLine, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing, multiplier: 1.0)
        Contraints.active(item: bottomLine, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom, multiplier: 1.0)
        Contraints.active(item: bottomLine, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute, multiplier: 1.0, constant: 1)
    }
}

