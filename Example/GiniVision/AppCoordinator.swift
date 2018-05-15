//
//  AppCoordinator.swift
//  GiniVision_Example
//
//  Created by Enrique del Pozo Gómez on 11/10/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import Foundation
import UIKit
import GiniVision

final class AppCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    fileprivate let window: UIWindow
    fileprivate var screenAPIViewController: UIViewController?
    
    var rootViewController: UIViewController {
        return selectAPIViewController
    }
    lazy var selectAPIViewController: SelectAPIViewController = {
        let selectAPIViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "selectAPIViewController") as? SelectAPIViewController)!
        selectAPIViewController.delegate = self
        selectAPIViewController.clientId = self.client.clientId
        return selectAPIViewController
    }()
    
    lazy var giniConfiguration: GiniConfiguration = {
        let giniConfiguration = GiniConfiguration()
        giniConfiguration.debugModeOn = true
        giniConfiguration.fileImportSupportedTypes = .pdf_and_images
        giniConfiguration.openWithEnabled = true
        giniConfiguration.qrCodeScanningEnabled = true
        giniConfiguration.multipageEnabled = true
        giniConfiguration.navigationBarItemTintColor = UIColor.white
        giniConfiguration.customDocumentValidations = { document in
            // As an example of custom document validation, we add a more strict check for file size
            let maxFileSize = 5 * 1024 * 1024
            if document.data.count > maxFileSize {
                let error = CustomDocumentValidationError(message: "Diese Datei ist leider größer als 5MB")
                return CustomDocumentValidationResult.failure(withError: error)
            }
            return CustomDocumentValidationResult.success()
        }
        return giniConfiguration
    }()
    
    private lazy var client: GiniClient = CredentialsManager.fetchClientFromBundle()
    
    init(window: UIWindow) {
        self.window = window
        print("------------------------------------\n\n",
              "📸 Gini Vision Library for iOS (\(GiniVision.versionString))\n\n",
            "      - Client id:  \(client.clientId)\n",
            "      - Client email domain:  \(client.clientEmailDomain)",
            "\n\n------------------------------------\n")
    }
    
    func start() {
        self.showSelectAPIScreen()
    }
    
    func processExternalDocument(withUrl url: URL, sourceApplication: String?) {
        // 1. Read data imported from url
        let data = try? Data(contentsOf: url)
        
        // 2. Build the document
        let documentBuilder = GiniVisionDocumentBuilder(data: data, documentSource: .appName(name: sourceApplication))
        documentBuilder.importMethod = .openWith
        let document = documentBuilder.build()
        
        // When a document is imported with "Open with", a dialog allowing to choose between both APIs
        // is shown in the main screen. Therefore it needs to go to the main screen if it is not there yet.
        popToRootViewControllerIfNeeded()
        
        // 3. Validate document
        if let document = document {
            do {
                try GiniVision.validate(document,
                                        withConfig: self.giniConfiguration)
                showOpenWithSwitchDialog(forDocuments: [DocumentRequest(value: document, error: nil)])
            } catch {
                showExternalDocumentNotValidDialog()
            }
        }
    }
    
    fileprivate func showSelectAPIScreen() {
        self.window.rootViewController = rootViewController
        self.window.makeKeyAndVisible()
    }
    
    fileprivate func showScreenAPI(withImportedDocuments documents: [DocumentRequest]? = nil) {
        let screenAPICoordinator = ScreenAPICoordinator(configuration: giniConfiguration,
                                                        importedDocuments: documents?.map { $0.document },
                                                        client: client)
        screenAPICoordinator.delegate = self
        screenAPICoordinator.start()
        add(childCoordinator: screenAPICoordinator)
        
        rootViewController.present(screenAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    fileprivate func showComponentAPI(withImportedDocument documents: [DocumentRequest]? = nil) {
        let componentAPICoordinator = ComponentAPICoordinator(documentRequests: documents ?? [],
                                                              configuration: giniConfiguration,
                                                              client: client)
        componentAPICoordinator.delegate = self
        componentAPICoordinator.start()
        add(childCoordinator: componentAPICoordinator)
        
        rootViewController.present(componentAPICoordinator.rootViewController, animated: true, completion: nil)
    }
    
    fileprivate func showSettings() {
        let settingsViewController = (UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "settingsViewController") as? SettingsViewController)!
        settingsViewController.delegate = self
        settingsViewController.giniConfiguration = giniConfiguration
        settingsViewController.modalPresentationStyle = .overFullScreen
        settingsViewController.modalTransitionStyle = .crossDissolve
        
        rootViewController.present(settingsViewController, animated: true, completion: nil)
    }
    
    fileprivate func showOpenWithSwitchDialog(forDocuments documents: [DocumentRequest]) {
        let alertViewController = UIAlertController(title: "Importierte Datei",
                                                    message: "Möchten Sie die importierte Datei mit dem " +
            "ScreenAPI oder ComponentAPI verwenden?",
                                                    preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Screen API", style: .default) {[weak self] _ in
            self?.showScreenAPI(withImportedDocuments: documents)
        })        
        alertViewController.addAction(UIAlertAction(title: "Component API", style: .default) { [weak self] _ in
            self?.showComponentAPI(withImportedDocument: documents)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func showExternalDocumentNotValidDialog() {
        let alertViewController = UIAlertController(title: "Ungültiges Dokument",
                                                    message: "Dies ist kein gültiges Dokument",
                                                    preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            alertViewController.dismiss(animated: true, completion: nil)
        })
        
        rootViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    fileprivate func popToRootViewControllerIfNeeded() {
        self.childCoordinators.forEach { coordinator in
            coordinator.rootViewController.dismiss(animated: true, completion: nil)
            self.remove(childCoordinator: coordinator)
        }
    }
}

// MARK: SelectAPIViewControllerDelegate

extension AppCoordinator: SelectAPIViewControllerDelegate {
    
    func selectAPI(viewController: SelectAPIViewController, didSelectApi api: GiniVisionAPIType) {
        switch api {
        case .screen:
            showScreenAPI()
        case .component:
            showComponentAPI()
        }
    }
    
    func selectAPI(viewController: SelectAPIViewController, didTapSettings: ()) {
        showSettings()
    }
}

extension AppCoordinator: SettingsViewControllerDelegate {
    func settings(settingViewController: SettingsViewController,
                  didChangeConfiguration configuration: GiniConfiguration) {
        giniConfiguration = configuration
    }
}

// MARK: ScreenAPICoordinatorDelegate

extension AppCoordinator: ScreenAPICoordinatorDelegate {
    func screenAPI(coordinator: ScreenAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator)
    }
}

// MARK: ComponentAPICoordinatorDelegate

extension AppCoordinator: ComponentAPICoordinatorDelegate {
    func componentAPI(coordinator: ComponentAPICoordinator, didFinish: ()) {
        coordinator.rootViewController.dismiss(animated: true, completion: nil)
        self.remove(childCoordinator: coordinator)
    }
}
