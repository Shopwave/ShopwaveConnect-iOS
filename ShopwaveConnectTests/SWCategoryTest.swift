@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWCategoryTest: SWTestCase {

  func testGetAllCategories() {
    stubGET()
    SWCategory.getCategories { (categories, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(categories)
      XCTAssertEqual(categories!.count, SWCategory.allCategories.count)
      XCTAssertEqual(SWCategory.allCategories.count, 4)
      XCTAssertEqual(SWCategory.activeCategories.count, 2)

      let categoryWithParent = categories![4580]
      XCTAssertNotNil(categoryWithParent)
      XCTAssertNotNil(categoryWithParent!.parentId)
      XCTAssertNotNil(categoryWithParent!.parent)

      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testGetSpecificCategory() {
    let mockId = UInt(random())
    stubGETwithId(mockId)
    SWCategory.getCategories(withCategoryIds: [mockId]) { (categories, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(categories)
      XCTAssertTrue(categories?.count == 1)
      let (id, category) = (categories?.first)!
      XCTAssertEqual(category.id, id)
      XCTAssertEqual(id, mockId)
      XCTAssertEqual(category.title, "Food")
      XCTAssertNil(category.parentId)
      XCTAssertNil(category.parent)

      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testServerUnavailable() {
    stubServer500()
    SWCategory.getCategories { (categories, errors) -> Void in
      XCTAssertNil(categories)
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
    let body = "{\"categories\":{\"4580\":{\"id\":4580,\"title\":\"Condiment\",\"parentId\":4950,\"deleteDate\":null,\"activeDate\":\"2015-12-01T13:37:11.000Z\",\"type\":0},\"4950\":{\"id\":4950,\"title\":\"Food\",\"parentId\":null,\"deleteDate\":null,\"activeDate\":\"2015-12-01T13:37:00.000Z\",\"type\":0},\"4951\":{\"id\":4951,\"title\":\"Drink\",\"parentId\":null,\"deleteDate\":null,\"activeDate\":null,\"type\":0},\"4952\":{\"id\":4952,\"title\":\"whoops\",\"parentId\":null,\"deleteDate\":\"2015-12-01T13:53:42.000Z\",\"activeDate\":\"2015-12-01T13:54:05.000Z\",\"type\":0}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":75}}"
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Tue, 01 Dec 2015 13:37:07 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "664",
      "connection" : "Close",
    ]
    let matcher = matcherForURL(SWCategory.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }

  func stubGETwithId(id: UInt) {
    let requestHeaders = [
      "categoryIds" : "\(id)"
    ]

    let statusCode = 200
    let body = "{\"categories\":{\"\(id)\":{\"id\":\(id),\"title\":\"Food\",\"parentId\":null,\"deleteDate\":null,\"activeDate\":\"2015-12-01T13:37:00.000Z\",\"type\":0}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":73}}"
    let responseHeaders = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Tue, 01 Dec 2015 11:38:03 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "429",
      "connection" : "Close",
    ]
    let matcher = matcherForURL(SWCategory.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: responseHeaders, body: body)

    stub(matcher, builder: builder)
  }

}
