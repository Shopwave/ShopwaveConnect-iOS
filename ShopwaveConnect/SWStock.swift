import Foundation

public enum SWStockInitType {
  case Empty
  case Zeros
}

public class SWStock: SWAPIEndpoint {
  static let logTag = "StockTake, Product"
  static let endpointURL = NSURL(string: "/stock/reconcile", relativeToURL: baseURL)!

  public var touchedInventory: [SWProduct : UInt] = [SWProduct : UInt]()
  public var availableProducts = [SWProduct]()
  var log: SWLog?
  let storeId: UInt
  let addedDate: NSDate
  var completeDate: NSDate?
  public var reconciliations = [SWProduct : SWStockReconciliation]()
  var complete: Bool {
    return completeDate != nil
  }

  public enum Error: ErrorType {
    case NoLocalInventory
  }

  init(storeId: UInt, addedDate: NSDate = NSDate(), type: SWStockInitType) {
    self.storeId = storeId
    self.addedDate = addedDate
    if type == SWStockInitType.Zeros {
      for product in SWProduct.liveProducts {
        self.touchedInventory[product] = 0
      }
    }
    super.init()
  }

  convenience init?(fromLog log: SWLog) {
    if let storeId = UInt(log.objectIdentifier!) {
      self.init(storeId: storeId, addedDate: log.addedDate, type: .Empty)

    } else {
      return nil
    }
    self.log = log
    self.completeDate = log.completeDate

    if let stocktake = log.value?["products"] as? [String : UInt] {
      for (productId, count) in stocktake {
        if let productId = UInt(productId), product = SWProduct.productsById[productId] {
          self.touchedInventory[product] = count
        }
      }
    }
  }

  public func saveToServer(completion:((errors: [ErrorType]?)->Void)?) {
    var products = [String : UInt]()

    for (product, count) in touchedInventory {
      products[String(product.id)] = count
    }

    let value = [
      "products" : products
    ]

    if let log = log {
      SWLog.postLogWithId(log.id, tag: SWStock.logTag, value: value, completeDate: completeDate, completion: { (newLog, errors) -> Void in
        if let errors = errors {
          // TODO: Remove internal Errors
          completion?(errors: errors)
        } else if let newLog = newLog {
          log.updateWithLog(newLog)
          completion?(errors: nil)
        }
      })
    } else {
      SWLog.postLogWithTag(SWStock.logTag, object: "STORE", objectIdentifier: "\(storeId)", value: value, completeDate: completeDate, completion: { (log, errors) -> Void in
        if let errors = errors {
          // TODO: Remove internal Errors
          completion?(errors: errors)
        } else if let log = log {
          self.log = log
          completion?(errors: nil)
        }
      })
    }
  }

  public class func stocktakesForStores(stores: [SWStore], completion:((stocktakes: [SWStore : [SWStock]]?, error: [ErrorType]?) -> Void)) {
    let ids = stores.map { (store) -> String in
      return "\(store.id)"
    }
    SWLog.getLogsWithTag(logTag, forObjects: "STORE", withIdentifiers: ids) { (logs, error) -> Void in
      var ledger = [SWStore : [SWStock]]()
      for (_,stockTake) in logs! {
        if let take = SWStock(fromLog: stockTake) {
          let storeId = UInt(take.log!.objectIdentifier!)!
          let store = SWStore.allStores[storeId]!
          if ledger[store] != nil {
            ledger[store]!.append(take)
          } else {
            ledger[store] = [take]
          }
        }
      }
      for (_, var stocktakes) in ledger {
        stocktakes.sortInPlace({ (take1: SWStock, take2: SWStock) -> Bool in
          return take1.addedDate.compare(take2.addedDate) == NSComparisonResult.OrderedDescending
        })
      }
      completion(stocktakes: ledger, error: error)
      return
    }
  }
  public func reconcileToServer(completion: ((errors: [ErrorType]?) -> Void)?) {
    SWProduct.getProductsForStoreIds([storeId], productIds: nil) { (_, errors) -> Void in
      if let errors = errors {
        completion?(errors: errors)
        return
      }

      var products = [String : AnyObject]()

      for (product, reconciliation) in self.reconciliations {
        var rec: [String : AnyObject] = [
          "productId" : product.id,
          "productName" : product.name.stringByAddingPercentEncodingForURLQueryValue()!,
          "quantity" : reconciliation.discrepancy
        ]

        if reconciliation.notes != "" {
          rec["note"] = reconciliation.notes.stringByAddingPercentEncodingForURLQueryValue()
        }

        if let reconciliation = reconciliation as? SWStockSurplus {
          rec["price"] = reconciliation.unitCost
          rec["vatPercentage"] = reconciliation.taxPercentage/100
        }

        products[String(reconciliation.product.id)] = rec
      }

      let stockReconcile = [
        "stockReconcile": [
          "products" : products,
          "storeId" : self.storeId,
          "completed" : true
        ]
      ]

      SWAPIEndpoint.postWithHeaders(nil, body: stockReconcile, url: SWStock.endpointURL, completion: { (result, headers, errors) -> Void in
        if let errors = errors {
          // TODO: Remove Internal Errors
          completion?(errors: errors)
        } else {
          // TODO: Handle baskets and invoices
          completion?(errors: nil)
        }
      })
    }
  }

  /**
   Increases the count of a product in the stocktake by one
   - parameter code: The barcode of the product to touch
   - returns: The updated count for touched product, or an error
   - SeeAlso: unTouchProductWithBarcode()
   */
  public func touchProductWithBarcode(code: String) -> (UInt?, ErrorType?) {
    if let product = SWProduct.productsByBarcodes[code] {
      return touchProduct(product)
    } else {
      return (nil, Error.NoLocalInventory)
    }
  }
  /**
   Increases the count of a product in the stocktake by one
   - parameter product: The product to increase count by 1
   - returns: The updated count for touched product, or an error
   - SeeAlso: unTouchProductWithIdentifier()
   */
  public func touchProduct(product: SWProduct) -> (UInt?, ErrorType?) {
    return adjustProduct(product, modifier: 1)
  }
  /**
   Decreases the count of a product in the stocktake by one
   - parameter code: The barcode of the product to untouch
   - returns: The updated count for untouched product, or an error
   - SeeAlso: touchProductWithBarcode()
   */
  public func unTouchProductWithBarcode(code: String) -> (UInt?, ErrorType?) {
    if let product = SWProduct.productsByBarcodes[code] {
      return unTouchProduct(product)
    } else {
      return (nil, Error.NoLocalInventory)
    }
  }
  /**
   Decreases the count of a product in the stocktake by one
   - parameter code: The identifier of the product to untouch
   - returns: The updated count for untouched product, or an error
   - SeeAlso: touchProductWithIdentifier()
   */
  public func unTouchProduct(product: SWProduct) -> (UInt?, ErrorType?) {
    return adjustProduct(product, modifier: -1)
  }

  /**
   Changes the count of a product in the stocktake by a given modifier
   - parameter id: The identifier of the product to alter
   - parameter modifier: The amount to shift the count.
   - returns: The updated count for touched product, or an error
   */
  public func adjustProduct(product: SWProduct, modifier: Int) -> (UInt?, ErrorType?) {
    if let count = touchedInventory[product] {
      touchedInventory[product] = UInt(Int(count) + modifier)
    } else {
      touchedInventory[product] = UInt(modifier)
    }
    return (touchedInventory[product]!, nil)
  }
}

extension String {
  func stringByAddingPercentEncodingForURLQueryValue() -> String? {
    let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
    characterSet.addCharactersInString("-._~")

    return stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
  }
}
