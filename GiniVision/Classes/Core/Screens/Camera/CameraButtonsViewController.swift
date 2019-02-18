//
//  CameraButtonsViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 2/18/19.
//

import UIKit

protocol CameraButtonsViewControllerDelegate: class {
    func cameraButtons(_ viewController: CameraButtonsViewController,
                       didTapOn button: CameraButtonsViewController.Button)
}

final class CameraButtonsViewController: UIViewController {

    weak var delegate: CameraButtonsViewControllerDelegate?
    fileprivate let giniConfiguration: GiniConfiguration
    fileprivate let currentDevice: UIDevice
    fileprivate let captureButtonMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    fileprivate var cameraCaptureButtonImage: UIImage? {
        return UIImageNamedPreferred(named: "cameraCaptureButton")
    }
    
    enum Button {
        case fileImport, capture, imagesStack
    }
    
    lazy var captureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(self.cameraCaptureButtonImage, for: .normal)
        button.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        button.accessibilityLabel = self.giniConfiguration.cameraCaptureButtonTitle
        return button
    }()
    
    lazy var flashToggleButton: UIButton = {
        let flashToggle = UIButton(type: .custom)
        flashToggle.translatesAutoresizingMaskIntoConstraints = false
        flashToggle.setImage(UIImage(bundleName: "flashOn"), for: .selected)
        flashToggle.setImage(UIImage(bundleName: "flashOff"), for: .normal)
        flashToggle.imageView?.contentMode = .scaleAspectFit
        flashToggle.addTarget(self, action: #selector(tapOnFlashToggle), for: .touchUpInside)
        
        if currentDevice.isIpad {
            flashToggle.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        } else {
            flashToggle.imageEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 20)
        }
        
        return flashToggle
    }()
    
    lazy var capturedImagesStackView: CapturedImagesStackView = {
        let view = CapturedImagesStackView(giniConfiguration: giniConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.didTapImageStackButton = { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.cameraButtons(self, didTapOn: .imagesStack)
        }
        return view
    }()
    
    lazy var fileImportButtonView: FileImportButtonView = {
        let view = FileImportButtonView(giniConfiguration: giniConfiguration)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.didTapButton = { [weak self] in
            guard let self = self else { return }
            self.delegate?.cameraButtons(self, didTapOn: .fileImport)
        }
        return view
    }()
    
    lazy var leftStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.alignment = currentDevice.isIpad ? .top : .center
        
        return stackView
    }()
    
    lazy var rightStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .horizontal
        stackView.alignment = currentDevice.isIpad ? .bottom : .center
        
        return stackView
    }()
    
    init(giniConfiguration: GiniConfiguration = .shared, currentDevice: UIDevice = .current) {
        self.giniConfiguration = giniConfiguration
        self.currentDevice = currentDevice
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        view.backgroundColor = .black
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(captureButton)
        view.addSubview(leftStackView)
        view.addSubview(rightStackView)
        
        if currentDevice.isIpad {
            let topVerticalAlignedStackView = UIStackView()
            topVerticalAlignedStackView.translatesAutoresizingMaskIntoConstraints = false
            topVerticalAlignedStackView.axis = .vertical
            topVerticalAlignedStackView.spacing = 32
            topVerticalAlignedStackView.alignment = .center
            
            if giniConfiguration.multipageEnabled {
                topVerticalAlignedStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            if true {
                topVerticalAlignedStackView.addArrangedSubview(flashToggleButton)
            }
            
            rightStackView.addArrangedSubview(topVerticalAlignedStackView)
        } else {
            if giniConfiguration.multipageEnabled {
                rightStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            leftStackView.addArrangedSubview(flashToggleButton)
        }
        
        addConstraints()
    }
    
    func addFileImportButton() {
        if currentDevice.isIpad {
            let bottomVerticalAlignedStackView = UIStackView()
            bottomVerticalAlignedStackView.translatesAutoresizingMaskIntoConstraints = false
            bottomVerticalAlignedStackView.axis = .vertical
            bottomVerticalAlignedStackView.alignment = .center
            bottomVerticalAlignedStackView.addArrangedSubview(fileImportButtonView)
            bottomVerticalAlignedStackView.isLayoutMarginsRelativeArrangement = true

            leftStackView.addArrangedSubview(bottomVerticalAlignedStackView)
        } else {
            leftStackView.insertArrangedSubview(fileImportButtonView, at: 0)
        }

        addImportButtonConstraints()
    }
}

// MARK: - Button actions

fileprivate extension CameraButtonsViewController {
    @objc func captureImage(_ sender: AnyObject) {
        delegate?.cameraButtons(self, didTapOn: .capture)
    }
    
    @objc func tapOnFlashToggle(_ button: UIButton) {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        button.isSelected = !button.isSelected
    }
}

// MARK: - Constraints

fileprivate extension CameraButtonsViewController {
    
    func addConstraints() {
        addCaptureButtonConstraints()
        addStackViewConstraints()
        
        if true {
            addFlashButtonConstraints()
        }
    }
    
    func addCaptureButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: captureButton, attr: .height, relatedBy: .equal, to: captureButton, attr: .width)
            Constraints.active(item: captureButton, attr: .centerY, relatedBy: .equal, to: view, attr: .centerY)
            Constraints.active(item: captureButton, attr: .trailing, relatedBy: .equal, to: view,
                               attr: .trailing, constant: -captureButtonMargins.right)
            Constraints.active(item: captureButton, attr: .leading, relatedBy: .equal, to: view, attr: .leading,
                               constant: captureButtonMargins.left, priority: 750)
        } else {
            Constraints.active(item: captureButton, attr: .width, relatedBy: .equal, to: captureButton, attr: .height)
            
            Constraints.active(item: captureButton, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
            Constraints.active(item: captureButton, attr: .top, relatedBy: .equal, to: view, attr: .top,
                               constant: captureButtonMargins.top)
            Constraints.active(item: captureButton, attr: .bottom, relatedBy: .equal, to: view, attr: .bottom,
                               constant: -captureButtonMargins.bottom)
        }
    }
    
    func addStackViewConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: rightStackView, attr: .trailing, relatedBy: .equal, to: view,
                               attr: .trailing)
            Constraints.active(item: rightStackView, attr: .leading, relatedBy: .equal, to: view,
                               attr: .leading)
            Constraints.active(item: rightStackView, attr: .top, relatedBy: .equal,
                               to: view, attr: .top)
            Constraints.active(item: rightStackView, attr: .bottom, relatedBy: .equal, to: captureButton,
                               attr: .top, constant: -50)
            
            Constraints.active(item: leftStackView, attr: .trailing, relatedBy: .equal, to: view,
                               attr: .trailing)
            Constraints.active(item: leftStackView, attr: .leading, relatedBy: .equal, to: view,
                               attr: .leading)
            Constraints.active(item: leftStackView, attr: .bottom, relatedBy: .equal,
                               to: view, attr: .bottom)
            Constraints.active(item: leftStackView, attr: .top, relatedBy: .equal, to: captureButton,
                               attr: .bottom, constant: 50)
        } else {
            Constraints.active(item: rightStackView, attr: .trailing, relatedBy: .equal, to: view,
                               attr: .trailing)
            Constraints.active(item: rightStackView, attr: .top, relatedBy: .equal, to: view,
                               attr: .top)
            Constraints.active(item: rightStackView, attr: .bottom, relatedBy: .equal, to: view,
                               attr: .bottom)
            Constraints.active(item: rightStackView, attr: .leading, relatedBy: .equal, to: captureButton,
                               attr: .trailing, priority: 750)
            
            Constraints.active(item: leftStackView, attr: .leading, relatedBy: .equal, to: view,
                               attr: .leading)
            Constraints.active(item: leftStackView, attr: .top, relatedBy: .equal, to: view,
                               attr: .top)
            Constraints.active(item: leftStackView, attr: .bottom, relatedBy: .equal, to: view,
                               attr: .bottom)
            Constraints.active(item: leftStackView, attr: .trailing, relatedBy: .equal, to: captureButton,
                               attr: .leading, priority: 750)
        }
    }
    
    func addImportButtonConstraints() {
        if UIDevice.current.isIpad {
            fileImportButtonView.widthAnchor
                .constraint(equalTo: leftStackView.widthAnchor,
                            constant: -(leftStackView.layoutMargins.left + leftStackView.layoutMargins.right))
                .isActive = true
        } else {
            fileImportButtonView.heightAnchor.constraint(equalTo: leftStackView.heightAnchor).isActive = true
        }
    }
    
    func addFlashButtonConstraints() {
        if UIDevice.current.isIpad {
            flashToggleButton.widthAnchor.constraint(equalTo: rightStackView.widthAnchor,
                                                     multiplier: 9/20).isActive = true
        } else {
            let height: CGFloat = 60
            flashToggleButton.heightAnchor.constraint(equalToConstant: height).isActive = true
            flashToggleButton.widthAnchor.constraint(equalTo: flashToggleButton.heightAnchor,
                                                     multiplier: 11 / 17).isActive = true
        }
        
    }
}
