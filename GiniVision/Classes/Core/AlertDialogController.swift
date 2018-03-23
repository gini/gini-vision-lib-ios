//
//  MultipageAlertDialogController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 3/23/18.
//

import UIKit

final class AlertDialogController: UIViewController {
    
    let giniConfiguration: GiniConfiguration
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .white
        return containerView
    }()
    
    lazy var dialogTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.dialogTitle
        label.textAlignment = .center
        label.font = self.giniConfiguration.customFont.bold.withSize(18)
        
        return label
    }()
    
    lazy var dialogSubTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.dialogSubTitle
        label.textAlignment = .center
        label.font = self.giniConfiguration.customFont.regular.withSize(14)
        label.numberOfLines = 0

        return label
    }()
    
    lazy var multipageImageView: UIImageView = {
        let imageView = UIImageView(image: self.dialogImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(self.buttonTitle, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        if let image = self.buttonImage {
            button.setImage(image, for: .normal)
        }

        button.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.backgroundColor = GiniConfiguration.sharedConfiguration.noResultsBottomButtonColor
        return button
    }()
    
    lazy var tapOutsideGesture: UITapGestureRecognizer =
        UITapGestureRecognizer(target: self, action: #selector(self.tapOutsideAction))
    
    var continueAction: (() -> Void) = {}
    var cancelAction: (() -> Void) = {}
    let dialogTitle: String
    let dialogSubTitle: String
    let dialogImage: UIImage?
    let buttonTitle: String
    let buttonImage: UIImage?
    
    init(giniConfiguration: GiniConfiguration,
         title: String,
         subTitle: String,
         image: UIImage?,
         buttonTitle: String,
         buttonImage: UIImage? = nil) {
        self.giniConfiguration = giniConfiguration
        self.dialogTitle = title
        self.dialogSubTitle = subTitle
        self.dialogImage = image
        self.buttonImage = buttonImage
        self.buttonTitle = buttonTitle
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view.addSubview(containerView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addGestureRecognizer(tapOutsideGesture)
        containerView.layer.cornerRadius = 2.0
        containerView.addSubview(dialogTitleLabel)
        containerView.addSubview(dialogSubTitleLabel)
        containerView.addSubview(multipageImageView)
        containerView.addSubview(continueButton)
        
        addConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func addConstraints() {
        Constraints.active(item: containerView, attr: .top, relatedBy: .greaterThanOrEqual, to: view, attr: .top, constant: 10, priority: 999)
        Constraints.active(item: containerView, attr: .bottom, relatedBy: .lessThanOrEqual, to: view, attr: .bottom, constant: -10, priority: 999)
        Constraints.active(item: containerView, attr: .leading, relatedBy: .greaterThanOrEqual, to: view, attr: .leading, constant: 10)
        Constraints.active(item: containerView, attr: .trailing, relatedBy: .lessThanOrEqual, to: view, attr: .trailing, constant: -10)
        Constraints.active(item: containerView, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
        Constraints.active(item: containerView, attr: .centerY, relatedBy: .equal, to: view, attr: .centerY)
        Constraints.active(item: containerView, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                           constant: 375, priority: 999)
        Constraints.active(item: containerView, attr: .height, relatedBy: .lessThanOrEqual, to: view, attr: .height, constant: 300)

        Constraints.active(item: dialogTitleLabel, attr: .top, relatedBy: .equal, to: containerView, attr: .top, constant: 20)
        Constraints.active(item: dialogTitleLabel, attr: .leading, relatedBy: .equal, to: containerView, attr: .leading, constant: 20)
        Constraints.active(item: dialogTitleLabel, attr: .trailing, relatedBy: .equal, to: containerView, attr: .trailing, constant: -20)

        Constraints.active(item: dialogSubTitleLabel, attr: .top, relatedBy: .equal, to: dialogTitleLabel, attr: .bottom, constant: 10, priority: 999)
        Constraints.active(item: dialogSubTitleLabel, attr: .leading, relatedBy: .equal, to: containerView, attr: .leading, constant: 20)
        Constraints.active(item: dialogSubTitleLabel, attr: .trailing, relatedBy: .equal, to: containerView, attr: .trailing, constant: -20)

        Constraints.active(item: multipageImageView, attr: .top, relatedBy: .equal, to: dialogSubTitleLabel, attr: .bottom, constant: 20, priority: 999)
        Constraints.active(item: multipageImageView, attr: .leading, relatedBy: .equal, to: containerView, attr: .leading, constant: 20)
        Constraints.active(item: multipageImageView, attr: .trailing, relatedBy: .equal, to: containerView, attr: .trailing, constant: -20)

        Constraints.active(item: continueButton, attr: .top, relatedBy: .greaterThanOrEqual, to: multipageImageView, attr: .bottom, constant: 20)
        Constraints.active(item: continueButton, attr: .leading, relatedBy: .equal, to: containerView, attr: .leading, constant: 20)
        Constraints.active(item: continueButton, attr: .trailing, relatedBy: .equal, to: containerView, attr: .trailing, constant: -20)
        Constraints.active(item: continueButton, attr: .bottom, relatedBy: .equal, to: containerView, attr: .bottom, constant: -20)
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

// MARK: - UserDefaults flags

extension AlertDialogController {
    fileprivate static let shouldShowNewMultipageFeatureKey = "ginivision.defaults.shouldShowNewMultipageFeature"
    static var shouldShowNewMultipageFeature: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: AlertDialogController.shouldShowNewMultipageFeatureKey)
        }
        get {
            let defaultsValue = UserDefaults
                .standard
                .object(forKey: AlertDialogController.shouldShowNewMultipageFeatureKey) as? Bool
            return defaultsValue ?? true
        }
    }
}
