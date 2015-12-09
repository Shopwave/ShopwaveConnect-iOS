import AddressBook
import Contacts
import CoreLocation
import Foundation

public class SWStore: SWAPIEndpoint {
  static let endpointURL = NSURL(string: "/store", relativeToURL: baseURL)!
  static var allStores = [UInt : SWStore]() {
    didSet{
      activeStores.removeAll()
      for (id, store) in allStores {
        if store.active {
          activeStores[id] = store
        }
      }
    }
  }
  static private(set) var activeStores = [UInt: SWStore]()

  var id: UInt
  var location: CLLocation?
  var addressLine1: String
  var addressLine2: String?
  var addressLine3: String?
  var phoneNumber: CNPhoneNumber?
  var city: String
  var postcode: String
  var countryId: String?
  var timezoneId: UInt?
  var storeDeleteDate: NSDate?
  var active: Bool {
    return storeDeleteDate == nil
  }
  var fullAddress: String {
    let addressComponents = [addressLine1, addressLine2, addressLine3, city, postcode]
    let address = SWAPIEndpoint.removeNils(fromArray: addressComponents)
    return SWAPIEndpoint.arrayToString(withSeparator: ", ", array: address)
  }

  class func getStores(completion:((stores: [UInt : SWStore]?, errors: [ErrorType]?) -> Void)?) {
    getStoresWithStoreIds(nil, completion: completion)
  }

  class func getStoresWithStoreIds(storeIds: [UInt]?, completion:((stores: [UInt : SWStore]?, errors: [ErrorType]?) -> Void)?) {
    var headers: [String : String]?
    if let storeIds = storeIds {
      headers = [
        "storeIds" : arrayToString(storeIds)
      ]
    }

    getWithHeaders(headers, body: nil, url: endpointURL) { (result, headers, errors) -> Void in
      if let errors = errors {
        // TODO: Remove internal errors
        completion?(stores: nil, errors: errors)
      } else if let result = result {
        let response = result["stores"] as! [String : AnyObject]
        var retrievedStores = [UInt : SWStore]()
        for (_, dict) in response {
          let store = SWStore(fromDictionary: dict as! [String:AnyObject])
          retrievedStores[store.id] = store
        }
        // Only update singleton's SWStore cache if we retrieved all the stores.
        if storeIds == nil {
          allStores = retrievedStores
        }
        completion?(stores: retrievedStores, errors: nil)
      }
    }
  }

  init(id: UInt, addressLine1: String, addressLine2: String? = nil, addressLine3: String? = nil, city: String, postcode: String, location: CLLocation? = nil,  phoneNumber: CNPhoneNumber? = nil,  countryId: String? = nil, timezoneId: UInt? = nil, storeDeleteDate: NSDate? = nil) {
    self.id = id
    self.location = location
    self.addressLine1 = addressLine1
    self.addressLine2 = addressLine2
    self.addressLine3 = addressLine3
    self.phoneNumber = phoneNumber
    self.city = city
    self.postcode = postcode
    self.countryId = countryId
    self.timezoneId = timezoneId
    self.storeDeleteDate = storeDeleteDate
    super.init()
  }

  convenience init(fromDictionary dictionary: [String : AnyObject]) {
    let id = dictionary["id"] as! UInt
    let addressLine1 = dictionary["addressLine1"] as! String
    let city = dictionary["city"] as! String
    let postcode = dictionary["postcode"] as! String
    let lat = dictionary["lat"] as! CLLocationDegrees
    let lng = dictionary["lng"] as! CLLocationDegrees

    let addressLine2 = dictionary["addressLine2"] as? String
    let addressLine3 = dictionary["addressLine3"] as? String
    let countryId = dictionary["countryId"] as? String
    let timezoneId = dictionary["timezoneId"] as? UInt

    var phoneNumber: CNPhoneNumber?
    var location: CLLocation?
    var storeDeleteDate: NSDate?

    if let phone = dictionary["phoneNumber"] as? String {
      phoneNumber = CNPhoneNumber(stringValue: phone)
    }
    if lat != 0 || lng != 0 {
      location = CLLocation(latitude: lat, longitude: lng)
    }
    if let deleted = dictionary["storeDeleteDate"] as? String {
      storeDeleteDate = SWAPIEndpoint.dateFromSWAPIDate(deleted)
    }

    self.init(id: id, addressLine1: addressLine1, addressLine2: addressLine2, addressLine3: addressLine3, city: city, postcode: postcode, location: location, phoneNumber: phoneNumber, countryId: countryId, timezoneId: timezoneId, storeDeleteDate: storeDeleteDate)
  }
}