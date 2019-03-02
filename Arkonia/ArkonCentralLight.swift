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

enum ArkonCentralLight {
    static let cPortals = 4

    static var blueNeuronSpriteTexture: SKTexture!
    static var debugRectangleTexture: SKTexture!
    static var greenNeuronSpriteTexture: SKTexture!
    static var orangeNeuronSpriteTexture: SKTexture!
    static var sceneBackgroundTexture: SKTexture!

    static let vArkonZPosition = CGFloat(4.0)
    static let vBorderZPosition = CGFloat(3.0)
    static let vLabelZPosition = CGFloat(4.0)
    static let vLabelCotainerZPosition = CGFloat(3.9)
    static let vLineZPosition = CGFloat(1.0)
    static let vNeuronZPosition = CGFloat(2.0)

    static var vNeuronAntiscale = CGFloat(ceil(sqrt(Double(cPortals))))
    static var vNeuronScale = CGFloat((cPortals == 1) ? (1.0 / 8.0) : (1.0 / 4.0))

    static let vPortalSeparatorsScale = 0.4
    static let vConnectorLineScale = CGFloat(1.0)

    static func makeColor(hexRGB: Int) -> NSColor {
        //        let rgbs = String(format: "0x%08X", rgb)
        //        print("heat = \(heat), heatSS = \(colorSS), rgb = \(rgbs)")
        let r = Double((hexRGB >> 16) & 0xFF) / 256
        let g = Double((hexRGB >>  8) & 0xFF) / 256
        let b = Double(hexRGB         & 0xFF) / 256

        return NSColor(calibratedRed: CGFloat(r), green: CGFloat(g),
                       blue: CGFloat(b), alpha: CGFloat(1.0))
    }

    static let colors: [NSColor] = [
        .red, .green, .blue,
        .cyan, .yellow, .magenta, .orange, .purple
    ]

    static var spriteTextureAtlas: SKTextureAtlas?
    static var spriteTextures = [SKTexture]()
    static var topTexture: SKTexture?

    static func unscale(_ position: CGPoint) -> CGPoint { return position * vNeuronAntiscale }
}
