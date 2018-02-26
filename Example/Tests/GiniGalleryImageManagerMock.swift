//
//  GiniGalleryImageManagerMock.swift
//  GiniVision_Tests
//
//  Created by Enrique del Pozo Gómez on 2/26/18.
//  Copyright © 2018 Gini GmbH. All rights reserved.
//

import Foundation
@testable import GiniVision

final class GiniGalleryImageManagerMock: GiniGalleryImageManagerProtocol {
    func numberOfItems() -> Int {
        return 3
    }
}
