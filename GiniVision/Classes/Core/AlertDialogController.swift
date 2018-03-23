//
//  MultipageAlertDialogController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/23/18.
//

import UIKit

final class AlertDialogController: UIViewController {
    
    let giniConfiguration: GiniConfiguration
    
    lazy var container: UIView = {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .white
        return container
    }()
    
    lazy var dialogTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is the title"
        label.textAlignment = .center
        label.font = self.giniConfiguration.customFont.bold.withSize(18)
        
        return label
    }()
    
    lazy var dialogSubTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is the subtitle This is the subtitle This is the subtitle This is the subtitle This is the subtitle This is the subtitle"
        label.textAlignment = .center
        label.font = self.giniConfiguration.customFont.regular.withSize(14)
        label.numberOfLines = 0

        return label
    }()
    
    lazy var multipageImage: UIImageView = {
        let imageView = UIImageView(image: UIImageNamedPreferred(named: "multipageIcon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle("Let's scan!", for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        button.setImage(UIImage(named: "cameraIcon",
                                       in: Bundle(for: GiniVision.self),
                                       compatibleWith: nil), for: .normal)
        button.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.backgroundColor = GiniConfiguration.sharedConfiguration.noResultsBottomButtonColor
        return button
    }()
    
    lazy var tapOutsideGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                action: #selector(self.tapOutsideAction))
    
    var continueAction: (() -> Void) = {}
    var cancelAction: (() -> Void) = {}
    
    init(giniConfiguration: GiniConfiguration) {
        self.giniConfiguration = giniConfiguration
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(container)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addGestureRecognizer(tapOutsideGesture)
        container.layer.cornerRadius = 2.0
        container.addSubview(dialogTitle)
        container.addSubview(dialogSubTitle)
        container.addSubview(multipageImage)
        container.addSubview(continueButton)
        
        addConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func addConstraints() {
        Constraints.active(item: container, attr: .top, relatedBy: .greaterThanOrEqual, to: view, attr: .top, constant: 10, priority: 999)
        Constraints.active(item: container, attr: .bottom, relatedBy: .lessThanOrEqual, to: view, attr: .bottom, constant: -10, priority: 999)
        Constraints.active(item: container, attr: .leading, relatedBy: .greaterThanOrEqual, to: view, attr: .leading, constant: 10)
        Constraints.active(item: container, attr: .trailing, relatedBy: .lessThanOrEqual, to: view, attr: .trailing, constant: -10)
        Constraints.active(item: container, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
        Constraints.active(item: container, attr: .centerY, relatedBy: .equal, to: view, attr: .centerY)
        Constraints.active(item: container, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 375, priority: 999)
        Constraints.active(item: container, attr: .height, relatedBy: .lessThanOrEqual, to: view, attr: .height, constant: 300)

        Constraints.active(item: dialogTitle, attr: .top, relatedBy: .equal, to: container, attr: .top, constant: 20)
        Constraints.active(item: dialogTitle, attr: .leading, relatedBy: .equal, to: container, attr: .leading, constant: 20)
        Constraints.active(item: dialogTitle, attr: .trailing, relatedBy: .equal, to: container, attr: .trailing, constant: -20)

        Constraints.active(item: dialogSubTitle, attr: .top, relatedBy: .equal, to: dialogTitle, attr: .bottom, constant: 10, priority: 999)
        Constraints.active(item: dialogSubTitle, attr: .leading, relatedBy: .equal, to: container, attr: .leading, constant: 20)
        Constraints.active(item: dialogSubTitle, attr: .trailing, relatedBy: .equal, to: container, attr: .trailing, constant: -20)

        Constraints.active(item: multipageImage, attr: .top, relatedBy: .equal, to: dialogSubTitle, attr: .bottom, constant: 20, priority: 999)
        Constraints.active(item: multipageImage, attr: .leading, relatedBy: .equal, to: container, attr: .leading, constant: 20)
        Constraints.active(item: multipageImage, attr: .trailing, relatedBy: .equal, to: container, attr: .trailing, constant: -20)

        Constraints.active(item: continueButton, attr: .top, relatedBy: .greaterThanOrEqual, to: multipageImage, attr: .bottom, constant: 20)
        Constraints.active(item: continueButton, attr: .leading, relatedBy: .equal, to: container, attr: .leading, constant: 20)
        Constraints.active(item: continueButton, attr: .trailing, relatedBy: .equal, to: container, attr: .trailing, constant: -20)
        Constraints.active(item: continueButton, attr: .bottom, relatedBy: .equal, to: container, attr: .bottom, constant: -20)
        Constraints.active(item: continueButton, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 60)

    }
    
    @objc func continueButtonAction() {
        continueAction()
    }
    
    @objc func tapOutsideAction() {
        cancelAction()
    }
    
}
