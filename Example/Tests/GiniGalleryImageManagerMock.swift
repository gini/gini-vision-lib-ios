//
//  GiniGalleryImageManagerMock.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class GiniGalleryImageManagerMock: GalleryImageManagerProtocol {
    var numberOfItems: Int = 3
    
    func fetchImage(at indexPath: IndexPath, completion: @escaping ((UIImage) -> Void)) {
        
    }
}
