import Foundation

public class SWLog: SWAPIEndpoint {

  public enum ObjectType {
    case Store
  }

  static let endpointURL = NSURL(string: "/log", relativeToURL: baseURL)!

  var id: String
  var tag: String
  var object: String?
  var objectIdentifier: String?
  var value: AnyObject?
  var addedDate: NSDate
  var completeDate: NSDate?

  convenience init(dictionary: [String : AnyObject]) {
    let dateAdded = dictionary["addedDate"] as! String
    let added = SWAPIEndpoint.dateFromSWAPIDate(dateAdded)!
    let id = dictionary["id"] as! String
    let tag = dictionary["tag"] as! String
    let object = dictionary["object"] as? String
    let identifier = dictionary["identifier"] as? String

    var complete: NSDate?
    if let completed = dictionary["completeDate"] as? String {
      complete = SWAPIEndpoint.dateFromSWAPIDate(completed)
    }
    self.init(id: id,
             tag: tag,
           value: dictionary["value"] as? NSDictionary,
          object: object,
objectIdentifier: identifier,
       addedDate: added,
    completeDate: complete)
}

  init(id: String, tag: String, value: NSDictionary?, object: String?, objectIdentifier: String?, addedDate: NSDate, completeDate: NSDate? = nil) {
    self.id = id
    self.tag = tag
    self.value = value
    self.object = object
    self.objectIdentifier = objectIdentifier
    self.addedDate = addedDate
    self.completeDate = completeDate
    super.init()
  }

  func updateWithLog(log: SWLog) {
    self.id = log.id
    self.tag = log.tag
    self.value = log.value
    self.object = log.object
    self.objectIdentifier = log.objectIdentifier
    self.addedDate = log.addedDate
    self.completeDate = log.completeDate
  }

  public func saveToServer(completion: ((errors: [ErrorType]?)-> Void)?) {
    SWLog.postLogWithId(id, tag: tag, value: value, completeDate: completeDate, object: object, identifier: objectIdentifier) { (log, errors) -> Void in
      if let errors = errors {
        //TODO: remove internal errors
        completion?(errors: errors)
      } else if let log = log {
        self.updateWithLog(log)
        completion?(errors: nil)
      }
    }
  }

  public class func getLogsWithTag(tag: String, forObjects objects : String, withIdentifiers identifiers:[String], completion:((logs: [String : SWLog]?, errors: [ErrorType]?) -> Void)) {
    let group = dispatch_group_create()
    var logs = [String : SWLog]()
    var errors = [ErrorType]()
    for identifier in identifiers {
      dispatch_group_enter(group)
      getLogWithId(nil, tag: tag, forObjects: objects, withIdentifier: identifier, completion: { (newLogs, newErrors) -> Void in
        if let newLogs = newLogs {
          for (key, value) in newLogs {
            logs[key] = value
          }
        }
        if let newErrors = newErrors {
          errors.appendContentsOf(newErrors)
        }
        dispatch_group_leave(group)
      })
    }
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
      if errors.count == 0 {
        completion(logs: logs, errors: nil)
      } else if logs.count == 0 {
        completion(logs: nil, errors: errors)
      } else {
        completion(logs: logs, errors: errors)
      }
    }
  }

  public class func getLogsWithTag(tag: String, forObjects objects : String, withIdentifier identifier: String, completion:((logs: [String : SWLog]?, errors: [ErrorType]?) -> Void)) {
    self.getLogWithId(nil, tag: tag, forObjects: objects, withIdentifier: identifier, completion: completion)
  }

  class func getLogWithId(id: String?,tag: String?, forObjects objects: String?, withIdentifier identifier: String?, completion:((logs: [String : SWLog]?, errors: [ErrorType]?) -> Void)) {
    var headers = [String : String]()
    if let tag = tag {
      headers["tag"] = tag
    }
    if let objects = objects {
      headers["object"] = objects
    }
    if let id = id {
      headers["id"] = id
    }
    if let identifier = identifier {
      headers["identifier"] = String(identifier)
    }

    getWithHeaders(headers, body: nil, url: endpointURL) { (result, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove internal errors
        completion(logs:nil, errors: errors)
      } else if let result = result {
        let logs = result["log"] as! [String : AnyObject]
        var ledger = [String : SWLog]()
        for (_,value) in logs {
          if let value = value as? [String : AnyObject] {
            let log = SWLog(dictionary: value)
            ledger[log.id] = log
          }
        }
        completion(logs: ledger, errors: nil)

      }
    }
  }

  class func postLogWithId(id: String, tag: String, value: AnyObject?, completeDate: NSDate? = nil, completion:((log: SWLog?, errors: [ErrorType]?) -> Void)?) {
    postLogWithId(id, tag: tag, value: value, completeDate: completeDate, object: nil, identifier: nil, completion: completion)
  }

  class func postLogWithTag(tag: String, object: String, objectIdentifier identifier: String, value: AnyObject?, completeDate: NSDate? = nil, completion:((log: SWLog?, errors: [ErrorType]?) -> Void)?) {
    postLogWithId(nil, tag: tag, value: value, completeDate: completeDate, object: object, identifier: identifier, completion:  completion)
  }


  private class func postLogWithId(id: String?, tag: String, value: AnyObject? = nil, completeDate: NSDate? = nil, object: String?, identifier: String?, completion:((log: SWLog?, errors: [ErrorType]?) -> Void)?) {
    var headers = [
      "tag" : tag
    ]

    if let object = object {
      headers["object"] = object
    }

    if let identifier = identifier {
      headers["identifier"] = identifier
    }

    if let id = id {
      headers["id"] = id
    }
    if let completeDate = completeDate {
      let timeSinceComplete = Int(NSDate().timeIntervalSinceDate(completeDate))

      headers["completed"] = timeSinceComplete == 0 ? "true" : String(timeSinceComplete)
    }

    postWithHeaders(headers, body: value, url: endpointURL) { (result, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove internal Errors
        completion?(log: nil, errors: errors)
      } else if let result = result {
        let response = result["log"] as! [String : AnyObject]
        let log = SWLog(dictionary: response)
        completion?(log: log, errors: nil)
      }
    }
  }
}
