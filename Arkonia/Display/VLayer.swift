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
import SpriteKit

class VLayer: KIdentifiable, Equatable {
    enum LayerRole { case senseLayer, hiddenLayer, motorLayer }

    let id: KIdentifier
    var layerRole: LayerRole
    var neurons = [VNeuron]()
    weak var portal: SKNode!
    let layerSSInGrid: Int

    var debugDescription: String {
        return "\(self): cNeurons = \(neurons.count)"
    }

    init(id: KIdentifier, portal: SKNode, layerRole: LayerRole, layerSSInGrid: Int) {
        self.id = id
        self.layerRole = layerRole
        self.layerSSInGrid = layerSSInGrid
        self.portal = portal
    }

    @discardableResult
    func addNeuron(bias: Double, inputSources: [VInputSource], output: Double)
        -> VNeuron
    {
        let nID = self.id.add(neurons.count, as: .neuron)
        let vN = VNeuron(id: nID, portal: portal, bias: bias,
                         inputSources: inputSources, output: output)

        neurons.append(vN)
        return neurons.last!
    }

    func visualize(spacer spacer_: VSpacer) {
        var spacer = spacer_
        spacer.setHorizontalSpacing(cNeurons: neurons.count)
        spacer.setLayerRole(layerRole)

        neurons.forEach {
            $0.visualize(spacer: spacer, layerRole: layerRole)
        }
    }

    static func == (_ lhs: VLayer, _ rhs: VLayer) -> Bool { return lhs.id == rhs.id }
}
