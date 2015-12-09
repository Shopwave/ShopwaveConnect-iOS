import Foundation

class SWStockSurplus: SWStockReconciliation {
  var unitCost: Float
  var taxPercentage: Float
  override var hasDetails: Bool {
    return super.hasDetails || taxPercentage != 0 || unitCost != 0
  }

  init(product: SWProduct, expectedCount: Int, actualCount: UInt, notes: String = "", unitCost: Float = 0, taxPercentage: Float = 0) {
    self.unitCost = unitCost
    self.taxPercentage = taxPercentage
    super.init(product: product, expectedCount: expectedCount, actualCount: actualCount, notes: notes)
  }
}
