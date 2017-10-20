//
//  OpenWithTutorialViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/20/17.
//

import UIKit

typealias OpenWithTutorialStep = (title: String, subtitle: String, image: UIImage?)

final public  class OpenWithTutorialViewController: UICollectionViewController {
    let reuseIdentifier = "Cell"
    let items: [OpenWithTutorialStep] = [
        ("Wählen Sie bitte eine Rechnung aus", "Bitte wählen Sie hierfür auf Ihrem Smartphone die Rechnung als PDF innerhalb einer Email-App, eines PDF-Viewers oder einer anderen App aus.", UIImageNamedPreferred(named: "cameraDefaultDocumentImage")),
        ("Aktivieren Sie die Teilen-Funktion", "Um die Datei an die <Banking App Name> weiterzuleiten, verwenden Sie die Teilen-Funktion, dargestellt als ein Viereck mit hoch zeigendem Pfeil, und wählen Sie “Öffnen in...” oder “Datei freigeben”. Bitte wählen Sie dann die <Banking App Name> aus der Liste aus, um den Analyse- und Überweisungsprozess zu starten.", UIImageNamedPreferred(named: "cameraDefaultDocumentImage")),
        ("Auf iPads können Sie auch “Drag-and-drop” nutzen", "Auf iPads können ab iOS 11 PDFs oder Fotos bequem aus der Datei-Browser-App per “Drag-and-drop” in die <Banking App Name> gezogen werden, um den Überweisungsprozess zu starten. Hierfür öffnen Sie zunächst die <Banking App Name> und bringen Sie die Datei-Browser-App als zweite App auf dem Screen an. Wählen Sie dann die gewünschte Datei aus und ziehen Sie diese zur <Banking App Name> hinüber.", UIImageNamedPreferred(named: "cameraDefaultDocumentImage"))
    ]
    private var stepsCollectionLayout: UICollectionViewFlowLayout {
        return self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }

    public init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init() should be called instead")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
        self.collectionView?.backgroundColor = .lightGray
        self.collectionView!.register(OpenWithTutorialCollectionCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        stepsCollectionLayout.minimumLineSpacing = 1
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }

    // MARK: UICollectionViewDataSource

    override public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! OpenWithTutorialCollectionCell
        cell.fillWith(item: items[indexPath.row], at: indexPath.row)
    
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension OpenWithTutorialViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 550)
    }
}

final class OpenWithTutorialCollectionCell: UICollectionViewCell {
    
    let padding:(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) = (40, 20, 40, 20)
    let stepIndicatorCircleSize: CGSize = CGSize(width: 30, height: 30)
    
    lazy var stepIndicator: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .red
        return label
    }()
    
    lazy var stepIndicatorCircle: UIView = {
        var view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame.size = self.stepIndicatorCircleSize
        view.layer.borderColor = Colors.Gini.raspberry.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = self.stepIndicatorCircleSize.width / 2
        return view
    }()
    
    lazy var stepTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stepSubTitle: UILabel = {
        var label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    lazy var stepImage: UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 14
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(stepIndicator)
        addSubview(stepIndicatorCircle)
        addSubview(stepTitle)
        addSubview(stepSubTitle)
        addSubview(stepImage)
        
        addConstrains()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(frame:) should be used instead")
    }
    
    private func addConstrains() {
        
        // stepIndicator
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: padding.top)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        
        ConstraintUtils.addActiveConstraint(item: stepIndicator, attribute: .centerX, relatedBy: .equal, toItem: stepIndicatorCircle, attribute: .centerX, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: stepIndicator, attribute: .centerY, relatedBy: .equal, toItem: stepIndicatorCircle, attribute: .centerY, multiplier: 1.0, constant: 0)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stepIndicatorCircleSize.height)
        ConstraintUtils.addActiveConstraint(item: stepIndicatorCircle, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: stepIndicatorCircleSize.width)

        // stepTitle
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .top, relatedBy: .equal, toItem: stepIndicator, attribute: .bottom, multiplier: 1.0, constant: 30)
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: stepTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        
        // stepSubTitle
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .top, relatedBy: .equal, toItem: stepTitle, attribute: .bottom, multiplier: 1.0, constant: 20)
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: stepSubTitle, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        
        // stepImage
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .top, relatedBy: .equal, toItem: stepSubTitle, attribute: .bottom, multiplier: 1.0, constant: 40)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: padding.left)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -padding.right)
        ConstraintUtils.addActiveConstraint(item: stepImage, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -40, priority: 999)

    }
    
    public func fillWith(item: OpenWithTutorialStep, at position: Int) {
        stepIndicator.text = String(describing: position + 1)
        stepTitle.text = item.title
        stepSubTitle.text = item.subtitle
        stepImage.image = item.image
    }
}

