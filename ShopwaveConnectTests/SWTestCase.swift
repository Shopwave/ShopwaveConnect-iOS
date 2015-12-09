@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWTestCase: XCTestCase {

  var expectation: XCTestExpectation!

  override class func setUp() {
    super.setUp()
    SWAuth.clientId = ""
    SWAuth.clientSecret = ""
    SWAuth.customURL = ""
    SWAuth.accessToken = ""
    SWAuth.tokenExpiration = NSDate(timeIntervalSinceNow: 1000)
  }

  override func setUp() {
    super.setUp()
    expectation = expectationWithDescription("")
  }

  override func tearDown() {
    super.tearDown()
    expectation = nil
    removeAllStubs()
  }

  private func matchAllMerchantstack(request: NSURLRequest) -> Bool {
    let baseRequestURL = "\((request.URL?.scheme)!)://\((request.URL?.host)!)/"
    return baseRequestURL == SWAPIEndpoint.baseURL!.absoluteString
  }

  func builderWithStatusCode(statusCode: Int, headers: [String : String]?, body: String?) -> ((request: NSURLRequest) -> Response) {
    func builder(request: NSURLRequest) -> Response {
      let response = NSHTTPURLResponse(URL: request.URL!, statusCode: statusCode, HTTPVersion: nil, headerFields: headers)
      let bodyData = body == nil ? nil : body!.dataUsingEncoding(NSUTF8StringEncoding)
      return .Success(response!, bodyData)
    }
    return builder
  }

  func matcherForURL(url: NSURL, withHeaders headers: [String : String]?) -> ((request: NSURLRequest) -> Bool) {
    func matcher(request: NSURLRequest) -> Bool {
      if let headers = headers {
        for (key, value) in headers {
          if let requestValue = request.allHTTPHeaderFields![key] {
            if requestValue == value {
              continue
            }
          }
          return false
        }
      }

      let urlsMatch = request.URL!.absoluteURL == url.absoluteURL
      return  urlsMatch
    }
    return matcher
  }

  func stubServer500() {
    func builder (request: NSURLRequest) -> Response {
      let response = NSHTTPURLResponse(URL: request.URL!, statusCode: 500, HTTPVersion: nil, headerFields: nil)
      return .Success(response!, nil)
    }
    stub(matchAllMerchantstack, builder: builder)
  }

}