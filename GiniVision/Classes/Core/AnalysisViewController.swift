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
    func displayError(withMessage message: String?, andAction action: (() -> Void)?)
    
    /**
     In case that the `GiniVisionDocument` analysed is an image it will display a no results screen
     with some capture suggestions. It won't show any screen if it is not an image, return `false` in that case.
     
     - returns: `true` if the screen was shown or `false` if it wasn't.
     */
    func tryDisplayNoResultsScreen() -> Bool
}

/**
 The `AnalysisViewController` provides a custom analysis screen which shows the upload and analysis activity.
 The user should have the option of canceling the process by navigating back to the review screen.
 
 **Text resources for this screen**
 
 * `ginivision.navigationbar.analysis.back` (Screen API only.)
 
 - note: Setting `ginivision.navigationbar.analysis.back` explicitly to the empty string in your
 localized strings will make `AnalysisViewController` revert to the default iOS back button.
 
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
        indicatorView.startAnimating()
        return indicatorView
    }()
    fileprivate var loadingIndicatorText: UILabel = {
        var loadingText = UILabel()
        loadingText.text = GiniConfiguration.shared.analysisLoadingText
        loadingText.font = GiniConfiguration.shared.customFont.regular.withSize(18)
        loadingText.textAlignment = .center
        loadingText.textColor = .white
        return loadingText
    }()
    fileprivate static let loadingIndicatorContainerHeight: CGFloat = 60
    fileprivate lazy var loadingIndicatorContainer: UIView = {
        let loadingIndicatorContainer = UIView(frame: CGRect(origin: .zero,
                                                             size: CGSize(width: AnalysisViewController.loadingIndicatorContainerHeight,
                                                                          height: AnalysisViewController.loadingIndicatorContainerHeight)))
        loadingIndicatorContainer.backgroundColor = .white
        loadingIndicatorContainer.layer.cornerRadius = AnalysisViewController.loadingIndicatorContainerHeight / 2
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
    
    fileprivate let document: GiniVisionDocument
    var didShowAnalysis: (() -> Void)?
    
    /**
     Designated intitializer for the `AnalysisViewController`.
     
     - parameter document: Reviewed document ready for analysis.
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    public init(document: GiniVisionDocument) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }
    
    /**
     Convenience intitializer for the `AnalysisViewController`.
     
     - parameter imageData:  Reviewed image ready for analysis
     
     - returns: A view controller instance giving the user a nice user interface while waiting for the analysis results.
     */
    
    @available(*, deprecated)
    public convenience init(_ imageData: Data) {
        self.init(document: GiniImageDocument(data: imageData, imageSource: .external))
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
        imageView.image = document.previewImage
        edgesForExtendedLayout = []
        view.backgroundColor = .black
        
        // Configure view hierachy
        addImageView()
        
        if let document = document as? GiniPDFDocument {
            addLoadingView(intoContainer: loadingIndicatorContainer)
            loadingIndicatorView.color = GiniConfiguration.shared.analysisLoadingIndicatorColor
            
            showPDFInformationView(withDocument: document,
                                   giniConfiguration: GiniConfiguration.shared)
        } else {
            addLoadingView()
            addLoadingText(below: loadingIndicatorView)
            addOverlay()
            
            if document.type == .image {
                showCaptureSuggestions(giniConfiguration: GiniConfiguration.shared)
            }
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didShowAnalysis?()
    }
    
    // MARK: Toggle animation
    /**
     Displays a loading activity indicator. Should be called when document analysis is started.
     
     - note: To change the color of the loading animation use `analysisLoadingIndicatorColor`
     on the `GiniConfiguration` class.
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
        
        Constraints.active(item: imageView, attr: .top, relatedBy: .equal, to: self.topLayoutGuide, attr: .bottom,
                          priority: 999)
        Constraints.active(item: imageView, attr: .bottom, relatedBy: .equal, to: self.bottomLayoutGuide, attr: .top,
                          priority: 999)
        Constraints.active(item: imageView, attr: .trailing, relatedBy: .equal, to: self.view, attr: .trailing)
        Constraints.active(item: imageView, attr: .leading, relatedBy: .equal, to: self.view, attr: .leading)
    }
    
    fileprivate func addOverlay() {
        self.view.insertSubview(overlayView, aboveSubview: imageView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: overlayView, attr: .top, relatedBy: .equal, to: imageView, attr: .top)
        Constraints.active(item: overlayView, attr: .trailing, relatedBy: .equal, to: imageView, attr: .trailing)
        Constraints.active(item: overlayView, attr: .bottom, relatedBy: .equal, to: imageView, attr: .bottom)
        Constraints.active(item: overlayView, attr: .leading, relatedBy: .equal, to: imageView, attr: .leading)
    }
    
    fileprivate func addLoadingText(below: UIView) {
        self.view.addSubview(loadingIndicatorText)
        loadingIndicatorText.translatesAutoresizingMaskIntoConstraints = false
        
        Constraints.active(item: loadingIndicatorText, attr: .trailing, relatedBy: .equal, to: imageView,
                          attr: .trailing)
        Constraints.active(item: loadingIndicatorText, attr: .top, relatedBy: .equal, to: below, attr: .bottom,
                          constant: 16)
        Constraints.active(item: loadingIndicatorText, attr: .leading, relatedBy: .equal, to: imageView, attr: .leading)
    }
    
    fileprivate func addLoadingView(intoContainer container: UIView? = nil) {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        if let container = container {
            container.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(container)
            container.addSubview(loadingIndicatorView)
            
            Constraints.active(item: container, attr: .centerX, relatedBy: .equal, to: self.view, attr: .centerX)
            Constraints.active(item: container, attr: .centerY, relatedBy: .equal, to: self.view, attr: .centerY)
            Constraints.active(item: container, attr: .height, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: AnalysisViewController.loadingIndicatorContainerHeight)
            Constraints.active(item: container, attr: .width, relatedBy: .equal, to: nil, attr: .notAnAttribute,
                              constant: AnalysisViewController.loadingIndicatorContainerHeight)
            Constraints.active(item: loadingIndicatorView, attr: .centerX, relatedBy: .equal, to: container,
                              attr: .centerX, constant: 1.5)
            Constraints.active(item: loadingIndicatorView, attr: .centerY, relatedBy: .equal, to: container,
                              attr: .centerY, constant: 1.5)
            
        } else {
            self.view.addSubview(loadingIndicatorView)
            Constraints.active(item: loadingIndicatorView, attr: .centerX, relatedBy: .equal, to: self.view,
                              attr: .centerX)
            Constraints.active(item: loadingIndicatorView, attr: .centerY, relatedBy: .equal, to: self.view,
                              attr: .centerY)
        }
    }
    fileprivate func showPDFInformationView(withDocument document: GiniPDFDocument,
                                            giniConfiguration: GiniConfiguration) {
        let pdfView = PDFInformationView(title: document.pdfTitle ?? "PDF Dokument",
                                         subtitle: giniConfiguration
                                            .analysisPDFNumberOfPages(pagesCount: document.numberPages),
                                         textColor: giniConfiguration.analysisPDFInformationTextColor,
                                         textFont: giniConfiguration.customFont.regular.withSize(16),
                                         backgroundColor: giniConfiguration.analysisPDFInformationBackgroundColor,
                                         superView: self.view,
                                         viewBelow: self.imageView)
        
        pdfView.show()
    }
    
    fileprivate func showCaptureSuggestions(giniConfiguration: GiniConfiguration) {
        let captureSuggestions = CaptureSuggestionsView(superView: self.view,
                                                        bottomLayout: bottomLayoutGuide,
                                                        font: giniConfiguration.customFont.regular.withSize(14))
        captureSuggestions.start()
    }
}
