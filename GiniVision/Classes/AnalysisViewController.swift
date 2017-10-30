//
//  AnalysisViewController.swift
//  GiniVision
//
//  Created by Peter Pult on 21/06/16.
//  Copyright © 2016 Gini GmbH. All rights reserved.
//

import UIKit

/**
 Delegate which can be used to communicate back to the analysis screen allowing to display custom messages on screen.
 
 - note: Screen API only.
 */
@objc public protocol AnalysisDelegate {
    
    /**
     Will display an error view on the analysis screen with a custom message.
     The provided action will be called, when the user taps on the error view.
     
     - parameter message: The error message to be displayed.
     - parameter action:  The action to be performed after the user tapped the error view.
     */
    func displayError(withMessage message: String?, andAction action: NoticeAction?)
    
    /**
     In case that the `GiniVisionDocument` analysed is an image it will display a no results screen
     with some capture suggestions. It won't show any screen if it is not an image, return `false` in that case.
     
     - returns: `true` if the screen was shown or `false` if it wasn't.
     */
    func tryDisplayNoResultsScreen() -> Bool
}

/**
 The `AnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity. The user should have the option of canceling the process by navigating back to the review screen.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.analysis.back` (Screen API only.)
 
 - note: Setting `ginivision.navigationbar.analysis.back` explicitly to the empty string in your localized strings will make `AnalysisViewController` revert to the default iOS back button.
 
 **Image resources for this screen**
 
 * `navigationAnalysisBack` (Screen API only.)
 
 Resources listed also contain resources for the container view controller. These are marked with _Screen API only_.
 
 - note: Component API only.
 */
@objc public final class AnalysisViewController: UIViewController {
    
    // User interface
    fileprivate var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    fileprivate var loadingIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        return indicatorView
    }()
    fileprivate var loadingIndicatorText:UILabel = {
        var loadingText = UILabel()
        loadingText.text = GiniConfiguration.sharedConfiguration.analysisLoadingText
        loadingText.font = GiniConfiguration.sharedConfiguration.font.regular.withSize(18)
        loadingText.textAlignment = .center
        loadingText.textColor = .white
        return loadingText
    }()
    fileprivate static let loadingIndicatorContainerHeight: CGFloat = 60
    fileprivate lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect(origin: .zero, size: CGSize(width: loadingIndicatorContainerHeight, height: loadingIndicatorContainerHeight)))
        loadingIndicatorContainer.backgroundColor = .white
        loadingIndicatorContainer.layer.cornerRadius = loadingIndicatorContainerHeight / 2
        loadingIndicatorContainer.layer.shadowOffset = CGSize(width: 0, height: 0)
        loadingIndicatorContainer.layer.shadowRadius = 0.8
        loadingIndicatorContainer.layer.shadowOpacity = 0.2
        loadingIndicatorContainer.layer.shadowColor = UIColor.black.cgColor
        return loadingIndicatorContainer
    }()
    fileprivate lazy var overlayView: UIView = {
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        return overlayView
    }()
    
    fileprivate let document:GiniVisionDocument
    
    /**
     Designated intitializer for the `AnalysisViewController`.
     
     - parameter document: Reviewed document ready for analysis.
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(_ document: GiniVisionDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     Convenience intitializer for the `AnalysisViewController`.
     
     - parameter imageData:  Reviewed image ready for analysis
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    
    @nonobjc
    @available(*, deprecated)
    public convenience init(_ imageData:Data) {
        self.init(GiniImageDocument(data: imageData, imageSource: .external))
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - warning: Not implemented.
     */
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        super.loadView()
        self.imageView.image = self.document.previewImage
        
        // Configure view hierachy
        addImageView()
        
        if let document = document as? GiniPDFDocument {
            addLoadingView(intoContainer: loadingIndicatorContainer)
            loadingIndicatorView.color = GiniConfiguration.sharedConfiguration.analysisLoadingIndicatorColor
            
            showPDFInformationView(withDocument:document)
        } else {
            addLoadingView()
            addLoadingText(below: loadingIndicatorView)
            addOverlay()
            
            showCaptureSuggestions()
        }
    }
    
    // MARK: Toggle animation
    /**
     Displays a loading activity indicator. Should be called when document analysis is started.
     
     - note: To change the color of the loading animation use `analysisLoadingIndicatorColor` on the `GiniConfiguration` class.
     */
    public func showAnimation() {
        loadingIndicatorView.startAnimating()
    }
    
    /**
     Hides the loading activity indicator. Should be called when document analysis is finished.
     */
    public func hideAnimation() {
        loadingIndicatorView.stopAnimating()
    }
    
    fileprivate func addImageView() {
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0, priority: 999)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
    }
    
    fileprivate func addOverlay() {
        self.view.insertSubview(overlayView, aboveSubview: imageView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: overlayView, attribute: .top, relatedBy: .equal, toItem: imageView, attribute: .top, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: overlayView, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: overlayView, attribute: .bottom, relatedBy: .equal, toItem: imageView, attribute: .bottom, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: overlayView, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .leading, multiplier: 1, constant: 0)
    }
    
    fileprivate func addLoadingText(below:UIView) {
        self.view.addSubview(loadingIndicatorText)
        loadingIndicatorText.translatesAutoresizingMaskIntoConstraints = false
        
        ConstraintUtils.addActiveConstraint(item: loadingIndicatorText, attribute: .trailing, relatedBy: .equal, toItem: imageView, attribute: .trailing, multiplier: 1, constant: 0)
        ConstraintUtils.addActiveConstraint(item: loadingIndicatorText, attribute: .top, relatedBy: .equal, toItem: below, attribute: .bottom, multiplier: 1, constant: 16)
        ConstraintUtils.addActiveConstraint(item: loadingIndicatorText, attribute: .leading, relatedBy: .equal, toItem: imageView, attribute: .leading, multiplier: 1, constant: 0)
    }
    
    fileprivate func addLoadingView(intoContainer container: UIView? = nil) {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(container)
            container.addSubview(loadingIndicatorView)
            
            ConstraintUtils.addActiveConstraint(item: container, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: container, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: container, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: AnalysisViewController.loadingIndicatorContainerHeight)
            ConstraintUtils.addActiveConstraint(item: container, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: AnalysisViewController.loadingIndicatorContainerHeight)
            ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 1.5)
            ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 1.5)
            
        } else {
            self.view.addSubview(loadingIndicatorView)
            ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            ConstraintUtils.addActiveConstraint(item: loadingIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        }
    }
    
    fileprivate func showPDFInformationView(withDocument document:GiniPDFDocument) {
        let pdfInformationView = PDFInformationView(title: document.pdfTitle ?? "PDF Dokument",
                                                    subtitle: GiniConfiguration.sharedConfiguration.analysisPDFNumberOfPages(pagesCount: document.numberPages),
                                                    textColor: GiniConfiguration.sharedConfiguration.analysisPDFInformationTextColor,
                                                    textFont: GiniConfiguration.sharedConfiguration.font.regular.withSize(16),
                                                    backgroundColor: GiniConfiguration.sharedConfiguration.analysisPDFInformationBackgroundColor,
                                                    superView: self.view,
                                                    viewBelow: self.imageView)
        
        pdfInformationView.show()
    }
    
    fileprivate func showCaptureSuggestions() {
        let captureSuggestions = CaptureSuggestionsView(superView: self.view,
                                                        font:GiniConfiguration.sharedConfiguration.font.regular.withSize(14))
        captureSuggestions.start()
    }
}
