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

class VDisplay: NSObject, SKSceneDelegate {
    typealias SceneTickCallback = (_ portal: SKNode) -> Void

    var portalNumbers = [SKNode: Int]()
    var portalServer: VPortalServer
    private weak var scene: SKScene?
    private var tickCallbacks = [() -> Void]()
    private var fNets = [SKNode: FNet]()

    init(_ scene: SKScene) {
        self.scene = scene
        self.portalServer = VPortalServer(scene)
    }

    private func display(via portal: SKNode) {
        guard let newFNet = self.fNets[portal] else { return }

        VSignalDriver(fNet: newFNet).drive().display(on: portal)
    }

    func newFNetAvailable(_ fNet: FNet, portal: SKNode) {
        self.fNets[portal] = fNet
        display(via: portal)
        self.fNets[portal] = nil
    }

    func newFNetAvailable(_ fNet: FNet, portal: Int) {
        let p = self.portalServer.getPortal(portal)
        self.fNets[p] = fNet
        display(via: p)
        self.fNets[p] = nil
    }

    func registerForSceneTick(_ cb: @escaping SceneTickCallback, portal: SKNode) {
        tickCallbacks.append({ cb(portal) })
    }

    var frameCount = 0

    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        tickCallbacks.forEach { $0() }
    }
}
