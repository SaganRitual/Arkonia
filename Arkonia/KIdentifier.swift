//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//

import Foundation

public protocol KIdentifiable: CustomStringConvertible, CustomDebugStringConvertible {
    var id: KIdentifier { get }
}

extension KIdentifiable {
    var description: String { return String(describing: id) }
    var debugDescription: String { return String(reflecting: id) }
}

public protocol KIdentifierProtocol: CustomStringConvertible {
    var description: String { get }
    var familyID: [Int] { get }
    var myID: Int { get }

    init(_ type: String, _ familyID: [Int], _ myID: Int)
}

public struct KIdentifier: Hashable, KIdentifierProtocol {
    public let description: String
    public let familyID: [Int]
    public let myID: Int
    let type: String

    var parentID: Int { return familyID.last! }

    public init(_ type: String, _ familyID: [Int], _ myID: Int) {
        self.description = KIdentifier.getFullID(type, familyID, myID)
        self.familyID = familyID
        self.myID = myID
        self.type = type
    }

    init(_ type: String, _ myID: Int) { self.init(type, [], myID) }

    enum KType: Int {
        case hiddenLayer, net, neuron, signalRelay, senseLayer = -1, motorLayer = -2
    }

    func add(_ newChild: Int, as kType: KType) -> KIdentifier {
        switch kType {
        case .hiddenLayer: return     KIdentifier("KLayer  ", familyID + [myID], newChild)
        case .motorLayer: return      KIdentifier("Motor   ", familyID + [myID], newChild)
        case .net: return             KIdentifier("KNet    ", [], newChild)
        case .neuron: return          KIdentifier("KNeuron ", familyID + [myID], newChild)
        case .senseLayer: return      KIdentifier("Sense   ", familyID + [myID], newChild)
        case .signalRelay: return     KIdentifier("KRelay  ", familyID + [myID], newChild)
        }
    }

    private static func getFullID(_ type: String, _ family: [Int], _ me: Int) -> String {
        var separators = ["", ":", ":", "."]
        var fullID = "\(type)("

        for (separator, member) in (family + [me]).enumerated() {
            let m: String = {
                switch member {
                case KIdentifier.KType.motorLayer.rawValue: return "b"
                case KIdentifier.KType.senseLayer.rawValue: return "t"
                default: return String(member)
                }
            }()

            fullID += separators[separator] + "\(m)"
        }

        return fullID + ")"
    }

    public static func == (_ lhs: KIdentifier, _ rhs: KIdentifier) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
