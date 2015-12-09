@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWUserTest: SWTestCase {

  func testGetCurrentUser() {
    stubGET()
    SWUser.getCurrentUser { (user, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(user)
      XCTAssertEqual(user, SWUser.currentUser)
      XCTAssertNotNil(user?.contexts[.Employee])
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testServerUnavailable() {
    stubServer500()
    SWUser.getCurrentUser { (user, errors) -> Void in
      XCTAssertNil(user)
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
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func stubGET() {
    let statusCode = 200
    let body = "{\"user\":{\"id\":1891,\"firstName\":\"Alex\",\"lastName\":\"Mitchell\",\"email\":\"alex@getshopwave.com\",\"employee\":{\"merchantId\":947,\"roleId\":1,\"stores\":{\"1136\":{\"id\":1136,\"roleId\":1,\"activeDate\":\"2015-10-13T13:33:53.000Z\"},\"1178\":{\"id\":1178,\"roleId\":3,\"activeDate\":\"2015-10-13T13:33:53.000Z\"}}}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":75}}"
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 02 Dec 2015 16:21:25 GMT",
      "server": "nginx/1.1.19",
      "vary": "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close"
    ]

    let matcher = matcherForURL(SWUser.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }
}
