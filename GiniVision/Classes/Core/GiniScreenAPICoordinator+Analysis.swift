//
//  GiniScreenAPICoordinator+Analysis.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 4/4/18.
//

import Foundation

// MARK: - Analysis Screen

internal extension GiniScreenAPICoordinator {
    func createAnalysisScreen(withDocument document: GiniVisionDocument) -> AnalysisViewController {
        let viewController = AnalysisViewController(document: document)
        viewController.view.backgroundColor = giniConfiguration.backgroundColor
        viewController.didShowAnalysis = { [weak self] in
            guard let `self` = self else { return }
            self.visionDelegate?.didShowAnalysis?(self)
        }
        viewController.setupNavigationItem(usingResources: self.cancelButtonResource,
                                           selector: #selector(back),
                                           position: .left,
                                           target: self)
        return viewController
    }
}

// MARK: - ImageAnalysisNoResults screen

extension GiniScreenAPICoordinator {
    func createImageAnalysisNoResultsScreen() -> ImageAnalysisNoResultsViewController {
        let imageAnalysisNoResultsViewController: ImageAnalysisNoResultsViewController
        let isCameraViewControllerLoaded: Bool = {
            guard let cameraViewController = cameraViewController else {
                return false
            }
            return screenAPINavigationController.viewControllers.contains(cameraViewController)
        }()
        
        if isCameraViewControllerLoaded {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController()
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: backButtonResource,
                                                                     selector: #selector(backToCamera),
                                                                     position: .left,
                                                                     target: self)
        } else {
            imageAnalysisNoResultsViewController = ImageAnalysisNoResultsViewController(bottomButtonText: nil,
                                                                                        bottomButtonIcon: nil)
            imageAnalysisNoResultsViewController.setupNavigationItem(usingResources: closeButtonResource,
                                                                     selector: #selector(closeScreenApi),
                                                                     position: .left,
                                                                     target: self)
        }
        
        imageAnalysisNoResultsViewController.didTapBottomButton = { [weak self] in
            self?.backToCamera()
        }
        
        return imageAnalysisNoResultsViewController
    }
}

// MARK: - AnalysisDelegate

extension GiniScreenAPICoordinator: AnalysisDelegate {
    func displayError(withMessage message: String?, andAction action: (() -> Void)?) {
        DispatchQueue.main.async {
            var noticeAction: NoticeAction?
            if let action = action {
                noticeAction = NoticeAction(title: NSLocalizedString("ginivision.analysis.error.actionTitle",
                                                                     bundle: Bundle(for: GiniVision.self),
                                                                     comment: "Action button title"),
                                            action: action)
            }
            let notice = NoticeView(text: message ?? "", type: .error, noticeAction: noticeAction)
            self.show(notice: notice)
        }
    }
    
    func tryDisplayNoResultsScreen() -> Bool {
        if let visionDocument = documentRequests.first?.document, visionDocument.type == .image {
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.imageAnalysisNoResultsViewController = self.createImageAnalysisNoResultsScreen()
                self.screenAPINavigationController.pushViewController(self.imageAnalysisNoResultsViewController!,
                                                                      animated: true)
            }
            
            return true
        }
        return false
    }
    
    private func show(notice: NoticeView) {
        let noticeView = analysisViewController?.view.subviews.compactMap { $0 as? NoticeView }.first
        if let noticeView = noticeView {
            noticeView.hide(completion: { [weak self] in
                self?.show(notice: notice)
            })
        } else {
            guard let analysisView = analysisViewController?.view else { return }

            analysisView.addSubview(notice)
            Constraints.pin(view: notice, toSuperView: analysisView, positions: [.top, .left, .right])
            notice.show()
        }
    }
}
