import Foundation

public class SWStockReconciliation: NSObject {
  let product: SWProduct
  var hasDetails: Bool {
    return notes != ""
  }
  var notes: String
  var expectedCount: Int
  var actualCount: UInt
  var discrepancy: Int {
    return Int(actualCount) - expectedCount
  }

  public init(product: SWProduct, expectedCount: Int, actualCount: UInt, notes: String = "") {
    self.product = product
    self.actualCount = actualCount
    self.expectedCount = expectedCount
    self.notes = notes
  }
}
