@testable import ShopwaveConnect

import Mockingjay
import XCTest

class SWStoreTest: SWTestCase {

  func testGetAllStores() {
    stubGET()
    SWStore.getStores { (stores, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(stores)
      XCTAssertEqual(SWStore.allStores.count, stores!.count)
      XCTAssertEqual(stores!.count, 3)
      XCTAssertEqual(SWStore.activeStores.count, 2)
      for (_, store) in SWStore.activeStores {
        XCTAssertTrue(store.active)
      }
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testGetSpecificStore() {
    let storeId = UInt(random())
    stubGETwithId(storeId)
    SWStore.getStoresWithStoreIds([storeId]) { (stores, errors) -> Void in
      XCTAssertNil(errors)
      XCTAssertNotNil(stores)
      XCTAssertEqual(stores!.count, 1)
      let (_, store) = stores!.first!
      XCTAssertNotEqual(store.fullAddress, "")
      XCTAssertNotNil(store.location)
      XCTAssertTrue(store.active)
      self.expectation.fulfill()
    }
    waitForExpectationsWithTimeout(0.1, handler: nil)
  }

  func testServerUnavailable() {
    stubServer500()
    SWStore.getStores { (stores, errors) -> Void in
      XCTAssertNil(stores)
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
    let body = "{\"stores\":{\"1136\":{\"id\":1136,\"lat\":0,\"lng\":0,\"addressLine1\":\"1829 Hobart Street\",\"addressLine2\":null,\"addressLine3\":null,\"phoneNumber\":\"6419902558\",\"city\":\"Grinnell\",\"postcode\":\"50112\",\"countryId\":\"US\",\"timezoneId\":null,\"storeDeleteDate\":null},\"1178\":{\"id\":1178,\"lat\":51.5235,\"lng\":-0.109899,\"addressLine1\":\"20 Baker\'s Row\",\"addressLine2\":null,\"addressLine3\":null,\"phoneNumber\":null,\"city\":\"London\",\"postcode\":\"EC1R 3DG\",\"countryId\":\"GB\",\"timezoneId\":36,\"storeDeleteDate\":null},\"1416\":{\"id\":1416,\"lat\":51.5277,\"lng\":-0.0779527,\"addressLine1\":\"whoops\",\"addressLine2\":null,\"addressLine3\":null,\"phoneNumber\":null,\"city\":\"london\",\"postcode\":\"UK\",\"countryId\":\"GB\",\"timezoneId\":null,\"storeDeleteDate\":\"2015-12-02T15:42:50.000Z\"}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":72}}"
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 02 Dec 2015 15:07:52 GMT",
      "server" : "nginx/1.1.19",
      "vary" : "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close"
    ]
    let matcher = matcherForURL(SWStore.endpointURL, withHeaders: nil)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)
  }

  func stubGETwithId(id: UInt) {
    let requestHeaders = [
      "storeIds" : "\(id)"
    ]

    let statusCode = 200
    let body = "{\"stores\":{\"\(id)\":{\"id\":\(id),\"lat\":51.5235,\"lng\":-0.109899,\"addressLine1\":\"20 Baker\'s Row\",\"addressLine2\":null,\"addressLine3\":null,\"phoneNumber\":null,\"city\":\"London\",\"postcode\":\"EC1R 3DG\",\"countryId\":\"GB\",\"timezoneId\":36,\"storeDeleteDate\":null}},\"api\":{\"message\":{\"success\":{\"202\":{\"id\":202,\"title\":\"Token is valid\",\"details\":\"Token is validated and found valid.\"},\"203\":{\"id\":203,\"title\":\"Request Processed Successfully\",\"details\":\"The request has been successfully completed.\"}}},\"codeBaseVersion\":0.6,\"executionTime_milliSeconds\":74}}"
    let headers = [
      "content-type" : "application/json; charset=utf-8",
      "date" : "Wed, 02 Dec 2015 15:30:50 GMT",
      "server": "nginx/1.1.19",
      "vary": "Accept-Encoding",
      "x-api-version" : "0.6",
      "x-powered-by" : "shopwave",
      "content-length" : "\(body.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))",
      "connection" : "Close"
    ]

    let matcher = matcherForURL(SWStore.endpointURL, withHeaders: requestHeaders)
    let builder = builderWithStatusCode(statusCode, headers: headers, body: body)
    stub(matcher, builder: builder)

  }

}
