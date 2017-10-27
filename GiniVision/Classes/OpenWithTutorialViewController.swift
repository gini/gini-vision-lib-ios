//
//  OpenWithTutorialViewController.swift
//  GiniVision
//
//  Created by Enrique del Pozo Gómez on 10/20/17.
//  Copyright © 2017 Gini GmbH. All rights reserved.
//

import UIKit

typealias OpenWithTutorialStep = (title: String, subtitle: String, image: UIImage?)

final class OpenWithTutorialViewController: UICollectionViewController {
    let openWithTutorialCollectionCellIdentifier = "openWithTutorialCollectionCellIdentifier"
    let openWithTutorialCollectionHeaderIdentifier = "openWithTutorialCollectionHeaderIdentifier"
    
    var appName:String {
        return GiniConfiguration.sharedConfiguration.openWithAppNameForTexts
    }
    
    lazy var items: [OpenWithTutorialStep] = [
        (NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step1.title", comment: "first step title for open with tutorial"),
         NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step1.subTitle", comment: "first step subtitle for open with tutorial"),
         UIImageNamedPreferred(named: "openWithTutorialStep1")),
        (NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step2.title", comment: "second step title for open with tutorial"),
         String(format: NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step2.subTitle", comment: "second step subtitle for open with tutorial"), self.appName, self.appName),
            UIImageNamedPreferred(named: "openWithTutorialStep2")),
        (NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step3.title", comment: "third step title for open with tutorial"),
         String(format: NSLocalizedStringPreferred("ginivision.help.openWithTutorial.step3.subTitle", comment: "third step subtitle for open with tutorial"), self.appName, self.appName, self.appName),
            UIImageNamedPreferred(named: "openWithTutorialStep3"))
    ]
    
    lazy var headerTitle: String = {
        let localizedString = NSLocalizedStringPreferred("ginivision.help.openWithTutorial.collectionHeader", comment: "intoduction header for further steps")
        return String(format: localizedString, self.appName)
    }()
    
    fileprivate var stepsCollectionLayout: OpenWithTutorialCollectionFlowLayout {
        return self.collectionView?.collectionViewLayout as! OpenWithTutorialCollectionFlowLayout
    }
    
    init() {
        super.init(collectionViewLayout: OpenWithTutorialCollectionFlowLayout())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init() should be called instead")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("ginivision.help.openWithTutorial.title", bundle: Bundle(for: GiniVision.self), comment: "title shown when the view controller is within a view controller")
        self.view.backgroundColor = Colors.Gini.pearl
        self.collectionView!.backgroundColor = nil
        self.edgesForExtendedLayout = []
        self.automaticallyAdjustsScrollViewInsets = false

        self.collectionView!.register(OpenWithTutorialCollectionCell.self, forCellWithReuseIdentifier: openWithTutorialCollectionCellIdentifier)
        self.collectionView!.register(OpenWithTutorialCollectionHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: openWithTutorialCollectionHeaderIdentifier)
        
        stepsCollectionLayout.minimumLineSpacing = 1
        stepsCollectionLayout.minimumInteritemSpacing = 1
        stepsCollectionLayout.estimatedItemSize = estimatedCellSize(widthParentSize: view.frame.size)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [unowned self] _ in
            self.stepsCollectionLayout.estimatedItemSize = self.estimatedCellSize(widthParentSize: size)
            self.collectionView?.collectionViewLayout.invalidateLayout()
        })
    }
    
    private func estimatedCellSize(widthParentSize size: CGSize) -> CGSize {
        if size.width > size.height && UIDevice.current.isIpad {
            let width:CGFloat = round(UIScreen.main.bounds.width / CGFloat(self.items.count) - CGFloat(self.stepsCollectionLayout.minimumInteritemSpacing * CGFloat(self.items.count - 1)))
            return CGSize(width: width, height: size.height)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 550)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: openWithTutorialCollectionCellIdentifier, for: indexPath) as! OpenWithTutorialCollectionCell
        cell.fillWith(item: items[indexPath.row], at: indexPath.row)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: openWithTutorialCollectionHeaderIdentifier, for: indexPath) as! OpenWithTutorialCollectionHeader
        header.headerTitle.text = headerTitle
        return header
    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension OpenWithTutorialViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height: CGFloat = collectionView.frame.width > collectionView.frame.height ? 0 : 130
        
        return CGSize(width: UIScreen.main.bounds.width, height: height)
    }
}
