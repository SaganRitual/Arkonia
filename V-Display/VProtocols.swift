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

protocol VGridProtocol {
    var gameScene: GameScene { get }
    var labelBackground: SKShapeNode! { get set }
    var kNet: KNet { get set }
    var spacer: Spacer! { get set }
    var vBrainSceneSize: CGSize { get set }
    var vNeurons: [SKShapeNode] { get set }

    init(gameScene: GameScene, kNet: KNet, sceneSize: CGSize)

    func displayGrid(_ sensoryInputs: KLayer, _ motorOutputs: KLayer)
    func displayNet(_ sensoryInputs: KLayer, _ kNet: KNet, _ motorOutputs: KLayer)

    func displayLayers(_ sensoryInputs: KLayer, _ kLayers: [KLayer], _ motorOutputs: KLayer)
    func makeVLayer(kLayer: KLayer, spacer: Spacer) -> VLayerProtocol
}

protocol VLayerProtocol {
    var kLayer: KLayer { get }
    var spacer: Spacer { get }

    func drawConnections(to upperLayer: VLayerProtocol)
    func drawNeurons() -> [SKShapeNode]
    func drawParameters(on nodeLayer: [SKShapeNode], isSenseLayer: Bool)
}
