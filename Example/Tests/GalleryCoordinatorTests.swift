//
//  GalleryCoordinatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

final class GalleryCoordinatorTests: XCTestCase {
    
    let galleryManager = GalleryManagerMock()
    let giniConfiguration: GiniConfiguration = GiniConfiguration.shared
    let selectedImageDocuments: [GiniImageDocument] = [
        GiniImageDocument(data: Data(count: 1), imageSource: .external),
        GiniImageDocument(data: Data(count: 2), imageSource: .external),
        GiniImageDocument(data: Data(count: 3), imageSource: .external)
    ]
    lazy var coordinator = GalleryCoordinator(galleryManager: self.galleryManager,
                                              giniConfiguration: GiniConfiguration.shared)
    
    var dummyImagePicker: ImagePickerViewController {
        return ImagePickerViewController(album: galleryManager.albums[0],
                                         galleryManager: galleryManager,
                                         giniConfiguration: GiniConfiguration.shared)
    }
    
    var dummyAlbumPicker: AlbumsPickerViewController {
        return AlbumsPickerViewController(galleryManager: galleryManager)
    }
    
    override func setUp() {
        super.setUp()
        giniConfiguration.multipageEnabled = true
        coordinator = GalleryCoordinator(galleryManager: self.galleryManager,
                                         giniConfiguration: giniConfiguration)
    }
    
    func testCloseGallery() {
        let delegate = GalleryCoordinatorDelegateMock()
        coordinator.delegate = delegate
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in
            _ = self.coordinator.cancelButton.target?.perform(self.coordinator.cancelButton.action)
            
            XCTAssertTrue(delegate.didCancelGallery,
                          "gallery image picking should be cancel after tapping cancel button")
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected image documents collection should be cleared after cancelling")
        }
    }
    
    func testOpenImages() {
        let delegate = GalleryCoordinatorDelegateMock()
        coordinator.delegate = delegate
        
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in
            self.selectImage(at: IndexPath(row: 1, section: 0), in: self.galleryManager.albums[2]) { _ in
                let innerButton = self.coordinator.openImagesButton.customView as? UIButton
                innerButton?.sendActions(for: .touchUpInside)
                
                let expect = self.expectation(for: NSPredicate(value: true),
                                              evaluatedWith: delegate.didOpenImages,
                                              handler: nil)
                self.wait(for: [expect], timeout: 1)
                XCTAssertTrue(delegate.didOpenImages,
                              "gallery images picked should be processed after tapping open images button")
                XCTAssertEqual(delegate.openedImageDocuments.count, 2,
                              "delegate opened image documents should be 2")
                XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                              "selected image documents collection should be empty after opening them")
            }
        }
    }
    
    func testNavigateBackToAlbumsTable() {
        coordinator.start()
        
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { _ in
            _ = self.coordinator.navigationController(self.coordinator.galleryNavigator,
                                                      animationControllerFor: .pop,
                                                      from: self.dummyImagePicker,
                                                      to: self.dummyAlbumPicker)
            XCTAssertFalse(self.galleryManager.isCaching,
                           "when going back to the album picker, caching should stop")
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected image documents collection should be cleared after going back")
        }
    }
    
    func testImagePickerDelegateDidSelect() {
        selectImage(at: IndexPath(row: 0, section: 0), in: galleryManager.albums[2]) { imagePicker in
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.openImagesButton,
                           "once that an image has been selected, the right bar button should be Open and not Cancel")
            XCTAssertFalse(self.coordinator.selectedImageDocuments.isEmpty,
                           "selected image documents should not be empty after selecting an image")
        }
    }
    
    func testImagePickerDelegateDidDeselect() {
        let album = galleryManager.albums[1]
        let deselectionIndex = IndexPath(row: 0, section: 0)
        selectImage(at: deselectionIndex, in: album) { imagePicker in
            self.coordinator.imagePicker(imagePicker,
                                         didDeselectAsset: album.assets[deselectionIndex.row],
                                         at: deselectionIndex)
            XCTAssertTrue(self.coordinator.selectedImageDocuments.isEmpty,
                          "selected documents array should be 0 after removing all selected items.")
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.cancelButton,
                           "once that an image has been selected, the right bar button should be Cancel and not Open")
        }
    }
    
    fileprivate func selectImage(at index: IndexPath,
                                 in album: Album,
                                 handler: @escaping ((ImagePickerViewController) -> Void)) {
        let imagePicker = ImagePickerViewController(album: album,
                                                    galleryManager: galleryManager,
                                                    giniConfiguration: GiniConfiguration.shared)
        coordinator.imagePicker(imagePicker,
                                didSelectAsset: album.assets[index.row],
                                at: index)

        handler(imagePicker)
    }
    
}
