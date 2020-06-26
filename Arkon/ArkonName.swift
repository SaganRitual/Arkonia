import Foundation

func AKName(_ name: ArkonName?) -> String {
    if let n = name { return n.debugDescription }
    return "<no name>"
}

struct ArkonName: Hashable, CustomDebugStringConvertible {
    enum Nametag: CaseIterable {
        case alice, bob, charles, david, ellen, felicity, grace, helen
        case india, james, karen, lizbeth, mary, nathan, olivia, paul
        case quincy, rob, samantha, tatiana, ulna, vivian, william
        case xavier, yvonne, zoe

        // Fix cRealnames if you add or remove here. Yes, it's ugly. Sue me
        case embryo, line, manna, neuron, empty, offgrid
    }

    static var cRealNames = Nametag.allCases.count - 6
    static var nameix = 0
    static var setNumber = 0

    static func makeName() -> ArkonName {
        defer {
            nameix += 1
            if (nameix % cRealNames) == 0 { setNumber += 1 }
        }

        let newName = ArkonName(
            nametag: Nametag.allCases[nameix % cRealNames],
            setNumber: setNumber
        )

        return newName
    }

    static let embryo     = ArkonName(nametag: .embryo, setNumber: 0)
    static let empty      = ArkonName(nametag: .empty, setNumber: 0)
    static let line       = ArkonName(nametag: .line, setNumber: 0)
    static let neuron     = ArkonName(nametag: .neuron, setNumber: 0)
    static let offgrid    = ArkonName(nametag: .offgrid, setNumber: 0)

    let debugDescription: String
    let nametag: Nametag
    let setNumber: Int

    private init(nametag: ArkonName.Nametag, setNumber: Int) {
        self.debugDescription = "\(nametag)(\(setNumber))"
        self.nametag = nametag
        self.setNumber = setNumber
    }

    static func == (_ lhs: ArkonName, _ rhs: ArkonName) -> Bool {
        return lhs.nametag == rhs.nametag && lhs.setNumber == rhs.setNumber
    }
}
