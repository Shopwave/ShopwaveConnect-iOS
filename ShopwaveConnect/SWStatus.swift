import Foundation

public class SWStatus: SWAPIEndpoint {
  static let endpointURL = NSURL(string: "/status", relativeToURL: baseURL)!

  public static private(set) var lastServerStatus: String?
  public static private(set) var lastServerTimestamp: NSDate?
  public static private(set) var lastCheckTimestamp: NSDate?

  public class func getStatus(completion:(available: Bool, serverTimestamp: NSDate?, errors: [ErrorType]?) -> Void) {
    getWithHeaders(nil, body: nil, url: endpointURL) { (_, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove Internal Errors
        completion(available: false, serverTimestamp: nil, errors: errors)
      } else if let headers = headers {
        if let statusCode = headers["statusCode"], timestampString = headers["Date"] {
          let available = (UInt(statusCode) == 200)
          let df = NSDateFormatter()
          df.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
          let timestamp = df.dateFromString(timestampString)
          completion(available: available, serverTimestamp: timestamp, errors: nil)
        }
      }
    }
  }
}
