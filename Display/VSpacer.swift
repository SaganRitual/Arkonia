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

struct VSpacer {
    var cNeurons: Int!
    var hLeft = CGFloat(0.0)
    var hSpacing = CGFloat(0.0)
    var layerRole = VLayer.LayerRole.senseLayer
    let portal: SKNode
    let height: CGFloat
    let width: CGFloat
    var vSpacing = CGFloat(0.0)
    var vTop = CGFloat(0.0)

    init(portal: SKNode, cLayers: Int) {
        self.portal = portal
        self.height = portal.frame.height
        self.width = portal.frame.width

        self.setVerticalSpacing(cLayers: cLayers)
    }

    func getPosition(for neuron: VNeuron) -> CGPoint {
        let xSS = neuron.id.myID
        let ySS = neuron.id.parentID    // The layer
        return getPosition(VGridPosition(x: xSS, y: ySS))
    }

    func getPosition(_ gridPosition: VGridPosition) -> CGPoint {
        let yOffset: CGFloat = {
            switch self.layerRole {
            case .motorLayer:  return height
            case .hiddenLayer: return CGFloat(gridPosition.y + 1) * vSpacing
            case .senseLayer:  return 0
            }
        }()

        let x = getX(gridPosition.x)
        let y = vTop - yOffset
        return CGPoint(x: x, y: y)
    }

    private func getX(_ xSS: Int) -> CGFloat {
        return hLeft + CGFloat(xSS + 1) * hSpacing
    }

    mutating func setHorizontalSpacing(cNeurons: Int) {
        self.hLeft = -width / 2.0
        self.hSpacing = width / CGFloat(cNeurons + 1)
    }

    mutating func setLayerRole(_ layerRole: VLayer.LayerRole) {
        self.layerRole = layerRole
    }

    mutating func setVerticalSpacing(cLayers: Int) {
        self.vSpacing = height / CGFloat(cLayers + 1)
        self.vTop = height / 2.0
    }
}

extension VSpacer {
    struct VGridSize {
        var width: Int
        var height: Int

        init(width: Int, height: Int) {
            self.width = width
            self.height = height
        }
    }

    struct VGridPosition {
        var x: Int
        var y: Int

        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
}
