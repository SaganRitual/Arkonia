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

protocol KInputProtocol {
    var inputRelays: [KSignalRelay] { get set }
}

protocol KOutputProtocol {
    var output: Double { get }
}

protocol KRelayProtocol: class, KInputProtocol, KOutputProtocol {
    var breaker: KSignalRelay? { get set }
    var isOperational: Bool { get }
}

class KSignalRelay: KIdentifiable, KRelayProtocol {
    // KIdentifiable
    let id: KIdentifier

    // KRelayProtocol
    weak var breaker: KSignalRelay?
    var inputRelays = [KSignalRelay]()
    var output: Double = 0.0

    var debugDescription: String { return "isOperational = \(isOperational)" }

    var overriddenState: Bool?
    var isOperational: Bool { return (overriddenState == nil) ? !inputRelays.isEmpty : overriddenState! }

    // All swim
    init(_ id: KIdentifier) {
        self.id = id
//        print("+\(self)")
    }

    deinit {
//        print("~\(self)")
        while !inputRelays.isEmpty { inputRelays.removeLast() }
    }
}

//extension KSignalRelay {
//    static func makeRelay(_ family: KIdentifier, _ me: Int) -> KSignalRelay {
//        let id = family.add(me, as: .signalRelay)
//        return KSignalRelay(id)
//    }
//
//    func connect(to targetNeurons: [Int], in upperLayer: KLayer) {
//        inputRelays = targetNeurons.map {
//            upperLayer.neurons[$0].relay!
//        }
//
////        print("\(self) connects to \(inputRelays)")
//    }
//
//    func overrideState(operational: Bool) { overriddenState = operational }
//}
