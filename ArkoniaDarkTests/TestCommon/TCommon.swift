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

class RRelay: KSignalRelay {
    deinit {
        //        print("~\(self)")
    }
}

class RLayer: CustomStringConvertible {
    let id: KIdentifier
    var relays = [RRelay?]()

    init(_ id: KIdentifier, gridWidth: Int) {
        self.id = id

        relays = (0..<gridWidth).map { addRelay($0) }
    }

    func addRelay(_ idNumber: Int) -> RRelay {
        let newID = id.add(idNumber, as: .signalRelay)
        return RRelay(newID)
    }

    var description: String {
        return relays.map {
            let op = String($0!.isOperational)
            let of = String(op.first!)
            return of.uppercased()
            }.joined()
    }

    subscript (_ ss: Int) -> RRelay? {
        get { return relays[ss]! }
        set { relays[ss] = newValue }
    }
}

class RGrid {
    let id: KIdentifier
    var layers: [RLayer]

    init(_ id: KIdentifier, gridWidth: Int, gridHeight: Int) {
        self.id = id
        layers = (0..<gridHeight).map {
            let newID = id.add($0, as: .hiddenLayer)
            return RLayer(newID, gridWidth: gridWidth)
        }
    }

    subscript (_ ss: Int) -> RLayer {
        get { return layers[ss] }
    }
}

class WRelay {
    weak var relay: RRelay?

    init(_ rRelay: RRelay) { self.relay = rRelay }
}

class WLayer {
    var relays = [WRelay]()

    init(_ rLayer: RLayer) {
        relays = rLayer.relays.map { WRelay($0!) }
    }

    subscript (_ ss: Int) -> WRelay {
        get { return relays[ss] }
    }
}

class WGrid {
    var layers: [WLayer]

    init(_ rGrid: RGrid) {
        layers = rGrid.layers.map { WLayer($0) }
    }

    subscript (_ ss: Int) -> WLayer {
        get { return layers[ss] }
    }
}
