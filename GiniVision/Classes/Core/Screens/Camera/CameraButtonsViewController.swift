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
    
    @objc func tapOnFlashToggle(_ button: UIButton) {
        if #available(iOS 10.0, *) {
            UIImpactFeedbackGenerator().impactOccurred()
        }
        button.isSelected = !button.isSelected
    }
    
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
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
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
        
        if UIDevice.current.isIpad {
            let verticalAlignedStackView = UIStackView()
            verticalAlignedStackView.axis = .vertical
            verticalAlignedStackView.spacing = 32
            
            if giniConfiguration.multipageEnabled {
                verticalAlignedStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            verticalAlignedStackView.addArrangedSubview(flashToggleButton)
            
            rightStackView.addArrangedSubview(verticalAlignedStackView)
        } else {
            if giniConfiguration.multipageEnabled {
                rightStackView.addArrangedSubview(capturedImagesStackView)
            }
            
            leftStackView.addArrangedSubview(flashToggleButton)
        }
        
        addConstraints()
    }
    
    func enableFileImport() {
        // Configure import file button
        if currentDevice.isIpad {
            leftStackView.addArrangedSubview(fileImportButtonView)
        } else {
            leftStackView.insertArrangedSubview(fileImportButtonView, at: 0)
        }
        addImportButtonConstraints()
    }
    
    @objc fileprivate func captureImage(_ sender: AnyObject) {
        delegate?.cameraButtons(self, didTapOn: .capture)
    }
    
}

// MARK: - Constraints

fileprivate extension CameraButtonsViewController {
    
    func addConstraints() {
        addviewButtonsConstraints()
        addStackViewConstraints()
        
        if true {
            addFlashButtonConstraints()
        }
    }
    
    func addviewButtonsConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: captureButton, attr: .width, relatedBy: .equal, to: view, attr: .width,
                               constant: -32)
            Constraints.active(item: captureButton, attr: .height, relatedBy: .equal, to: captureButton, attr: .width)
            Constraints.active(item: captureButton, attr: .centerY, relatedBy: .equal, to: view, attr: .centerY)
            Constraints.active(item: captureButton, attr: .trailing, relatedBy: .equal, to: view,
                               attr: .trailing, constant: -16)
            Constraints.active(item: captureButton, attr: .leading, relatedBy: .equal, to: view, attr: .leading,
                               constant: 16, priority: 750)
        } else {
            Constraints.active(item: captureButton, attr: .height, relatedBy: .equal, to: view, attr: .height,
                               constant: -32)
            Constraints.active(item: captureButton, attr: .width, relatedBy: .equal, to: captureButton, attr: .height)
            
            Constraints.active(item: captureButton, attr: .centerX, relatedBy: .equal, to: view, attr: .centerX)
            Constraints.active(item: captureButton, attr: .top, relatedBy: .equal, to: view, attr: .top,
                               constant: 16)
            Constraints.active(item: captureButton, attr: .bottom, relatedBy: .equal, to: view, attr: .bottom,
                               constant: -16)
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
            
        } else {
            Constraints.active(item: fileImportButtonView, attr: .height, relatedBy: .equal, to: leftStackView,
                               attr: .height)
        }
    }
    
    func addFlashButtonConstraints() {
        if UIDevice.current.isIpad {
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: 50)
            Constraints.active(item: flashToggleButton, attr: .width, relatedBy: .equal, to: rightStackView,
                               attr: .width, constant: -16)
        } else {
            let height: CGFloat = 60
            Constraints.active(item: flashToggleButton, attr: .height, relatedBy: .equal, to: nil,
                               attr: .notAnAttribute, constant: height)
            Constraints.active(item: flashToggleButton, attr: .width, relatedBy: .equal, to: flashToggleButton,
                               attr: .height, multiplier: 11 / 17, constant: 1.0)
        }
        
    }
}
