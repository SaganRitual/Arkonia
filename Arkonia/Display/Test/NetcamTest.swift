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

extension Visualizer {
    private func addNeuron(whichNetcam: VNet.Quadrant, gridPosition: VGridPosition,
                           gridSize: VGridSize)
    {
        var opacity = CGFloat(0.0)

        let netcam = vNet.getNetcam(whichNetcam)
        var spacer = VSpacer(netcam: netcam, cLayers: gridSize.height)
        spacer.setHorizontalSpacing(cNeurons: gridSize.width)
        spacer.setLayerRole(.hiddenLayer)

        let scenePosition = spacer.getPosition(gridPosition)

        let vNeuron = SKShapeNode(circleOfRadius: CGFloat(15.0))
        vNeuron.fillColor = getFillColor(whichNetcam)

        vNeuron.position = scenePosition
        print("vn = \(vNeuron.position)")

        vNeuron.alpha = opacity
        opacity += CGFloat(1.0) / CGFloat(gridSize.width * gridSize.height)

        let label = makeNetcamLabel(whichNetcam, gridPosition: gridPosition)
        vNeuron.addChild(label)

        netcam.addChild(vNeuron)
    }

    private func getFillColor(_ whichNetcam: VNet.Quadrant) -> NSColor {
        switch whichNetcam {
        case .one: return .blue
        case .two: return .green
        case .three: return .yellow
        case .four: return .purple
        }
    }

    private func makeNetcamLabel(_ whichNetcam: VNet.Quadrant, gridPosition: VGridPosition)
        -> SKLabelNode
    {
        let label = SKLabelNode(text: "\(gridPosition)")
        label.fontColor = .black
        label.fontSize = 8
        label.fontName = "Courier New"
        label.position.x = -CGFloat(label.frame.width / 2)
        return label
    }
}
