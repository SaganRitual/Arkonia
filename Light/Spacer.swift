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

struct Spacer {
    enum LayerType { case sensoryInputs, hidden, motorOutputs }

    var cNeurons: Int!
    var hLeft = CGFloat(0.0)
    var hSpacing = CGFloat(0.0)
    let layersCount: Int
    var layerType = LayerType.hidden
    let netcam: SKNode
    var neuronsMap = [Int : Int]()
    let scaledHeight: CGFloat
    let scaledWidth: CGFloat
    let vSpacing: CGFloat
    let vTop: CGFloat

    init(netcam: SKNode, layersCount: Int) {
        self.layersCount = layersCount
        self.netcam = netcam

        let scaledWidth = netcam.frame.width / netcam.xScale
        let scaledHeight = netcam.frame.height / netcam.yScale

        self.vSpacing = scaledHeight / CGFloat(layersCount + 1)
        self.vTop = scaledHeight / 2.0

        self.scaledHeight = scaledHeight
        self.scaledWidth = scaledWidth
    }

    func getPosition(xSS: Int, ySS: Int) -> CGPoint {
        let yOffset: CGFloat = {
            switch self.layerType {
            case .motorOutputs:  return scaledHeight
            case .hidden:        return CGFloat(ySS + 1) * vSpacing
            case .sensoryInputs: return 0
            }
        }()

        let p = CGPoint(x: getX(xSS: xSS), y: vTop - yOffset)
        return p
    }

    private func getX(xSS: Int) -> CGFloat {
        return hLeft + CGFloat(self.neuronsMap[xSS]! + 1) * hSpacing
    }

    mutating func setHorizontalSpacing(_ neuronsMap: [Int : Int]) {
        self.neuronsMap = neuronsMap
        self.cNeurons = neuronsMap.count
        self.hLeft = -scaledWidth / 2.0
        self.hSpacing = scaledWidth / CGFloat(cNeurons + 1)
    }
}