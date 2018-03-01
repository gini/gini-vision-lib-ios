//
//  ImagePickerCollectionViewCell.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/27/18.
//

import Foundation

final class ImagePickerCollectionViewCell: UICollectionViewCell {
    static let identifier = "ImagePickerCollectionViewCell"
    
    let selectedCircleSize = CGSize(width: 25, height: 25)
    
    lazy var galleryImage: UIImageView = {
        let galleryImage: UIImageView = UIImageView(frame: .zero)
        galleryImage.translatesAutoresizingMaskIntoConstraints = false
        galleryImage.contentMode = .scaleAspectFill
        galleryImage.clipsToBounds = true
        return galleryImage
    }()
    
    lazy var selectedForegroundView: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.alpha = 0
        return view
    }()
    
    lazy var checkImage: UIImageView = {
        let image = UIImageNamedPreferred(named: "supportedFormatsIcon")
        var imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.alpha = 0
        return imageView
    }()
    
    lazy var checkCircleBackground: UIView = {
        let circleView = UIView()
        circleView.translatesAutoresizingMaskIntoConstraints = false
        circleView.layer.borderWidth = 1
        circleView.layer.cornerRadius = self.selectedCircleSize.width / 2
        circleView.layer.borderColor = UIColor.white.cgColor
        return circleView
    }()
    
    override var isSelected: Bool {
        didSet {
            selectedForegroundView.alpha = isSelected ? 1 : 0
            changeCheckCircle(to: isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(galleryImage)
        addSubview(selectedForegroundView)
        addSubview(checkCircleBackground)
        checkCircleBackground.addSubview(checkImage)
        
        Constraints.pin(view: galleryImage, toSuperView: self)
        Constraints.pin(view: selectedForegroundView, toSuperView: self)
        Constraints.active(item: checkCircleBackground, attr: .bottom, relatedBy: .equal, to: self, attr: .bottom,
                           constant: -5)
        Constraints.active(item: checkCircleBackground, attr: .trailing, relatedBy: .equal, to: self, attr: .trailing,
                           constant: -5)
        Constraints.active(item: checkCircleBackground, attr: .height, relatedBy: .equal, to: nil,
                           attr: .notAnAttribute, constant: selectedCircleSize.width)
        Constraints.active(item: checkCircleBackground, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: selectedCircleSize.height)
        Constraints.center(view: checkImage, with: checkCircleBackground)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func size(for screen: UIScreen = UIScreen.main,
                    itemsInARow: Int,
                    collectionViewLayout: UICollectionViewLayout) -> CGSize {
        let width = screen.bounds.width / CGFloat(itemsInARow)
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: width, height: width)
        }
        
        let spacing = flowLayout.minimumInteritemSpacing * CGFloat(itemsInARow - 1)
        let widthWithoutSpacing = (screen.bounds.width - spacing) / CGFloat(itemsInARow)
        
        return CGSize(width: widthWithoutSpacing, height: widthWithoutSpacing)
    }
    
    fileprivate func changeCheckCircle(to selected: Bool) {
        if selected {
            checkCircleBackground.layer.borderColor = Colors.Gini.blue.cgColor
            checkCircleBackground.backgroundColor = Colors.Gini.blue
            checkImage.alpha = 1
        } else {
            checkCircleBackground.layer.borderColor = UIColor.white.cgColor
            checkCircleBackground.backgroundColor = .clear
            checkImage.alpha = 0
        }
    }
}
