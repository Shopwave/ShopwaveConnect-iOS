import Foundation

public class SWUser: SWAPIEndpoint {
  static let endpointURL = NSURL(string: "/user", relativeToURL: baseURL)!
  static public private(set) var currentUser: SWUser?

  let id: UInt
  let firstName: String?
  let lastName: String?
  let email: String

  let contexts: [SWUserContextType : SWUserContext]

  public class func getCurrentUser(completion:((user: SWUser?, errors: [ErrorType]?)-> Void)?) {
    getWithHeaders(nil, body: nil, url: endpointURL) { (result, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove Internal Errors
        completion?(user: nil, errors: errors)
      } else if let result = result, userDictionary = result["user"] as? [String : AnyObject] {
        let user = SWUser(fromDictionary: userDictionary)
        self.currentUser = user
        completion?(user: user, errors: nil)
      }
    }
  }

  init(id: UInt, firstName: String?, lastName: String?, email: String,
    contexts: [SWUserContextType : SWUserContext] = [SWUserContextType : SWUserContext]() ) {
      self.id = id
      self.firstName = firstName
      self.lastName = lastName
      self.email = email
      self.contexts = contexts
      super.init()
  }

  convenience init(fromDictionary dictionary: [String : AnyObject]) {
    let id = dictionary["id"] as! UInt
    let email = dictionary["email"] as! String

    let firstName = dictionary["firstName"] as? String
    let lastName = dictionary["lastName"] as? String

    var contexts = [SWUserContextType : SWUserContext]()
    if let employee = dictionary["employee"] as? [String : AnyObject],
      employeeContext = SWEmployeeContext(fromDictionary: employee) {
        contexts[.Employee] = employeeContext
    }

    self.init(id: id, firstName: firstName, lastName: lastName, email: email, contexts: contexts)
  }
}
