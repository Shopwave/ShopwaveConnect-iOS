import Foundation

public class SWProduct: SWAPIEndpoint {
  static let endpointURL = NSURL(string: "/product", relativeToURL: baseURL)!
  static var allProducts = Set<SWProduct>() {
    didSet {
      recalculateCaches()
    }
  }
  static private(set) var liveProducts: Set<SWProduct> = Set<SWProduct>()
  static private(set) var productsById: [UInt : SWProduct] = [UInt : SWProduct]()
  static private(set) var productsByBarcodes: [String : SWProduct] = [String : SWProduct]()

  class func recalculateCaches() {
    liveProducts.removeAll()
    productsById.removeAll()
    productsByBarcodes.removeAll()
    allProducts.forEach { (product) -> () in
      productsById[product.id] = product
      if let barcode = product.barcode {
        productsByBarcodes[barcode] = product
      }
      if product.deleteDate != nil {
        liveProducts.insert(product)
      }
    }
  }

  var id: UInt
  var name: String
  var price: Double
  var taxPercentage: Double
  var productInstanceId: UInt

  var activeDate: NSDate?
  var addedDate: NSDate?
  var barcode: String?
  var deleteDate: NSDate?
  var details: String?
  var totalStock: UInt?
  var stockSold: UInt?
  var stockLeft: Int?
  var imageURLs: Set<NSURL>?
  var productInstanceAddedDate: NSDate?

  var sourceDictionary: [String : AnyObject]?


  var categoriesIds: Set<UInt>
  var categories: Set<SWCategory> {
    return Set(categoriesIds.map({ (categoryId) -> SWCategory in
      SWCategory.categoriesById[categoryId]!
    }))
  }

  init(id: UInt, name: String, price: Double, taxPercentage: Double, productInstanceId: UInt, activeDate: NSDate? = nil, addedDate: NSDate? = nil, barcode: String? = nil, deleteDate: NSDate? = nil, details: String? = nil, totalStock: UInt? = nil, stockSold: UInt? = nil, stockLeft: Int? = nil, imageURLs: Set<NSURL>? = nil, productInstanceAddedDate: NSDate? = nil, categoriesIds: Set<UInt> = Set<UInt>()) {
    self.id = id
    self.name = name
    self.price = price
    self.taxPercentage = taxPercentage
    self.productInstanceId = productInstanceId

    self.activeDate = activeDate
    self.addedDate = addedDate
    self.barcode = barcode
    self.deleteDate = deleteDate
    self.details = details
    self.totalStock = totalStock
    self.stockSold = stockSold
    self.stockLeft = stockLeft
    self.imageURLs = imageURLs
    self.productInstanceAddedDate = productInstanceAddedDate
    self.categoriesIds = categoriesIds

    super.init()
  }
  convenience init(fromDictionary dict: [String : AnyObject]) {
    var id: UInt
    var name: String
    var price: Double
    var taxPercentage: Double
    var productInstanceId: UInt

    var activeDate: NSDate?
    var addedDate: NSDate?
    var barcode: String?
    var deleteDate: NSDate?
    var details: String?
    var totalStock: UInt?
    var stockSold: UInt?
    var stockLeft: Int?
    var imageURLs: Set<NSURL>?
    var productInstanceAddedDate: NSDate?
    var categoriesIds = Set<UInt>()

    id = dict["id"] as! UInt
    name = dict["name"] as! String
    price = Double(dict["price"] as! String)!
    taxPercentage = Double(dict["vatPercentage"] as! String)!
    productInstanceId = dict["productInstanceId"] as! UInt

    if let active = dict["activeDate"] as? String {
      activeDate = SWAPIEndpoint.dateFromSWAPIDate(active)
    }
    if let added = dict["addedDate"] as? String {
      addedDate = SWAPIEndpoint.dateFromSWAPIDate(added)
    }
    if let bc = dict["barcode"] as? String {
      barcode = bc
    }
    if let deleted = dict["deleteDate"] as? String {
      deleteDate = SWAPIEndpoint.dateFromSWAPIDate(deleted)
    }
    if let detail = dict["details"] as? String {
      details = detail
    }
    if let total = dict["totalStock"] as? String {
      totalStock = UInt(total)
    }
    if let sold = dict["stockSold"] as? String {
      stockSold = UInt(sold)
    }
    if let left = dict["stockLeft"] as? String {
      stockLeft = Int(left)
    }
    if let images = dict["images"] as? [String] {
      var urls =  Set<NSURL>()
      images.forEach({ (str) -> () in
        if let url = NSURL(string: str) {
          urls.insert(url)
        }
      })
      imageURLs = urls
    }
    if let instanceAddedDate = dict["productInstanceAddedDate"] as? String {
      productInstanceAddedDate = SWAPIEndpoint.dateFromSWAPIDate(instanceAddedDate)
    }

    if let categories = dict["categories"] as? [String : String] {
      for (categoryId, _) in categories {
        if let id = UInt(categoryId) {
          categoriesIds.insert(id)
        }
      }
    }

    self.init(id: id, name: name, price: price, taxPercentage: taxPercentage, productInstanceId: productInstanceId, activeDate: activeDate, addedDate: addedDate, barcode: barcode, deleteDate: deleteDate, details: details, totalStock: totalStock, stockSold: stockSold, stockLeft: stockLeft, imageURLs: imageURLs, productInstanceAddedDate: productInstanceAddedDate, categoriesIds: categoriesIds)
    sourceDictionary = dict
  }

  func combine(withProduct product: SWProduct) {
    if id != product.id {
      return
    }

    sourceDictionary = product.sourceDictionary
    name = product.name
    price = product.price
    taxPercentage = product.taxPercentage
    productInstanceId = product.productInstanceId

    categoriesIds = product.categoriesIds

    if let activeDate = product.activeDate {
      self.activeDate = activeDate
    }
    if let addedDate = product.addedDate {
      self.addedDate = addedDate
    }
    if let barcode = product.barcode {
      self.barcode = barcode
    }
    if let deleteDate = product.deleteDate {
      self.deleteDate = deleteDate
    }
    if let details = product.details {
      self.details = details
    }
    if let totalStock = product.totalStock {
      self.totalStock = totalStock
    }
    if let stockSold = product.stockSold {
      self.stockSold = stockSold
    }
    if let stockLeft = product.stockLeft {
      self.stockLeft = stockLeft
    }
    if let imageURLs = product.imageURLs {
      self.imageURLs = imageURLs
    }
    if let productInstanceAddedDate = product.productInstanceAddedDate {
      self.productInstanceAddedDate = productInstanceAddedDate
    }
  }

  class func initialiseProducts(products: [SWProduct]) {
    allProducts.removeAll()
    for product in products {
      upsertProduct(product)
    }
  }

  class func upsertProduct(product: SWProduct) {
    if let oldProduct = productsById[product.id] {
      oldProduct.combine(withProduct: product)
    } else {
      allProducts.insert(product)
    }
  }

  class func upsertProducts(products: [SWProduct]) {
    for product in products {
      upsertProduct(product)
    }
  }

  class func updateLocalProducts(completion:(()->Void)?) {
    getProducts { (products, error) -> Void in
      completion?()
    }
  }

  /**
  Used to fetch all products in all stores for the currently authenticated user
  - parameter completion: A set of instructions to execute after products are fetched
  - returns: products, an array of SWProducts, or an error
  */
  public class func getProducts(completion:((products: [SWProduct]?, errors: [ErrorType]?)->Void)) {
    getProductsForStoreIds(nil, productIds: nil, completion: completion)
  }
  /**
  Used to fetch certain products in certain stores for the currently authenticated user
  - parameter storeIds: An array of stores to fetch products from. Use nil to fetch for all stores.
  - parameter productIds: An array of products to fetch. Use nil to fetch all products.
  - parameter completion: A set of instructions to execute after products are fetched
  - returns: products, an array of SWProducts, or an error
  */
  public class func getProductsForStoreIds(storeIds:[UInt]?, productIds:[Int]?,
    completion:((products: [SWProduct]?, errors: [ErrorType]?)->Void)?) {
      var headers = [String : String]()

      if let storeIds = storeIds {
        headers["storeId"] = arrayToString(storeIds)
      }
      if let productIds = productIds {
        headers["productIds"] = arrayToString(productIds)
      }

      getWithHeaders(headers, body: nil, url: endpointURL) { (result, headers, errors) -> Void in
        if let errors = errors {
          // TODO: Remove Internal Errors
          completion?(products: nil, errors: errors)
        } else if let result = result {
          let response = result["products"] as! [String : AnyObject]
          var products = [SWProduct]()
          for (_, productDictionary) in response {
            if let dict = productDictionary as? [String : AnyObject] {
              products.append(SWProduct(fromDictionary: dict))
            }
          }
          upsertProducts(products)
          completion?(products: products, errors: nil)
        } else {
          completion?(products: nil, errors: [SWAPIEndpoint.Error.Unknown(details: "SWAPIEndpoint.getWithHeaders returned no results nor errors")])
        }
      }
  }
}
