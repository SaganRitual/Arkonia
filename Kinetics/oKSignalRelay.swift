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

struct GridXY {
    let x: Int, y: Int
    weak var relay: KSignalRelay?

    init(_ x: Int, _ y: Int) { self.x = x; self.y = y }
}

struct ConnectionSpec {
    var targets: [GridXY]
}

let cLayers = 5
let cNeurons = 5

enum KConnectoid {
//    static func getConnections(_ relay: KSignalRelay, to upperLayer: KLayer) -> [Int] {
//        let x = relay.id.myID, y = upperLayer.id.myID
//        let connections = inputSpecs[x][y]
//        return connections.targets.map { $0.x }
//    }

    static let inputSpecs: [[ConnectionSpec]] =     [
        [
            ConnectionSpec(targets: [GridXY(0, 0)]),
            ConnectionSpec(targets: [GridXY(1, 0)]),
            ConnectionSpec(targets: [GridXY(2, 0)]),
            ConnectionSpec(targets: [GridXY(3, 0)]),
            ConnectionSpec(targets: [GridXY(4, 0)])
        ], [
            ConnectionSpec(targets: [GridXY(0, 1)]),
            ConnectionSpec(targets: [GridXY(1, 1)]),
            ConnectionSpec(targets: [GridXY(2, 1)]),
            ConnectionSpec(targets: [GridXY(3, 1)]),
            ConnectionSpec(targets: [GridXY(4, 1)])
        ], [
            ConnectionSpec(targets: [GridXY(0, 2)]),
            ConnectionSpec(targets: [GridXY(1, 2)]),
            ConnectionSpec(targets: [GridXY(2, 2)]),
            ConnectionSpec(targets: [GridXY(3, 2)]),
            ConnectionSpec(targets: [GridXY(4, 2)])
        ], [
            ConnectionSpec(targets: [GridXY(0, 3)]),
            ConnectionSpec(targets: [GridXY(1, 3)]),
            ConnectionSpec(targets: [GridXY(2, 3)]),
            ConnectionSpec(targets: [GridXY(3, 3)]),
            ConnectionSpec(targets: [GridXY(4, 3)])
        ], [
            ConnectionSpec(targets: [GridXY(0, 4)]),
            ConnectionSpec(targets: [GridXY(1, 4)]),
            ConnectionSpec(targets: [GridXY(2, 4)]),
            ConnectionSpec(targets: [GridXY(3, 4)]),
            ConnectionSpec(targets: [GridXY(4, 4)])
        ]
    ]
}

//class KSignalRelay: KIdentifiable, KRelayProtocol {
//    // KIdentifiable
//    var description: String { return id.description }
//    let id: KIdentifier
//
//    // KRelayProtocol
//    weak var breaker: KSignalRelay?
//    var inputRelays = [KSignalRelay]()
//    var output: Double = 0.0
//
//    var overriddenState: Bool?
//    var isOperational: Bool {
//        return (overriddenState == nil) ? !inputRelays.isEmpty : overriddenState!
//    }
//
//    // All swim
//    init(_ id: KIdentifier) {
//        self.id = id
////        print("+\(self)")
//    }
//
//    deinit {
////        print("~\(self)")
//        while !inputRelays.isEmpty { inputRelays.removeLast() }
//    }
//}
//
//extension KSignalRelay {
//    static func makeRelay(_ family: KIdentifier, _ me: Int) -> KSignalRelay {
//        let id = family.add(me, as: .signalRelay)
//        return KSignalRelay(id)
//    }
//
//    func connect(to targetNeurons: [Int], in upperLayer: KLayer) {
//        inputRelays = targetNeurons.map { upperLayer.neurons[$0].relay! }
////        print("\(self) c\(inputRelays)")
//    }
//
//    func overrideState(operational: Bool) { overriddenState = operational }
//}
