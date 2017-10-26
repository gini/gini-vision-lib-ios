//
//  ImageAnalysisNoResultsContainerViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/16/17.
//

import Foundation

internal class ImageAnalysisNoResultsContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // Resources
    fileprivate let closeButtonResources = PreferredButtonResource(image: "navigationCameraClose", title: "ginivision.navigationbar.camera.close", comment: "Button title in the navigation bar for the close button on the camera screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarCameraTitleCloseButton)
    fileprivate let backButtonResources = PreferredButtonResource(image: "arrowBack", title: "ginivision.navigationbar.analysis.back", comment: "Button title in the navigation bar for the back button on the analysis screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarAnalysisTitleBackButton)

    init(canGoBack: Bool = true) {
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor

        // Configure content controller
        let imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController
        
        if canGoBack {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil, bottomButtonIcon: nil)
        }
        
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.backToCamera()
        }
        contentController = imageAnalysisNoResultsViewController
        
        // Configure close button
        if canGoBack {
            setupLeftNavigationItem(usingResources: backButtonResources, selector: #selector(backToCamera))
        } else {
            setupLeftNavigationItem(usingResources: closeButtonResources, selector: #selector(close))
        }
        
        view.addSubview(containerView)
        
        addConstraints()

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayContent(contentController) 
    }
    
    @objc private func backToCamera() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelAnalysis?()
        
        if let cameraViewController = navigationController?.viewControllers.flatMap({ $0 as? CameraContainerViewController }).first {
            _ = navigationController?.popToViewController(cameraViewController, animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Constraints
    fileprivate func addConstraints() {
        let superview = self.view
        
        // Container view
        containerView.translatesAutoresizingMaskIntoConstraints = false
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .top, relatedBy: .equal, toItem: superview, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: superview, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: superview, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: superview, attribute: .leading, multiplier: 1, constant: 0)
    }
}
