@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWAuthTest: SWTestCase {

  func testFailsForNoClientId(){
    SWAuth.clientId = nil
    XCTFail()
  }

  func testFailsForNoClientSecret(){
    SWAuth.clientSecret = nil
    XCTFail()
  }

  func testFailsForNoCustomURL(){
    SWAuth.customURL = nil
    XCTFail()
  }

}
