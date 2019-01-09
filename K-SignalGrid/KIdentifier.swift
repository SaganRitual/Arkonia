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
#if !NETCAMS_SMOKE_TEST
import Foundation

struct KIdentifier: CustomDebugStringConvertible, Hashable, KIdentifierProtocol {
    var description: String
    let familyID: [Int]
    let myID: Int
    let type: String

    var debugDescription: String { return description }
    var parentID: Int { return familyID.last! }

    init(_ type: String, _ familyID: [Int], _ myID: Int) {
        self.description = KIdentifier.getFullID(type, familyID, myID)
        self.familyID = familyID
        self.myID = myID
        self.type = type
    }

    init(_ type: String, _ myID: Int) { self.init(type, [], myID) }

    enum KType { case signalRelay, layer, net, neuron, senseLayer, motorLayer }
    func add(_ newChild: Int, as kType: KType) -> KIdentifier {
        switch kType {
        case .layer: return           KIdentifier("KLayer  ", familyID + [myID], newChild)
        case .net: return             KIdentifier("KNet    ", [], newChild)
        case .neuron: return          KIdentifier("KNeuron ", familyID + [myID], newChild)
        case .signalRelay: return     KIdentifier("KRelay  ", familyID + [myID], newChild)
        case .senseLayer: return      KIdentifier("Sense   ", familyID + [myID], newChild)
        case .motorLayer: return      KIdentifier("Motor   ", familyID + [myID], newChild)
        }
    }

    private static func getFullID(_ type: String, _ family: [Int], _ me: Int) -> String {
        var separators = ["", ":", ":", "."]
        var fullID = "\(type)("

        for (separator, member) in (family + [me]).enumerated() {
            fullID += separators[separator] + "\(member)"
        }

        return fullID + ")"
    }

    static func == (_ lhs: KIdentifier, _ rhs: KIdentifier) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
#endif
