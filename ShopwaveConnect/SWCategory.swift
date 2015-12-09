import Foundation

public class SWCategory: SWAPIEndpoint {
  static let endpointURL = NSURL(string: "/category", relativeToURL: baseURL)!
  static var allCategories: Set<SWCategory> = Set<SWCategory>() {
    didSet {
      categoriesById.removeAll()
      activeCategories.removeAll()
      allCategories.forEach { (category) in
        categoriesById[category.id] = category
        if category.activeDate != nil && category.deleteDate == nil {
          activeCategories.insert(category)
        }
      }
    }
  }
  static private(set) var activeCategories: Set<SWCategory> = Set<SWCategory>()
  static private(set) var categoriesById = [UInt : SWCategory]()

  public typealias SWCategoryCompletion = (categories: [UInt : SWCategory]?, errors:[ErrorType]?) -> Void

  let id: UInt
  var title: String
  var parentId: UInt?
  var parent: SWCategory? {
    if let parentId = parentId {
      return SWCategory.categoriesById[parentId]
    } else {
      return nil
    }
  }
  var deleteDate: NSDate?
  var activeDate: NSDate?
  override public var description: String {
    return title
  }

  func combine(withCategory new: SWCategory) {
    if id != new.id {
      return
    }
    title = new.title
    if let parentId = new.parentId {
      self.parentId = parentId
    }
    if let deleteDate = new.deleteDate {
      self.deleteDate = deleteDate
    }
    if let activeDate = new.activeDate {
      self.activeDate = activeDate
    }
  }

  class func upsertCategory(category: SWCategory) {
    if let oldCategory = categoriesById[category.id] {
      oldCategory.combine(withCategory: category)
    } else {
      allCategories.insert(category)
    }
  }

  class func upsertCategories(categories: [SWCategory]) {
    for category in categories {
      upsertCategory(category)
    }
  }

  public class func getCategories(completion:SWCategoryCompletion?) {
    getCategories(withCategoryIds: nil, completion: completion)
  }

  public class func getCategories(withCategoryIds ids:[UInt]?, completion: SWCategoryCompletion?) {
    var headers: [String : String]?
    if let ids = ids {
      headers = [
        "categoryIds" : arrayToString(ids)
      ]
    }

    getWithHeaders(headers, body: nil, url: endpointURL) { (result, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove Internal Errors
        completion?(categories: nil, errors: errors)
      } else if let result = result {
        let response = result["categories"] as! [String : AnyObject]
        var retrievedCategories = [UInt : SWCategory]()
        for (_, dict) in response {
          let category = SWCategory(fromDictionary: dict as! [String : AnyObject])
          retrievedCategories[category.id] = category
        }
        upsertCategories(Array(retrievedCategories.values))
        completion?(categories: retrievedCategories, errors: nil)
      } else {
        completion?(categories: nil, errors: [SWAPIEndpoint.Error.Unknown(details: "SWAPIEndpoint.getWithHeaders returned no results nor errors")])
      }
    }
  }

  init(fromDictionary dict:[String : AnyObject]) {
    id = dict["id"] as! UInt
    title = dict["title"] as! String

    if let parentId = dict["parentId"] as? UInt {
      self.parentId = parentId
    }

    if let date = dict["deleteDate"] as? String!, actualDate = date {
      deleteDate = SWAPIEndpoint.dateFromSWAPIDate(actualDate)
    }

    if let date = dict["activeDate"] as? String!, actualDate = date {
      activeDate = SWAPIEndpoint.dateFromSWAPIDate(actualDate)
    }
  }
}
