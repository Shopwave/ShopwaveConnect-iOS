import Foundation

public class SWEmployeeContext: SWUserContext {
  static let rolesWhichMayTakeStock = Set<Role>(arrayLiteral: .Owner, .Manager, .AssistantManager)
  
  public enum Role: UInt {
    case Owner = 1
    case Manager = 2
    case Assistant = 3
    case Guest = 4
    case AssistantManager = 5
  }

  let merchantRole: Role
  let merchantId: UInt

  let storeRoles: [SWStore : Role]
  let activeAtStore: [SWStore : NSDate?]


  // MARK: Initializers
  init(merchantRole role: Role, merchantId id: UInt, storeRoles stores: [SWStore : Role]?, activeAtStore active: [SWStore : NSDate?]?) {
    self.merchantRole = role
    self.merchantId = id
    self.storeRoles = (stores == nil) ? [SWStore : Role]() : stores!
    self.activeAtStore = (active == nil) ? [SWStore : NSDate?]() : active!
    super.init()
  }

  convenience init?(fromDictionary dict: [String : AnyObject]) {
    var merchantRole: Role?
    if let roleId = dict["roleId"] as? UInt, role = Role(rawValue: roleId) {
      merchantRole = role
    }
    let merchantId = dict["merchantId"] as? UInt
    var storeRoles = [SWStore : Role]()
    var activeStores = [SWStore : NSDate?]()

    if let stores = dict["stores"] as? [UInt : [String : AnyObject]] {
      for (storeId, storeDictionary) in stores {
        let store = SWStore.allStores[storeId]
        if let storeRole = storeDictionary["roleId"] as? Role, store = store {
          storeRoles[store] = storeRole
        }
        if let activeDate = dict["activeDate"] as? String, store = store {
          let active = SWAPIEndpoint.dateFromSWAPIDate(activeDate)
          activeStores[store] = active
        } else if store != nil {
          activeStores[store!] = nil
        }
      }
    }
    if let merchantId = merchantId, merchantRole = merchantRole {
      self.init(merchantRole: merchantRole,
                  merchantId: merchantId,
                  storeRoles: storeRoles,
               activeAtStore: activeStores)
    } else {
      return nil
    }
  }

  // MARK: Permissions
  func mayPerformStocktake(forStore store:SWStore) -> Bool {
    var storeRole: Role
    if storeRoles.count == 0 {
      storeRole = merchantRole
    } else {
      if let role = storeRoles[store] where activeAtStore[store] != nil {
        storeRole = role
      } else { // If there are stores defined, unlisted stores and inactive stores are a "no"
        return false
      }
    }
    return SWEmployeeContext.rolesWhichMayTakeStock.contains(storeRole)
  }
}
