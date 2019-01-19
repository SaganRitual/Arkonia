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
    let netcam: SKNode
    let scaledHeight: CGFloat
    let scaledWidth: CGFloat
    var vSpacing = CGFloat(0.0)
    var vTop = CGFloat(0.0)

    init(netcam: SKNode, cLayers: Int) {
        self.netcam = netcam
        self.scaledHeight = netcam.frame.height / netcam.yScale
        self.scaledWidth = netcam.frame.width / netcam.xScale

        self.setVerticalSpacing(cLayers: cLayers)
    }

    func getPosition(for neuron: VNeuron) -> CGPoint {
        let xSS = neuron.id.myID
        let ySS = neuron.id.parentID    // The layer
        return getPosition(xSS: xSS, ySS: ySS)
    }

    func getPosition(xSS: Int, ySS: Int) -> CGPoint {
        let yOffset: CGFloat = {
            switch self.layerRole {
            case .motorLayer:  return scaledHeight
            case .hiddenLayer: return CGFloat(ySS + 1) * vSpacing
            case .senseLayer:  return 0
            }
        }()

        let x = getX(xSS)
        let y = vTop - yOffset
        return CGPoint(x: x, y: y)
    }

    private func getX(_ xSS: Int) -> CGFloat {
        return hLeft + CGFloat(xSS + 1) * hSpacing
    }

    mutating func setHorizontalSpacing(cNeurons: Int) {
        self.hLeft = -scaledWidth / 2.0
        self.hSpacing = scaledWidth / CGFloat(cNeurons + 1)
    }

    mutating func setLayerRole(_ layerRole: VLayer.LayerRole) {
        self.layerRole = layerRole
    }

    mutating func setVerticalSpacing(cLayers: Int) {
        self.vSpacing = scaledHeight / CGFloat(cLayers + 1)
        self.vTop = scaledHeight / 2.0
    }
}
