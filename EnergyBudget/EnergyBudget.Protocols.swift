import Foundation

protocol HasCapacity: HasCapacityCosts {
    var capacity: CGFloat { get }
}

protocol HasMass {
    var mass: CGFloat { get }
}

protocol HasCapacityCosts {
    var maintCostOozePerCap: CGFloat { get }
    var maintCostWorkPerCap: CGFloat { get }
    var mfgCostOozePerCap:   CGFloat { get }
    var mfgCostWorkPerCap:   CGFloat { get }
}

protocol HasCompartments: HasCapacityCosts {
    var hamStore: OozeStorage { get }
    var oxygenStore: OozeStorage { get }
    var vitaminBStore: OozeStorage { get }
    var vitaminLStore: OozeStorage { get }
}

protocol HasSelectableStore {
    associatedtype SelectType
    func selectStore(_ organID: OrganID) -> SelectType?
}

protocol OrganProtocol {
    var storage: OozeStorage { get }
}

protocol Protoplasm {}

protocol StorageProtocol: class, HasCapacity, HasMass {
    var availableCapacity: CGFloat { get }
    var level: CGFloat { get set }

    func deposit(_ quantity: CGFloat) -> CGFloat
    func withdraw(_ quantity: CGFloat?) -> CGFloat
}

extension StorageProtocol {
    @discardableResult
    func deposit(_ quantity: CGFloat) -> CGFloat {
        let net = min(quantity, availableCapacity)
        level += net
        Debug.log(level: 179) { "StorageProtocol.deposit(\(quantity)) -> \(net)" }
        return net
    }

    @discardableResult
    func withdraw(_ quantity: CGFloat?) -> CGFloat {
        let qq = quantity ?? level
        let net = min(level, qq)
        level -= net
        Debug.log(level: 179) { "StorageProtocol.withdraw(\(quantity ?? -1)) -> \(net)" }
        return net
    }
}
