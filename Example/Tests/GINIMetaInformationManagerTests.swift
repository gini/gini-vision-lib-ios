import XCTest
@testable import GiniVision
import ImageIO

class ImageMetaInformationManagerTests: XCTestCase {
    
    var invoiceData: Data {
        let path = Bundle.main.url(forResource: "invoice", withExtension: "jpg")
        return (try! Data(contentsOf: path!))
    }
    var manager: ImageMetaInformationManager {
        return ImageMetaInformationManager(imageData: invoiceData)
    }
    
    func testInitialization() {
        XCTAssertNotNil(manager.image, "image should not be nil")
        XCTAssertNotNil(manager.metaInformation, "meta information should not be nil")
    }
    
    func testGettingMetaInformation() {
        guard let information = manager.metaInformation else {
            return XCTFail("meta information should not be nil")
        }
        guard let exif = information[kCGImagePropertyExifDictionary as String] as? NSDictionary else {
            return XCTFail("exif information should not be nil")
        }
        let exposureTime = exif[kCGImagePropertyExifExposureTime as String]
        XCTAssert(exposureTime as? Double == 1/33, "exposure time should be set and equal to \"1/33\"")
    }
    
    func testSettingMetaInformation() {
        guard let mutableInformation = manager.metaInformation?.mutableCopy() as? NSMutableDictionary else {
            return XCTFail("failed to retrieve mutable meta information from test data")
        }
        let value = "MyCompany"
        let key = kCGImagePropertyTIFFMake as String
        mutableInformation.set(metaInformation: value as AnyObject?, forKey: key)
        XCTAssert(mutableInformation.getMetaInformation(forKey: key) as? String == value, "failed to set value correctly on meta information")
    }
    
    func testFilteringAndSettingRequiredFields() {
        var mutableManager = manager
        mutableManager.filterMetaInformation()
        guard let filteredData = mutableManager.imageData() else {
            return XCTFail("filtered image data should not be nil")
        }
        
        let filteredManager = ImageMetaInformationManager(imageData: filteredData)
        XCTAssertNotNil(filteredManager.image, "image should not be nil")
        XCTAssertNotNil(filteredManager.metaInformation, "meta information should not be nil")
        guard let mutableInformation = filteredManager.metaInformation?.mutableCopy() as? NSMutableDictionary else {
            return XCTFail("failed to retrieve mutable meta information from filtered image data")
        }
        let key = kCGImagePropertyExifUserComment as String
        XCTAssert((mutableInformation.getMetaInformation(forKey: key) as? String)?.contains("GiniVisionVer") == true, "filtered data did not set custom fields")
    }
    
}
