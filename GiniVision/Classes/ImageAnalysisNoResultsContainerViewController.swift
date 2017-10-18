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
        
        // Configure content controller
        let imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController
        
        if canGoBack {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil, bottomButtonIcon: nil)
        }
        
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.back()
        }
        contentController = imageAnalysisNoResultsViewController
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        if canGoBack {
            setupLeftNavigationItem(usingResources: backButtonResources, selector: #selector(back))
        } else {
            setupLeftNavigationItem(usingResources: closeButtonResources, selector: #selector(close))
        }
        
        // Configure view hierachy
        view.addSubview(containerView)
        
        // Add constraints
        addConstraints()
        
        // remove analysis from stack.

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add content to container view
        displayContent(contentController) 
    }
    
    @objc private func back() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelAnalysis?()
        
        _ = self.navigationController?.popViewController(animated: true)
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
