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

import Cocoa
import SpriteKit

@NSApplicationMain
class KAppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        KAppController.shared.showMainWindow(withTitle: "Arkonia")

        KAppDelegate.setupArkonTextures()
        KAppDelegate.setupBackgroundTextures()
        KAppDelegate.setupMannaTexture()
        KAppDelegate.setupNeuronTextures()

        FDecoder.shared = FDecoder()
        Mutator.shared = Mutator()
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}

extension KAppDelegate {
    private static func setupArkonTextures() {
        let atlas = SKTextureAtlas(named: "Arkons")
        let topTexture = atlas.textureNamed("spark-outline-large")

        ArkonCentralLight.spriteTextureAtlas = atlas
        ArkonCentralLight.topTexture = topTexture
    }

    private static func setupBackgroundTextures() {
        let atlas = SKTextureAtlas(named: "Backgrounds")
        ArkonCentralLight.sceneBackgroundTexture = atlas.textureNamed("scene-background")
        ArkonCentralLight.debugRectangleTexture = atlas.textureNamed("debug-rectangle")
    }

    private static func setupMannaTexture() {
        let atlas = SKTextureAtlas(named: "Manna")
        ArkonCentralLight.mannaSpriteTexture = atlas.textureNamed("manna")
    }

    private static func setupNeuronTextures() {
        let atlas = SKTextureAtlas(named: "Neurons")
        ArkonCentralLight.orangeNeuronSpriteTexture = atlas.textureNamed("neuron-orange-half")
        ArkonCentralLight.blueNeuronSpriteTexture = atlas.textureNamed("neuron-blue")
        ArkonCentralLight.greenNeuronSpriteTexture = atlas.textureNamed("neuron-green-half")
    }
}
