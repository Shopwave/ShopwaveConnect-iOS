import SafariServices

let keychainAccessTokenKey = "ShopwaveConnectAccessToken"
let keychainRefreshTokenKey = "ShopwaveConnectRefreshToken"
let keychainTokenExpirationKey = "ShopwaveConnectTokenExpiration"

let baseURL = NSURL(string: "https://secure.merchantstack.com/")!
let logoutURL = NSURL(string: "logout", relativeToURL: baseURL)!
let authURL = NSURL(string: "oauth/authorize", relativeToURL: baseURL)!
let tokenURL = NSURL(string: "oauth/token", relativeToURL: baseURL)!

public typealias SWAuthCompletion = ((error: SWAuth.Error?) -> Void)

public class SWAuth {
  //MARK: Private Variables
  static var refreshToken: String?
  static var tokenExpiration: NSDate?
  static var authVC: SFSafariViewController?
  static var priorScopes: [Scope]?
  static var lastCompletion: SWAuthCompletion?

  //MARK: Public Variables
  public static var customURL: String?
  /// The Client ID for an implementing app. Must be set before authentication may occur.
  public static var clientId: String?
  /// The Client Secret for an implementing app. Must be set before authentication may occur.
  public static var clientSecret: String?
  /// The access token needed to access Shopwave Connect APIs
  public internal(set) static var accessToken: String?
  /// Indicates whether it is an advantagous time to renew access credentials to the Shopwave server
  public static var shouldReAuth: Bool {
      /*
      If the token expiration date is earlier than now, the token is expired and so we should reauth
      */
      return (accessToken == nil) || (tokenExpiration == nil) || (tokenExpiration?.compare(NSDate()) == NSComparisonResult.OrderedAscending)
  }
  //MARK: Public Methods
  /**
  The method used to begin the Shopwave Connect authentication process.
  - parameter scopes:An array of SWAuth.Scopes for which to authorise this client
  - parameter onViewController:A UIViewController which will present the authentication view
  controller modally
  - parameter completion:A set of instructions to follow after authentication is complete.
  - returns: success, a boolean, and error, if one exists
  - Note: SWAuth.clientId and SWAuth.clientSecret must be set, and SWAuth.handleOpenURL(url:) must
  be called in the App Delegate for authentication to proceed. Further, a custom URL scheme or
  universal link must be registered to this app.
  */
  public class func authenticateWithScopes(scopes: [Scope], onViewController vc: UIViewController,
    completion: SWAuthCompletion?) {
      if clientId == nil {
        fatalError("SWAuth.ClientId must be set in App Delegate before attempting to authenticate.")
      }
      if clientSecret == nil {
        fatalError("SWAuth.ClientSecret must be set in App Delegate before attempting to authenticate.")
      }
      if customURL == nil {
        fatalError("SWAuth.customURL must be set in App Delegate before attempting to authenticate.")
      }

      if shouldReAuth == false {
        completion?(error: nil)
        return
      }
      /*
      We only want to refresh if we have an expired access token, a refresh token, and if there are
      no additional scopes needed
      */
      if refreshToken != nil && shouldReAuth && priorScopes != nil && scopes == priorScopes! {
        refreshTokensWithCompletion(completion)
      } else {
        priorScopes = scopes
        let requestID = NSUUID()
        self.lastCompletion = completion
        authVC = SFSafariViewController(URL: authURLForScopes(scopes, uuid:requestID), entersReaderIfAvailable:false)
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
          vc.presentViewController(authVC!, animated: true, completion: nil)
        })
      }
  }

  /**
  Used to reauthenticate for last used scopes.
  - parameter viewController:In case user interaction is required, it will be presented modally on
  this view controller
  - parameter completion:A set of instructions to follow after authentication is complete.
  - returns: success, a boolean, and error, if one exists
  - SeeAlso: authenticateWithScopes(scopes,onViewController,completion)
  */
  public class func reAuthOnViewController(viewController: UIViewController,
    completion:SWAuthCompletion?) {
      if priorScopes == nil {
        completion?(error: .NoScopesSet)
      }
      self.authenticateWithScopes(priorScopes!, onViewController: viewController, completion: completion)
  }

  /**
  Used to log out the current user.
  */
  public class func logOut(onViewController vc: UIViewController, completion: SWAuthCompletion) {
    refreshToken = nil
    tokenExpiration = nil
    authVC = nil
    priorScopes = nil
    lastCompletion = nil
    let requestID = NSUUID()
    self.lastCompletion = completion
    authVC = SFSafariViewController(URL: logoutURLForUUID(requestID), entersReaderIfAvailable: false)
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      vc.presentViewController(authVC!, animated: true, completion: nil)
    }
  }

  /**
  Required to be called in an implementing app's AppDelegate in the handleOpenURL method
  - parameter url:The same URL passed to the App Delegate's handleOpenURL method
  - returns: true if url was a response to a SWAuth action, false if unrelated
  */
  public class func handleOpenURL(url: NSURL) -> Bool {
    let decomposedURL = NSURLComponents(URL: url, resolvingAgainstBaseURL: true)
    var code: String?

    if decomposedURL?.host == "logout" {
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        authVC?.dismissViewControllerAnimated(true, completion: { () -> Void in
          lastCompletion?(error: nil)
        })
      })
      return true
    } else if decomposedURL?.host == "login" {
      //var requestId: String?
      for queryItem in (decomposedURL?.queryItems)! {
        if queryItem.name == "code" {
          code = queryItem.value
        } else if queryItem.name == "requestId" {
          //requestId = queryItem.value
        }
      }
      // url is an auth code from a SFSafariViewController
      if code != nil {//&& requestId != nil {
        //handleAuthCode(code!, forRequest:NSUUID(UUIDString:requestId!)!)
        handleAuthCode(code!, forRequest:NSUUID())
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  //MARK: Private Methods
  class func authURLForScopes(scopes: [Scope], uuid: NSUUID) -> NSURL {
    let endpoints = getEndpointsForScopes(scopes)
    var queryItems: [NSURLQueryItem] = []
    queryItems.append(NSURLQueryItem(name: "access_type", value: "online"))
    queryItems.append(NSURLQueryItem(name: "redirect_uri", value: customURL! + "login"))
    queryItems.append(NSURLQueryItem(name: "response_type", value: "code"))
    queryItems.append(NSURLQueryItem(name: "client_id", value: clientId))
    queryItems.append(NSURLQueryItem(name: "scope", value: endpoints.joinWithSeparator(",")))
    //queryItems.append(NSURLQueryItem(name: "requestId", value: uuid.UUIDString))

    let components = NSURLComponents(URL: authURL, resolvingAgainstBaseURL: true)
    components?.queryItems = queryItems
    return (components?.URL)!
  }

  class func logoutURLForUUID(uuid: NSUUID) -> NSURL {
    var queryItems: [NSURLQueryItem] = []
    queryItems.append(NSURLQueryItem(name: "redirect_uri", value: customURL! + "logout"))
    queryItems.append(NSURLQueryItem(name: "redirect", value: "true"))
    //queryItems.append(NSURLQueryItem(name: "requestId", value: uuid.UUIDString))

    let components = NSURLComponents(URL: logoutURL, resolvingAgainstBaseURL: true)
    components?.queryItems = queryItems
    return (components?.URL)!
  }

  class func handleAuthCode(authCode: String, forRequest:NSUUID) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      authVC?.dismissViewControllerAnimated(true, completion: nil)
    }
    fetchTokensForAuthCode(authCode, completion:lastCompletion!)
  }

  class func fetchTokensForAuthCode(authCode:String, completion:SWAuthCompletion?) {
    let request = NSMutableURLRequest(URL: tokenURL)
    request.HTTPMethod = "POST"

    let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: true)
    var queryItems: [NSURLQueryItem] = []
    queryItems.append(NSURLQueryItem(name: "access_type", value: "online"))
    queryItems.append(NSURLQueryItem(name: "redirect_uri", value: customURL! + "login"))
    queryItems.append(NSURLQueryItem(name: "response_type", value: "code"))
    queryItems.append(NSURLQueryItem(name: "client_id", value: self.clientId))
    queryItems.append(NSURLQueryItem(name: "scope", value: "application"))
    queryItems.append(NSURLQueryItem(name: "client_secret", value: self.clientSecret))
    queryItems.append(NSURLQueryItem(name: "grant_type", value: "authorization_code"))
    queryItems.append(NSURLQueryItem(name: "code", value: authCode))
    components?.queryItems = queryItems

    request.HTTPBody = components?.query!.dataUsingEncoding(NSUTF8StringEncoding)

    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, res, error in
      if error != nil {
        completion?(error: .InternalError)
        return
      }
      do {
        let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
        self.accessToken = response["access_token"] as? String
        self.refreshToken = response["refresh_token"]as? String
        self.tokenExpiration = NSDate(timeIntervalSinceNow: response["expires_in"] as! NSTimeInterval)
        SWUser.getCurrentUser({ (user, error) -> Void in
          if error != nil {
            completion?(error: nil)
          }
        })
      } catch {
        completion?(error: .InternalError)
        return
      }
    }
    task.resume()
  }

  class func refreshTokensWithCompletion(completion:SWAuthCompletion?) {
    let request = NSMutableURLRequest(URL: tokenURL)
    request.HTTPMethod = "POST"

    let components = NSURLComponents(URL: request.URL!, resolvingAgainstBaseURL: false)
    var queryItems: [NSURLQueryItem] = []
    queryItems.append(NSURLQueryItem(name: "access_type", value: "online"))
    queryItems.append(NSURLQueryItem(name: "redirect_uri", value: customURL))
    queryItems.append(NSURLQueryItem(name: "response_type", value: "code"))
    queryItems.append(NSURLQueryItem(name: "client_id", value: self.clientId))
    queryItems.append(NSURLQueryItem(name: "scope", value: "application"))
    queryItems.append(NSURLQueryItem(name: "client_secret", value: self.clientSecret))
    queryItems.append(NSURLQueryItem(name: "grant_type", value: "refresh_token"))
    queryItems.append(NSURLQueryItem(name: "refresh_token", value: self.refreshToken))
    components?.queryItems = queryItems

    request.HTTPBody = components?.query!.dataUsingEncoding(NSUTF8StringEncoding)

    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, res, error in
      if error != nil {
        completion?(error: .InternalError)
        return
      }
      do {
        let response = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
        self.accessToken = response["access_token"] as? String
        self.tokenExpiration = NSDate(timeIntervalSinceNow: response["expires_in"] as! NSTimeInterval)
        completion?(error: nil)
        return
      } catch {
        completion?(error: .InternalError)
        return
      }
    }
    task.resume()
  }

  //MARK: Utilities

  class func getEndpointsForScopes(scopes: [Scope]) -> [String] {
    var endpointArray: [String] = []
    for scope in scopes {
      endpointArray.append(endpoints[scope]!)
    }
    return endpointArray
  }

  static let endpoints: [Scope: String] = [
    .User: "user",
    .Application: "application",
    .Baskets: "basket",
    .Categories: "category",
    .Merchant: "merchant",
    .Store: "store",
    .Supplier: "supplier",
    .SupplierStore: "supplierStore",
    .Stock: "stock",
    .Invoice: "invoice",
    .Products: "product",
    .Log: "log",
    .Promotions: "promotion"
  ]

  public enum Scope {
    /**
    Allows you to get your user information and invite other users for your channel.
    */
    case User
    /**
    Helps you create an app identifier and secret, get your app details and delete any unwanted apps.
    */
    case Application
    /**
    Helps you create, get and delete baskets, basket products, attach promotions to a basket and
    transactions. If merchants stocks management is enabled, an automatic stock recalculations will
    happen in the background.
    */
    case Baskets
    /**
    Create, update, get and delete a merchant's categories.
    */
    case Categories
    /**
    Allows you to get, create, update and delete your merchant information. Remember merchant is the
    root of all information about that merchant. Deleting a merchant may cause loosing sales,
    products, promotion data for that
    */
    case Merchant
    /**
    Allows you to get, create, update and delete store information. With store endpoint you can not
    only store address, but latitude and longitude for that location. Which is helpful for all your
    location based apps.
    */
    case Store
    /**
    Allows you to get, create, update and delete supplier information. With suppliers you can keep all
    your contacts in one place.
    */
    case Supplier
    /**
    Allows you to get, create, update and delete supplier store information. This is also a location
    based storage.
    */
    case SupplierStore
    /**
    Allows you to post us the stock discrepancies when you do a stock take. This will recalculate the
    stock.
    */
    case Stock
    /**
    Merchants' wants to store all there expenses. This invoice endpoint can be used exactly for this
    purpose. You can also add product stock invoices which will recalculate the stocks for the
    products.
    */
    case Invoice
    /**
    Allows you to get, create, update and delete your products. We have a comprehensive query platform
    for our product.
    */
    case Products
    /**
    Log is our big data storage API. You can make use of it for all your application log.
    */
    case Log
    /**
    Allows you to get, create, update and delete promotions and generate promotion code. Promotion can
    be product, category or basket based.
    */
    case Promotions
  }

  public enum Error: ErrorType {
    /// Found when an implementing app did not set their ClientID before invoking authentication
    case ClientIdNotSet
    /// Found when an implementing app did not set their Client secret before invoking authentication
    case ClientSecretNotSet
    /// Found when SWAuth.reAuthOnViewController was called before SWAuth.authenticateWithScopes
    case NoScopesSet
    /// Found when an underlying error occurred. Please file a bug report.
    case InternalError
  }
}

let test: [SWAuth.Scope: String] = [
  .User: "user",
  .Application: "applicatoin"
]

