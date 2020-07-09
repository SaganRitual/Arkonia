import CoreGraphics

enum ChamberID { case fat, ham, na, oxygen, vitaminB, vitaminL }

class ChamberedStore: Protoplasm, HasCompartments, HasMass, HasSelectableStore {
    typealias SelectType = OozeStorage

    static func fill(_ store: ChamberedStore) {
        store.allCompartments.forEach { $0.deposit($0.availableCapacity) }
    }

    let capacityMultiplier: CGFloat

    let maintCostOozePerCap: CGFloat
    let maintCostWorkPerCap: CGFloat
    let mfgCostOozePerCap:   CGFloat
    let mfgCostWorkPerCap:   CGFloat

    let organID: OrganID
    let fatStore: OozeStorage?  // Spawn/embryo have fat stores, stomach does not
    let hamStore: OozeStorage
    let oxygenStore: OozeStorage
    let vitaminBStore: OozeStorage
    let vitaminLStore: OozeStorage

    let allCompartments: [OozeStorage]

    var mass: CGFloat { allCompartments.reduce(0) { $0 + $1.mass } * RealWorldConversions.arkoniaKgPerRealKg }

    init(_ organID: OrganID, _ capacityMultiplier: CGFloat) {
        self.organID = organID
        self.fatStore = (organID == .stomach) ? nil : OozeStorage(organID, .fat)
        self.hamStore = OozeStorage(organID, .ham)
        self.oxygenStore = OozeStorage(organID, .oxygen)
        self.vitaminBStore = OozeStorage(organID, .vitaminB)
        self.vitaminLStore = OozeStorage(organID, .vitaminL)

        self.allCompartments = [fatStore, hamStore, oxygenStore, vitaminBStore, vitaminLStore].compactMap { $0 }

        self.capacityMultiplier = capacityMultiplier

        self.maintCostWorkPerCap = capacityMultiplier * allCompartments.reduce(0) { $0 + $1.maintCostWorkPerCap }
        self.maintCostOozePerCap = capacityMultiplier * allCompartments.reduce(0) { $0 + $1.maintCostOozePerCap }
        self.mfgCostWorkPerCap =   capacityMultiplier * allCompartments.reduce(0) { $0 + $1.mfgCostWorkPerCap }
        self.mfgCostOozePerCap =   capacityMultiplier * allCompartments.reduce(0) { $0 + $1.mfgCostOozePerCap }
    }

    func selectStore(_ organID: OrganID) -> OozeStorage? {
        switch organID {
        case .bone:     return vitaminBStore
        case .energy:   return hamStore
        case .fatStore: return fatStore
        case .leather:  return vitaminLStore
        case .lungs:    return oxygenStore

        default: fatalError()
        }
    }
}
