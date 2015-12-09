@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWProductTest: SWTestCase {

  func testGETReturnsExpectedObjects() {
    stubGET()
    SWProduct.getProducts { (products, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(products)
      XCTAssertEqual(products?.count, SWProduct.allProducts.count)
      XCTAssertEqual(SWProduct.allProducts.count, 3)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testGETAdditionalInformationCombines() {
    stubGET()
    SWProduct.getProducts { (products, errors) -> Void in
      let storeId = UInt(random())
      self.stubGETwithStoreId(storeId)
      SWProduct.getProductsForStoreIds([storeId], productIds: nil, completion: { (products, errors) -> Void in
        XCTAssertEqual(SWProduct.allProducts.count, 3)
        for product in SWProduct.allProducts {
          XCTAssertNotNil(product.stockLeft)
          XCTAssertNotNil(product.stockSold)
          XCTAssertNotNil(product.totalStock)
        }
        self.expectation.fulfill()
      })
    }
    waitForExpectationsWithTimeout(1, handler: nil)
  }

  func testServerUnavailable() {
    stubServer500()
    SWProduct.getProducts { (products, errors) -> Void in
      XCTAssertNil(products)
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
    let body = "{\"products\":{\"80206\":{\"id\":80206,\"barcode\":\"B313\",\"name\":\"Mayonnaise\",\"details\":\"9.5g - 10ml\",\"unit\":null,\"productInstanceId\":115968,\"price\":\"41.7\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-09-23T13:30:33.000Z\",\"categories\":{\"4580\":\"Condiment\"},\"productInstanceTimestamp\":\"2015-09-30T10:07:07.000Z\",\"productTimestamp\":\"2015-09-30T10:07:06.000Z\"},\"80499\":{\"id\":80499,\"barcode\":\"515253\",\"name\":\"Sweet Curry Dip\",\"details\":\"Made in the UK by McCormick Europe\\r\\nLittleborough, OL15 8BZ UK\",\"unit\":null,\"productInstanceId\":115965,\"price\":\"41.7\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-09-30T09:13:59.000Z\",\"categories\":{},\"productInstanceTimestamp\":\"2015-09-30T09:29:46.000Z\",\"productTimestamp\":\"2015-09-30T09:29:46.000Z\"},\"83009\":{\"id\":83009,\"barcode\":\"tvewelve\",\"name\":\"whatever\",\"details\":\"\",\"unit\":null,\"productInstanceId\":120216,\"price\":\"83250.0\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-11-11T13:30:08.000Z\",\"categories\":{},\"productInstanceTimestamp\":\"2015-11-11T13:45:58.000Z\",\"productTimestamp\":\"2015-11-11T13:45:58.000Z\"}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":438}}"
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Tue, 24 Nov 2015 16:15:33 GMT",
      "etag" : "\"2067262733\"",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "1365",
      "connection" : "Close",
    ]

    let matcher = matcherForURL(SWProduct.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }

  func stubGETwithStoreId(id: UInt) {
    let requestHeaders = [
      "storeId" : "\(id)"
    ]
    let statusCode = 200
    let body = "{\"products\":{\"80206\":{\"id\":80206,\"barcode\":\"B313\",\"name\":\"Mayonnaise\",\"details\":\"9.5g - 10ml\",\"unit\":null,\"productInstanceId\":115968,\"price\":\"41.7\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-09-23T13:30:33.000Z\",\"categories\":{\"4580\":\"Condiment\"},\"productInstanceTimestamp\":\"2015-09-30T10:07:07.000Z\",\"productTimestamp\":\"2015-09-30T10:07:06.000Z\",\"totalStock\":80,\"stockSold\":25,\"stockLeft\":55},\"80499\":{\"id\":80499,\"barcode\":\"515253\",\"name\":\"Sweet Curry Dip\",\"details\":\"Made in the UK by McCormick Europe\\r\\nLittleborough, OL15 8BZ UK\",\"unit\":null,\"productInstanceId\":115965,\"price\":\"41.7\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-09-30T09:13:59.000Z\",\"categories\":{},\"productInstanceTimestamp\":\"2015-09-30T09:29:46.000Z\",\"productTimestamp\":\"2015-09-30T09:29:46.000Z\",\"totalStock\":35,\"stockSold\":35,\"stockLeft\":0},\"83009\":{\"id\":83009,\"barcode\":\"tvewelve\",\"name\":\"whatever\",\"details\":\"\",\"unit\":null,\"productInstanceId\":120216,\"price\":\"83250.0\",\"size\":\"0.0\",\"vatPercentage\":\"0.200\",\"activeDate\":\"2015-11-11T13:30:08.000Z\",\"categories\":{},\"productInstanceTimestamp\":\"2015-11-11T13:45:58.000Z\",\"productTimestamp\":\"2015-11-11T13:45:58.000Z\",\"totalStock\":5,\"stockSold\":5,\"stockLeft\":0}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":448}}"

    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Tue, 24 Nov 2015 17:32:12 GMT",
      "etag" : "\"894250166\"",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "1499",
      "connection" : "Close",
    ]
    let matcher = matcherForURL(SWProduct.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }
}
