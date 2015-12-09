import XCTest
@testable import ShopwaveConnect

class SWAPIEndpointTest: XCTestCase {

    func testRemoveNils() {
      let fullNilArray: [AnyObject?] = [nil, nil, nil, nil]
      let someNilArray: [String?] = [nil, "a", nil, "b", nil, nil, "c"]
      let noNilArray: [String?] = ["a", "b", "c"]

      XCTAssertEqual(SWAPIEndpoint.removeNils(fromArray: fullNilArray).count, 0)
      XCTAssertEqual(SWAPIEndpoint.removeNils(fromArray: someNilArray), ["a", "b", "c"])
      XCTAssertEqual(SWAPIEndpoint.removeNils(fromArray: noNilArray), ["a", "b", "c"])
    }

}
