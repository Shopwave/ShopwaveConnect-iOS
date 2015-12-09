@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWStockTest: SWTestCase {

  func testEmptyStocktakePost() {
    stubPOST()
    stubProductGET()
    let emptyStocktake = SWStock(storeId: 12, type: .Empty)
    emptyStocktake.reconcileToServer { (errors) -> Void in
      XCTAssertNil(errors)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }
  func testZeroedStocktakePost() {
    stubPOST()
    stubProductGET()
    let stocktake = SWStock(storeId: 12, type: .Zeros)
    stocktake.reconcileToServer { (errors) -> Void in
      XCTAssertNil(errors)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testTouchingMethods() {
    SWProduct.upsertProducts(randomProducts())
    let take = SWStock(storeId: 12, type: .Empty)
    var (count, error) = take.touchProductWithBarcode("doggie")
    XCTAssertNil(error)
    XCTAssertEqual(count, 1)
    XCTAssertEqual(take.touchedInventory.count, 1)
    XCTAssertEqual(take.touchedInventory.first!.0.barcode, "doggie")
    XCTAssertEqual(take.touchedInventory.first!.1, 1)
    (count, error) = take.touchProductWithBarcode("doggie")
    XCTAssertNil(error)
    XCTAssertEqual(count, 2)
    XCTAssertEqual(take.touchedInventory.count, 1)
    XCTAssertEqual(take.touchedInventory.first!.0.barcode, "doggie")
    XCTAssertEqual(take.touchedInventory.first!.1, 2)
    (count, error) = take.unTouchProductWithBarcode("doggie")
    XCTAssertNil(error)
    XCTAssertEqual(count, 1)
    XCTAssertEqual(take.touchedInventory.count, 1)
    XCTAssertEqual(take.touchedInventory.first!.0.barcode, "doggie")
    XCTAssertEqual(take.touchedInventory.first!.1, 1)
    (count, error) = take.touchProductWithBarcode("kitty")
    XCTAssertNil(error)
    XCTAssertEqual(count, 1)
    XCTAssertEqual(take.touchedInventory.count, 2)
    (count, error) = take.unTouchProductWithBarcode("doggie")
    XCTAssertNil(error)
    XCTAssertEqual(count, 0)
    XCTAssertEqual(take.touchedInventory.count, 2)
    self.expectation.fulfill()
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testCompletion() {
    let take = SWStock(storeId: 12, type: .Empty)
    XCTAssertFalse(take.complete)
    take.completeDate = NSDate()
    XCTAssertTrue(take.complete)
    expectation.fulfill()
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func randomProducts() -> [SWProduct] {
    return [
      SWProduct(id: 1, name: "Dog", price: 12, taxPercentage: 5, productInstanceId: 1, barcode: "doggie"),
      SWProduct(id: 2, name: "Cat", price: 12, taxPercentage: 5, productInstanceId: 2, barcode: "kitty"),
      SWProduct(id: 3, name: "Television", price: 13, taxPercentage: 20, productInstanceId: 5, barcode: "tv")

    ]
  }

  func stubPOST() {
    let matcher = matcherForURL(SWStock.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(201, headers: nil, body: nil)
    stub(matcher, builder: builder)
  }

  func stubProductGET() {
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
}
