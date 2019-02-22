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
    #if K_RUN_MAIN

    var curator: Curator?
    var goalSuite: GSGoalSuite?
    var workItem: DispatchWorkItem!

    #elseif K_RUN_DISPLAY_TEST
    var displayTest: VDisplayTest?
    #else
    #error("No run mode specified")
    #endif

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        KAppController.shared.showMainWindow(withTitle: "TDisplay")

        KAppDelegate.setupArkonTextures()
        KAppDelegate.setupNeuronTextures()

        if let scene = KAppController.shared.scene {
            _ = Display(scene)  // Sets Display.shared

            #if K_RUN_MAIN

            _ = World()         // Sets World.shared

            #elseif K_RUN_WITH_CURATOR

            self.goalSuite = AAGoalSuite()
            self.curator = Curator(goalSuite: nok(self.goalSuite))
            self.workItem = DispatchWorkItem { [weak self] in _ = nok(self?.curator).select() }
            DispatchQueue.global(qos: .background).async(execute: self.workItem)

            #elseif K_RUN_DISPLAY_TEST

            displayTest = VDisplayTest()
            displayTest!.start()

            #endif
        }
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}

extension KAppDelegate {
    private static func setupArkonTextures() {
        let atlas = SKTextureAtlas(named: "Arkons")
        let topTexture = atlas.textureNamed("ArkonBase-02")

        ArkonCentralLight.spriteTextureAtlas = atlas
        ArkonCentralLight.topTexture = topTexture
    }

    private static func setupNeuronTextures() {
        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentralLight.sceneBackgroundTexture = spriteAtlas.textureNamed("scene-background")
        ArkonCentralLight.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange-half")
        ArkonCentralLight.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentralLight.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green-half")
    }
}
