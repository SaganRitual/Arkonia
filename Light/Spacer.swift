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
    var cNeurons: Int!
    var forSenseLayer = false
    let layersCount: Int
    let netcam: SKNode
    let scaledHeight: CGFloat
    let scaledWidth: CGFloat
    let vSpacing: CGFloat
    let vTop: CGFloat

    init(netcam: SKNode, layersCount: Int, cNeurons: Int? = nil) {
        self.layersCount = layersCount
        self.netcam = netcam

        let scaledWidth = netcam.frame.width / netcam.xScale
        let scaledHeight = netcam.frame.height / netcam.yScale

        self.vSpacing = scaledHeight / CGFloat(layersCount + 1)
        self.vTop = scaledHeight / 2.0
        self.cNeurons = cNeurons

        self.scaledHeight = scaledHeight
        self.scaledWidth = scaledWidth
    }

    func getPosition(xSS: Int, ySS: Int) -> CGPoint {
        return getPosition(cNeurons: self.cNeurons, xSS: xSS, ySS: ySS)
    }

    func getPosition(cNeurons: Int, xSS: Int, ySS: Int) -> CGPoint {
        let offset = forSenseLayer ? 0 : CGFloat(ySS + 1) * vSpacing

        return CGPoint(x: getX(xSS: xSS), y: vTop - offset)
    }

    private func getX(xSS: Int) -> CGFloat {
        let hSpacing = scaledWidth / CGFloat(cNeurons + 1)
        let hLeft = -scaledWidth / 2.0

        return hLeft + CGFloat(xSS + 1) * hSpacing
    }

    mutating func setDefaultCNeurons(_ cNeurons: Int) { self.cNeurons = cNeurons }
}
