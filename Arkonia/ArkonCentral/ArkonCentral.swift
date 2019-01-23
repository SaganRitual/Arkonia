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

protocol DecoderProtocol {}

enum ArkonCentral {
    static var decoder: DecoderProtocol!
    static var selectionControls = KSelectionControls()

    static let cPortals = 4

    static var sceneBackgroundTexture: SKTexture!
    static var blueNeuronSpriteTexture: SKTexture!
    static var greenNeuronSpriteTexture: SKTexture!
    static var orangeNeuronSpriteTexture: SKTexture!

    static let isMotorLayer = -2
    static let isSenseLayer = -1

    static let vBorderZPosition = CGFloat(3.0)
    static let vConnectorZPosition = CGFloat(1.0)
    static let vNeuronZPosition = CGFloat(2.0)

    static var vNeuronAntiscale = ceil(4.0 / sqrt(Double(cPortals)))
    static var vNeuronScale: CGFloat = { CGFloat(ArkonCentral.cPortals == 1 ? 0.25 : 0.25) }()

    static let vPortalSeparatorsScale = 0.4
}

struct KSelectionControls {
    var cGenerations = 30000
    var cGenes = 200
    var cLayersInStarter = 5
    var cMotorNeurons = 6
    var cSenseNeurons = 7
    var cSpawnAttempts = 2
    var cSubjectsPerGeneration = 100
    var maxKeepersPerGeneration = 2
    var peerGroupLimit = 2
    var theFishNumber = 0
}
