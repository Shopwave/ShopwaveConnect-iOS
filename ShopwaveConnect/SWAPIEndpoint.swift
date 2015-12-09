import Foundation

public class SWAPIEndpoint: NSObject {
  static let baseURL = NSURL(string: "https://api.merchantstack.com/")
  static let dateFormatter = NSDateFormatter()
  static var apiVersion = 0.6

  //MARK: Utilities
  class func arrayToString(array:[AnyObject]) -> String {
    return arrayToString(withSeparator: ",", array: array)
  }

  class func arrayToString(withSeparator separator: String, array:[AnyObject]) -> String {
    return array.map({ (object) -> String in
      return object.description
    }).joinWithSeparator(separator)
  }

  class func removeNils<T>(fromArray array: [T?]) -> [T] {
    return array.filter{ $0 != nil }.map({ $0! })
  }

  public class func dateFromSWAPIDate(string: String) -> NSDate? {
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return dateFormatter.dateFromString(string)
  }

  class func responseForRequest(request:NSURLRequest, completion:((responseObject: [String : AnyObject]?, responseHeaders: [String : String]? , errors: [ErrorType]?) -> Void)) {
    let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, res, error in
      if let error = error {
        completion(responseObject: nil, responseHeaders: nil, errors: [error])
        return
      } else {
        let res = res as! NSHTTPURLResponse
        var responseHeaders = [String : String]()
        for (key, value) in res.allHeaderFields {
          responseHeaders[key as! String] = value as? String
        }
        responseHeaders["statusCode"] = String(res.statusCode)
        if res.statusCode > 400 {
          let errors = [errorForServerStatusCode(UInt(res.statusCode), withDetails: nil)]
          completion(responseObject: nil, responseHeaders: responseHeaders, errors: errors)
          return
        }
        if let data = data where data.length > 0 {
          do {
            let response = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers)
            completion(responseObject: response as? [String : AnyObject], responseHeaders: responseHeaders, errors: nil)
            return
          } catch let error {
            completion(responseObject: nil, responseHeaders: nil, errors: [error])
            return
          }
        } else {
          completion(responseObject: nil, responseHeaders: responseHeaders, errors: nil)
        }
      }
    }
    task.resume()
  }

  class func processRequest(request: NSURLRequest, completion:((result: [String : AnyObject]?, headers: [String : String]?, errors: [ErrorType]?) -> Void)?) {
    responseForRequest(request, completion: { (var responseObject, responseHeaders, serverErrors) -> Void in
      if let serverErrors = serverErrors {
        completion?(result: nil, headers: nil, errors: serverErrors)
        return
      } else if let api = responseObject?["api"] as? [String : AnyObject],
                message = api["message"] as? [String : AnyObject],
                 errors = message["errors"] as? [UInt : AnyObject] {
          var returnableErrors = [ErrorType]()
          for (errorId, details) in errors {
            let errorDetail = details["details"] as? String
            let error = errorForAPIErrorId(errorId, withDetails: errorDetail)
            returnableErrors.append(error)
          }
          completion?(result:nil, headers: nil, errors: returnableErrors)
          return
      } else {
        responseObject?.removeValueForKey("api")
        completion?(result: responseObject, headers: responseHeaders, errors: nil)
      }
    })
  }

  class func requestWithHeaders(headers: [String : String]?, method: String, body: AnyObject?, url: NSURL, completion:((result: [String : AnyObject]?, responseHeaders: [String : String]?, errors: [ErrorType]?) -> Void)?) {
    let request = NSMutableURLRequest(URL: url)
    if let accesstoken = SWAuth.accessToken {
      request.setValue("Bearer " + accesstoken, forHTTPHeaderField: "Authorization")
      request.HTTPMethod = method
      request.setValue(String(apiVersion), forHTTPHeaderField: "x-accept-version")

      if let body = body {
        do {
          let bodyData =  try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(rawValue: 0))
          let body = NSString(format: "postBody=%@", NSString(data: bodyData, encoding: NSUTF8StringEncoding)!)
          request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        } catch let error {
          completion?(result: nil, responseHeaders: nil, errors: [error])
          return
        }
      }

      if let headers = headers {
        for (key, value) in headers {
          request.setValue(value, forHTTPHeaderField: key)
        }
      }

      processRequest(request, completion: completion)
    } else {
      completion?(result: nil, responseHeaders: nil, errors: [SWAPIEndpoint.Error.AuthenticationError(details: "SWAuth.accesstoken is nil")])
    }
  }

  /**
  Used to send a set of headers and data to a URL using HTTP DELETE method.
  - parameter headers: Key/Value pairs which will be added to the request's header section
  - parameter body: An object which will be converted into JSON data and sent in the request's body section
  - parameter url: The URL to send the request
  - parameter completion:A set of instructions to follow after a response is received.
  - SeeAlso: postWithHeaders(headers:body:url:completion:)
  - SeeAlso: getWithHeaders(headers:body:url:completion:)
  */
  public class func deleteWithHeaders(headers: [String : String]?, body: AnyObject?, url: NSURL, completion:((result: [String : AnyObject]?, responseHeaders: [String : String]?, errors: [ErrorType]?) -> Void)?) {
    requestWithHeaders(headers, method: "DELETE", body: body, url: url, completion: completion)
  }

  /**
  Used to send a set of headers and data to a URL using HTTP POST method.
  - parameter headers: Key/Value pairs which will be added to the request's header section
  - parameter body: An object which will be converted into JSON data and sent in the request's body section
  - parameter url: The URL to send the request
  - parameter completion:A set of instructions to follow after a response is received.
  - SeeAlso: postWithHeaders(headers:body:url:completion:)
  - SeeAlso: getWithHeaders(headers:body:url:completion:)
  */
  public class func postWithHeaders(headers: [String : String]?, body: AnyObject?, url: NSURL, completion:((result: [String : AnyObject]?, responseHeaders: [String : String]?, errors: [ErrorType]?) -> Void)?) {
    requestWithHeaders(headers, method: "POST", body: body, url: url, completion: completion)
  }

  /**
  Used to send a set of headers and data to a URL using HTTP GET method.
  - parameter headers: Key/Value pairs which will be added to the request's header section
  - parameter body: An object which will be converted into JSON data and sent in the request's body section
  - parameter url: The URL to send the request
  - parameter completion:A set of instructions to follow after a response is received.
  - SeeAlso: postWithHeaders(headers:body:url:completion:)
  - SeeAlso: getWithHeaders(headers:body:url:completion:)
  */
  public class func getWithHeaders(headers: [String : String]?, body: AnyObject?, url: NSURL, completion:((result: [String : AnyObject]?, responseHeaders: [String : String]?, errors: [ErrorType]?) -> Void)?) {
    requestWithHeaders(headers, method: "GET", body: body, url: url, completion: completion)
  }

  public enum Error: ErrorType {
    /// A valid access token was not found. Use SWAuth to authenticate the user.
    case AuthenticationError(details: String?)
    /// Something went wrong. Please report this error.
    case Unknown(details: String?)
    /// The service went down. Please check back later.
    case ServiceDown(details: String?)
    /// The client_id supplied is invalid
    case InvalidClient(details: String?)
    /// The app is not authorized to use our service.
    case UnauthorisedClient(details: String?)
    /// The redirect_uri supplied is not valid or is not registered with us.
    case RedirectURIMismatch(details: String?)
    /// Access denied for the request
    case AccessDenied(details: String?)
    /// The scope provided is invalid
    case InvalidScope(details: String?)
    /// The grant type requested is invalid
    case InvalidGrant(details: String?)
    /// The token supplied is invalid
    case InvalidToken(details: String?)
    /// Token expired or invalid. Please renew your token
    case ExpiredToken(details: String?)
    /// The code provided is invalid for your client_id
    case InvalidCode(details: String?)
    /// The resource you are looking for does not exist
    case NotFound(details: String?)
    /// The authorization header is invalid. The correct format is Authorization: {token_type} {accessToken}
    case AuthorisationHeaderInvalid(details: String?)
    /// The user does not own this resource and its forbidden
    case ResourceNotAllowedForSpecifiedUser(details: String?)
    /// One or more of the required parameters or object formation is missing in your request. Please refer the documentation.
    case RequiredParameterOrObjectMissingInRequest(details: String?)
    /// One or more of the required parameters or object formation is missing in your request. Please refer the documentation
    case EmailAddressNotValid(details: String?)
    /// There is a limit for every object you can send to our server and you are exceding that.
    case RequestQuotaExceeded(details: String?)
    /// Something went wrong.
    case InternalServerError(details: String?)
    /// The media type is unsupported by the server.
    case UnsupportedMediaType(details: String?)
    /// Promotion code is unique to a basket. Promotion code once used on one basket cannot be used again.
    case UsedPromotionCode(details: String?)
    /// JSON web token is not supplied or found invalid. Please supply a valid HMAC-SHA256 encoded token. The correct format is base64encode(JWT_Header).base64encode(Payload).HMACSHA256(Part1_encodedString, 'shared_secret').
    case JSONWebTokenInvalid(details: String?)
    /// A client-side runtime error has occurred. Please report this as a bug.
    case InternalFrameworkError(details: String?)
  }

  static func errorForServerStatusCode(code: UInt, withDetails details: String?) -> ErrorType {
    switch code {
      case 500:
        return Error.ServiceDown(details: details)
      default:
        return Error.Unknown(details: details)
    }
  }

  static func errorForAPIErrorId(id: UInt, withDetails details: String?) -> ErrorType {
    switch id {
      case 900: 
        return Error.ServiceDown(details: details)
      case 901: 
        return Error.InvalidClient(details: details)
      case 902: 
        return Error.UnauthorisedClient(details: details)
      case 903: 
        return Error.RedirectURIMismatch(details: details)
      case 904: 
        return Error.AccessDenied(details: details)
      case 905: 
        return Error.InvalidScope(details: details)
      case 906: 
        return Error.InvalidGrant(details: details)
      case 907: 
        return Error.InvalidToken(details: details)
      case 908: 
        return Error.ExpiredToken(details: details)
      case 909: 
        return Error.InvalidCode(details: details)
      case 910: 
        return Error.NotFound(details: details)
      case 911: 
        return Error.AuthorisationHeaderInvalid(details: details)
      case 912: 
        return Error.ResourceNotAllowedForSpecifiedUser(details: details)
      case 913: 
        return Error.RequiredParameterOrObjectMissingInRequest(details: details)
      case 914: 
        return Error.EmailAddressNotValid(details: details)
      case 915: 
        return Error.UsedPromotionCode(details: details)
      case 916: 
        return Error.UnsupportedMediaType(details: details)
      case 917: 
        return Error.InternalServerError(details: details)
      case 918: 
        return Error.JSONWebTokenInvalid(details: details)
      case 919: 
        return Error.RequestQuotaExceeded(details: details)
      default:
        return Error.Unknown(details: details)
    }
  }
}