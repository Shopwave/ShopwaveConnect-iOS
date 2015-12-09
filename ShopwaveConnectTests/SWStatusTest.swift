@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWStatusTest: SWTestCase {

  func testNormalResponse() {
    let df = NSDateFormatter()
    df.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"

    stubGET()
    SWStatus.getStatus { (available, serverTimestamp, errors) -> Void in
      XCTAssertTrue(available)
      XCTAssertEqual(serverTimestamp, df.dateFromString("Wed, 18 Nov 2015 15:13:38 GMT"))
      XCTAssertNil(errors)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testServerUnavailable() {
    stubServer500()
    SWStatus.getStatus {(available, serverTimestamp, errors) -> Void in
      XCTAssertFalse(available)
      XCTAssertNil(serverTimestamp)
      XCTAssertNotNil(errors)
      XCTAssertTrue(errors!.contains({ (error) -> Bool in
        if let error = error as? SWAPIEndpoint.Error {
          return error._code == SWAPIEndpoint.Error.ServiceDown(details: nil)._code
        } else {
          return false
        }
      }))
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func stubGET() {
    let statusCode = 200
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 18 Nov 2015 15:13:38 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-powered-by" : "shopwave",
      "content-length" : "346",
      "connection" : "Close",
    ]
    let body = "{\"status\":\"OK\",\"serverTimestamp\":\"2015-11-1815:13:38\",\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Tokenisvalid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":73}}"

    let matcher = matcherForURL(SWStatus.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }
}
