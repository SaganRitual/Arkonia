protocol KIdentifiable: CustomStringConvertible, CustomDebugStringConvertible {
    var id: KIdentifier { get }
}

extension KIdentifiable {
    var description: String { return String(describing: id) }
    var debugDescription: String { return String(reflecting: id) }
}

protocol KIdentifierProtocol {
    var familyID: [Int] { get }
    var myID: Int { get }
    var type: KIdentifier.KType { get }

    init(_ type: KIdentifier.KType, _ familyID: [Int], _ myID: Int)
}

struct KIdentifier: Hashable, KIdentifierProtocol {
    public let familyID: [Int]
    public let myID: Int
    let type: KType

    var parentID: Int { return familyID.last! }

    public init(_ type: KType, _ familyID: [Int], _ myID: Int) {
        self.familyID = familyID
        self.myID = myID
        self.type = type
    }

    init(_ type: KIdentifier.KType, _ myID: Int) { self.init(type, [], myID) }

    enum KType: Int {
        case hiddenLayer, net, neuron, signalRelay, senseLayer = -1, motorLayer = -2
    }

    func add(_ newChild: Int, as kType: KType) -> KIdentifier {
        return KIdentifier(kType, familyID + [myID], newChild)
    }

    public static func == (_ lhs: KIdentifier, _ rhs: KIdentifier) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
