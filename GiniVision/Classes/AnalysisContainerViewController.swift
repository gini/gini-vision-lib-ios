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
    
    // User interface
    fileprivate var backButton = UIBarButtonItem()
    
    // Resources
    fileprivate let backButtonResources = PreferredResource(image: "navigationAnalysisBack", title: "ginivision.navigationbar.analysis.back", comment: "Button title in the navigation bar for the back button on the analysis screen")
    
    // Properties
    fileprivate var noticeView: NoticeView?
    
    init(imageData: Data) {
        super.init(nibName: nil, bundle: nil)
        
        // Configure content controller
        contentController = AnalysisViewController(imageData)
        
        // Configure title
        title = GiniConfiguration.sharedConfiguration.navigationBarAnalysisTitle
        
        // Configure colors
        view.backgroundColor = GiniConfiguration.sharedConfiguration.backgroundColor
        
        // Configure close button
        backButton = GiniBarButtonItem(
            image: backButtonResources.preferredImage,
            title: backButtonResources.preferredText,
            style: .plain,
            target: self,
            action: #selector(back)
        )
        
        // Configure view hierachy
        view.addSubview(containerView)
        navigationItem.setLeftBarButton(backButton, animated: false)
        
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
    
}
