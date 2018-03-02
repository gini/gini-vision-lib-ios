//
//  GalleryCoordinatorTests.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 3/2/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import XCTest
@testable import GiniVision

class GalleryCoordinatorTests: XCTestCase {
    
    let galleryManager = GalleryManagerMock()
    let selectedImageDocuments: [GiniImageDocument] = [
        GiniImageDocument(data: Data(count: 1), imageSource: .external),
        GiniImageDocument(data: Data(count: 2), imageSource: .external),
        GiniImageDocument(data: Data(count: 3), imageSource: .external)
    ]
    lazy var coordinator = GalleryCoordinator(galleryManager: self.galleryManager,
                                              giniConfiguration: GiniConfiguration.sharedConfiguration)
    
    var dummyImagePicker: ImagePickerViewController {
        return ImagePickerViewController(album: galleryManager.albums[0],
                                         galleryManager: galleryManager,
                                         giniConfiguration: GiniConfiguration.sharedConfiguration)
    }
    
    var dummyAlbumPicker: AlbumsPickerViewController {
        return AlbumsPickerViewController(galleryManager: galleryManager)
    }
    
    override func setUp() {
        super.setUp()
        coordinator = GalleryCoordinator(galleryManager: self.galleryManager,
                                         giniConfiguration: GiniConfiguration.sharedConfiguration)
    }
    
    func testGalleryCoordinatorStart() {
        coordinator.start()
        
        XCTAssertTrue(galleryManager.isCaching, "gallery manager should have started caching")
        XCTAssertEqual(coordinator.galleryNavigator.viewControllers.count, 2,
                       "there should be 2 view controller in the navigator when the gallery coordinator starts")
    }
    
    func testCloseGallery() {
        let delegate = GalleryCoordinatorDelegateMock()
        coordinator.delegate = delegate
        selectImage(at: 0, in: galleryManager.albums[2]) { _ in
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
        
        selectImage(at: 0, in: galleryManager.albums[2]) { _ in
            self.selectImage(at: 1, in: self.galleryManager.albums[2]) { _ in
                let innerButton = self.coordinator.openImagesButton.customView as? UIButton
                innerButton?.sendActions(for: .touchUpInside)
                
                XCTAssertTrue(delegate.didOpenImages,
                              "gallery images picked should be processed after tapping open images button")
                XCTAssertTrue(delegate.openedImageDocuments.count == 2,
                              "selected image documents collection should be empty after opening them")
            }
        }
    }
    
    func testNavigateBackToAlbumsTable() {
        coordinator.start()
        
        selectImage(at: 0, in: galleryManager.albums[2]) { _ in
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
    
    func testAlbumPickerDelegateDidSelect() {
        coordinator.albumsPicker(dummyAlbumPicker, didSelectAlbum: galleryManager.albums[0])
        _ = expectation(for: NSPredicate(format: "count = 2"),
                        evaluatedWith: coordinator.galleryNavigator.viewControllers, handler: nil)
        waitForExpectations(timeout: 10) { _ in
            XCTAssertEqual(self.coordinator.galleryNavigator.viewControllers.count, 2,
                           "when selecting an album an image picker should be loaded")
        }
        
    }
    
    func testImagePickerDelegateDidSelect() {
        selectImage(at: 0, in: galleryManager.albums[2]) { imagePicker in
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.openImagesButton,
                           "Once that an image has been selected, the right bar button should be Open and not Cancel")
            XCTAssertFalse(self.coordinator.selectedImageDocuments.isEmpty,
                           "selected image documents should not be empty after selecting an image")
        }
    }
    
    func testImagePickerDelegateDidDeselect() {
        let album = galleryManager.albums[1]
        let deselectionIndex = 0
        selectImage(at: deselectionIndex, in: album) { imagePicker in
            self.coordinator.imagePicker(imagePicker,
                                         didDeselectAssetAt: IndexPath(row: deselectionIndex, section:0),
                                         in: album)
            XCTAssertEqual(imagePicker.navigationItem.rightBarButtonItem,
                           self.coordinator.cancelButton,
                           "Once that an image has been selected, the right bar button should be Cancel and not Open")
        }
    }
    
    fileprivate func selectImage(at index: Int, in album: Album, handler: @escaping ((ImagePickerViewController) -> Void)) {
        let imagePicker = ImagePickerViewController(album: album,
                                                    galleryManager: galleryManager,
                                                    giniConfiguration: GiniConfiguration.sharedConfiguration)
        coordinator.imagePicker(imagePicker, didSelectAssetAt: IndexPath(row: index, section: 0), in: album)
        
        _ = expectation(for: NSPredicate(format: "count != 0"),
                        evaluatedWith: coordinator.selectedImageDocuments, handler: nil)
        waitForExpectations(timeout: 1) { _ in
            handler(imagePicker)
        }
    }
    
}
