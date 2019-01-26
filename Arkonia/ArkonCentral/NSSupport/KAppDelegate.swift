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
    var displayTest: VDisplayTest?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentral.sceneBackgroundTexture = spriteAtlas.textureNamed("scene-background")
        ArkonCentral.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange-half")
        ArkonCentral.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentral.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green-half")

		KAppController.shared.showMainWindow(withTitle: "VisualizerTest")

		if let scene = KAppController.shared.scene {

        	ArkonCentral.display = VDisplay(scene)
        	scene.delegate = ArkonCentral.display

        	displayTest = VDisplayTest()
        	displayTest?.start()
		}
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}
