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
    let layersCount: Int
    let netcam: SKShapeNode
    let vSpacing: CGFloat

    init(netcam: SKShapeNode, layersCount: Int) {
        self.layersCount = layersCount
        self.netcam = netcam
        self.vSpacing = 2 * netcam.frame.height / CGFloat(layersCount + 1)
    }

    func getPosition(neuronsThisLayer: Int, xIndex: Int, yIndex: Int) -> CGPoint {
        let vTop = (netcam.frame.height - CGFloat(vSpacing))

        let hSpacing = 2 * netcam.frame.width / CGFloat(neuronsThisLayer + 1)
        let hLeft = -netcam.frame.width + hSpacing

        return CGPoint(x: hLeft + CGFloat(xIndex) * hSpacing, y: vTop - CGFloat(yIndex) * vSpacing)
    }
}
