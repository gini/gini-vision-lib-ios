//
//  AnalysisContainerViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini. All rights reserved.
//

import UIKit

internal class AnalysisContainerViewController: UIViewController, ContainerViewController {
    
    // Container attributes
    internal var containerView     = UIView()
    internal var contentController = UIViewController()
    
    // Resources
    fileprivate let backButtonResources = PreferredButtonResource(image: "navigationAnalysisBack", title: "ginivision.navigationbar.analysis.back", comment: "Button title in the navigation bar for the back button on the analysis screen", configEntry: GiniConfiguration.sharedConfiguration.navigationBarAnalysisTitleBackButton)
    
    // Properties
    fileprivate var noticeView: NoticeView?
    fileprivate var document: GiniVisionDocument
    
    init(document: GiniVisionDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller
        contentController = AnalysisViewController(document)
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        setupLeftNavigationItem(usingResources: backButtonResources, selector: #selector(back))
        
        // Configure view hierachy
        view.addSubview(containerView)
        
        // Add constraints
        addConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add content to container view
        displayContent(contentController)
        
        // Start loading animation
        (contentController as? AnalysisViewController)?.showAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didShowAnalysis?(self)
    }
    
    @IBAction func back() {
        let delegate = (navigationController as? GiniNavigationViewController)?.giniDelegate
        delegate?.didCancelAnalysis?()
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    fileprivate func showNotice(_ notice: NoticeView) {
        if noticeView != nil {
            noticeView?.hide(completion: {
                self.noticeView = nil
                self.showNotice(notice)
            })
        } else {
            noticeView = notice
            view.addSubview(noticeView!)
            noticeView?.show()
        }
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

extension AnalysisContainerViewController: AnalysisDelegate {
    
    func displayError(withMessage message: String?, andAction action: NoticeAction?) {
        let notice = NoticeView(text: message ?? "", noticeType: .error, action: action)
        DispatchQueue.main.async { 
            self.showNotice(notice)
        }
    }
    
    func displayNoResultsScreen(completion: ((_ shown: Bool) -> ())) {
        guard let giniNavController = self.navigationController as? GiniNavigationViewController else {
            completion(false)
            return
        }
        
        if document.type == .image {
            var filteredViewControllers = giniNavController.viewControllers.filter {
                !($0 is AnalysisContainerViewController) && !($0 is ReviewContainerViewController)
            }
            filteredViewControllers.append(imageAnalyisNoResults(within: giniNavController))
            giniNavController.setViewControllers(filteredViewControllers, animated: true)

            completion(true)
            return
        }
        completion(false)
    }
    
    fileprivate func imageAnalyisNoResults(within nav: UINavigationController) -> ImageAnalysisNoResultsContainerViewController {
        let isCameraViewControllerLoaded = nav.viewControllers.contains(where: { viewController in
            return viewController is CameraContainerViewController
        })
        
        if isCameraViewControllerLoaded {
            return ImageAnalysisNoResultsContainerViewController()
        } else {
            return ImageAnalysisNoResultsContainerViewController(canGoBack: false)
        }
    }
    
}
