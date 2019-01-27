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
    #if LIGHT_RUN

    var curator: Curator?
    let goalSuite = NGGoalSuite("Zoe Bishop")
    var workItem: DispatchWorkItem!

    #elseif LT_DISPLAY
    var displayTest: VDisplayTest?
    #endif

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let spriteAtlas = SKTextureAtlas(named: "Neurons")
        ArkonCentralLight.sceneBackgroundTexture = spriteAtlas.textureNamed("scene-background")
        ArkonCentralLight.orangeNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-orange-half")
        ArkonCentralLight.blueNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-blue")
        ArkonCentralLight.greenNeuronSpriteTexture = spriteAtlas.textureNamed("neuron-green-half")

        KAppController.shared.showMainWindow(withTitle: "VisualizerTest")

        if let scene = KAppController.shared.scene {

          ArkonCentralLight.display = VDisplay(scene)
          scene.delegate = ArkonCentralLight.display

          #if LIGHT_RUN

          self.curator = Curator(goalSuite: goalSuite)
          self.workItem = DispatchWorkItem { [weak self] in _ = self!.curator!.select() }
          DispatchQueue.global(qos: .background).async(execute: self.workItem)

          #elseif LT_DISPLAY
          displayTest = VDisplayTest()
          displayTest!.start()
          #endif
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

}
