@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWLogTest: SWTestCase {
  func testServerUnavailable() {
    stubServer500()
    SWLog.getLogsWithTag("StockTake, Product", forObjects: "STORE", withIdentifier: "12") { (logs, errors) -> Void in
      XCTAssertNil(logs)
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

  func testGetForMultipleIds() {
    let storeIds = [
      "1136",
      "1196"
    ]

    for id in storeIds {
      stubGETforTag("StockTake, Product", object: "STORE", identifier: id)
    }

    SWLog.getLogsWithTag("StockTake, Product", forObjects: "STORE", withIdentifiers: storeIds) { (logs, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(logs)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(10, handler: nil)
  }

  func testPostNewLog() {
    let tag = "Test"
    let object = "STORE"
    let identifier = "12"
    let value = ["shopwave" : "connect"]
    stubPOSTforTag(tag, object: object, identifier: identifier, value: value)
    SWLog.postLogWithTag(tag, object: object, objectIdentifier: identifier, value: value) { (log, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(log)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testPostUpdatedLog() {
    let id = "947-STORE-1136:1449057618501"
    let tag = "Test"
    stubPOSTforLogId(id, tag: tag)
    let log = SWLog(id: id, tag: tag, value: nil, object: "STORE", objectIdentifier: "1136", addedDate: NSDate(), completeDate: NSDate())
    log.saveToServer { (errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(log.completeDate)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func stubGETforTag(tag: String, object: String, identifier: String) {
    let requestHeaders = [
      "object" : object,
      "identifier" : identifier,
      "tag" : tag
    ]

    let statusCode = 200
    let body = "{\r\n\t\"log\": {\r\n\t\t\"947-\(object)-\(identifier):1447245532919\": {\r\n\t\t\t\"id\": \"947-\(object)-\(identifier):1447245532919\",\r\n\t\t\t\"merchantId\": \"947\",\r\n\t\t\t\"tag\": \"StockTake, Product\",\r\n\t\t\t\"object\": \"\(object)\",\r\n\t\t\t\"identifier\": \"\(identifier)\",\r\n\t\t\t\"addedDate\": \"2015-11-11T12:38:52.919Z\"\r\n\t\t},\r\n\t\t\"947-\(object)-\(identifier):1447281050241\": {\r\n\t\t\t\"id\": \"947-\(object)-\(identifier):1447281050241\",\r\n\t\t\t\"merchantId\": \"947\",\r\n\t\t\t\"tag\": \"StockTake, Product\",\r\n\t\t\t\"object\": \"\(object)\",\r\n\t\t\t\"identifier\": \"\(identifier)\",\r\n\t\t\t\"addedDate\": \"2015-11-11T22:30:50.241Z\",\r\n\t\t\t\"completeDate\": \"2015-11-11T22:31:26.252Z\"\r\n\t\t}\r\n\t},\r\n\t\"api\": {\r\n\t\t\"message\": {\r\n\t\t\t\"success\": {\r\n\t\t\t\t\"202\": {\r\n\t\t\t\t\t\"id\": 202,\r\n\t\t\t\t\t\"title\": \"Token is valid\",\r\n\t\t\t\t\t\"details\": \"Token is validated and found valid.\"\r\n\t\t\t\t},\r\n\t\t\t\t\"203\": {\r\n\t\t\t\t\t\"id\": 203,\r\n\t\t\t\t\t\"title\": \"Request Processed Successfully\",\r\n\t\t\t\t\t\"details\": \"The request has been successfully completed.\"\r\n\t\t\t\t}\r\n\t\t\t}\r\n\t\t},\r\n\t\t\"codeBaseVersion\": 0.6,\r\n\t\t\"executionTime_milliSeconds\": 100\r\n\t}\r\n}"
    let responseHeaders = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Tue, 24 Nov 2015 16:15:33 GMT",
      "etag" : "\"2067262733\"",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close",
    ]

    let matcher = matcherForURL(SWLog.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: responseHeaders, body: body)
    stub(matcher, builder: builder)
  }

  func stubPOSTforTag(tag: String, object: String, identifier: String, value: AnyObject?) {
    let requestHeaders = [
      "tag" : tag,
      "object" : object,
      "identifier" : identifier
    ]

    let statusCode = 201
    var valueJSONString = ""
    if let value = value {
      do {
        let valueJSON = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions.init(rawValue: 0))
        valueJSONString = String(data: valueJSON, encoding: NSUTF8StringEncoding)!
      } catch {
        fatalError()
      }
    }

    let body = "{\"log\":{\"value\":\(valueJSONString),\"object\":\"\(object)\",\"identifier\":\"\(identifier)\",\"tag\":\"\(tag)\",\"id\":\"947-\(object)-\(identifier):1449057618501\",\"addedDate\":\"2015-12-02T12:00:18.501Z\"},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"206\":{\"id\":206,\"title\":\"Resource Created\",\"details\":\"Your resource is created partially or fully. Please check further message or process log\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":104}}"

    let responseHeaders = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 02 Dec 2015 12:00:18 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close"
    ]

    let matcher = matcherForURL(SWLog.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: responseHeaders, body: body)
    stub(matcher, builder: builder)
  }

  func stubPOSTforLogId(id: String, tag: String) {
    let requestHeaders = [
      "id" : id,
      "tag" : tag
    ]

    let statusCode = 201
    let body = "{\"log\":{\"value\":{\"shopwave\":\"connect\"},\"tag\":\"\(tag)\",\"id\":\"\(id)\",\"completeDate\":\"2015-12-02T12:38:31.325Z\",\"addedDate\":\"2015-12-02T12:38:31.325Z\"},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"206\":{\"id\":206,\"title\":\"Resource Created\",\"details\":\"Your resource is created partially or fully. Please check further message or process log\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":114}}"
    let responseHeaders = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 02 Dec 2015 12:38:31 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close"
    ]

    let matcher = matcherForURL(SWLog.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: responseHeaders, body: body)
    stub(matcher, builder: builder)
  }

}
