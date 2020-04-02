struct ArkonName: Hashable {
    enum Nametag: CaseIterable {
        case alice, bob, charles, david, ellen, felicity, grace, helen
        case india, james, karen, lizbeth, mary, nathan, olivia, paul
        case quincy, rob, samantha, tatiana, ulna, vivian, william
        case xavier, yvonne, zoe

        // Fix cRealnames if you add or remove here. Yes, it's ugly. Sue me
        case aboriginal, line, manna, neuron, nothing, offgrid
    }

    static var cRealNames = Nametag.allCases.count - 6
    static var nameix = 0
    static var setNumber = 0

    static func makeName(_ nametag: ArkonName.Nametag, _ setNumber: Int) -> ArkonName {
        return ArkonName(nametag: nametag, setNumber: setNumber)
    }

    static func makeName() -> ArkonName {
        defer {
            nameix = (nameix + 1) % cRealNames
            if nameix == 0 { setNumber += 1 }
        }

        return ArkonName(
            nametag: Nametag.allCases[nameix % cRealNames],
            setNumber: setNumber
        )
    }

    static let empty   = ArkonName(nametag: .nothing, setNumber: 0)
    static let offgrid = ArkonName(nametag: .offgrid, setNumber: 0)

    let nametag: Nametag
    let setNumber: Int

    static func == (_ lhs: ArkonName, _ rhs: ArkonName) -> Bool {
        return lhs.nametag == rhs.nametag && lhs.setNumber == rhs.setNumber
    }
}
