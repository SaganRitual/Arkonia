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

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var curator: Curator?
    var currentProgenitor: GSSubject?
    var firstPass = true
    var frameCount = 0
    let goalSuite = NGGoalSuite("Zoe Bishop")
//    let goalSuite = AAGoalSuite()
    var kNet: KNet!

    var myCuratorStatus = CuratorStatus.running
    var nowShowingRandomCandidate: GSSubject?
    var vGrid: VGrid!
    var workItem: DispatchWorkItem!

    func makeVGrid(_ kNet: KNet) {
        self.kNet = kNet
        vGrid = VGrid(gameScene: self, kNet: kNet, sceneSize: self.frame.size)
    }

#if INSPECTION
    override func mouseUp(with event: NSEvent) {

    }
#endif

    override func didChangeSize(_ oldSize: CGSize) {
        guard ArkonCentral.gScene == nil else { return }
        ArkonCentral.gScene = self

        self.curator = Curator(goalSuite: goalSuite)
        self.workItem = DispatchWorkItem { [weak self] in _ = self!.curator!.select() }
        DispatchQueue.global(qos: .background).async(execute: self.workItem)
    }

    override func update(_ currentTime: TimeInterval) {
        frameCount += 1

        guard let curator = self.curator else { return }
        guard myCuratorStatus == .running else { return }

        guard curator.status == .running else {
            myCuratorStatus = curator.status
            workItem.cancel()
            self.curator = nil
            return
        }

        guard let his = curator.currentProgenitor else { return }

        if self.currentProgenitor == nil { self.currentProgenitor = his }
        guard let mine = self.currentProgenitor else { preconditionFailure() }

//        updateRandomDisplay()

        if mine.fishNumber == his.fishNumber && !firstPass { return }

        self.currentProgenitor = his
//        print("vvv: \(vGrid != nil)", terminator: "")
        self.removeAllChildren()
        vGrid?.displayGrid(kNet.senseLayer, kNet.motorLayer)
        vGrid = nil
        kNet = nil
        mine.tNet = nil

        firstPass = false
    }

//    var primeRandomUpdate = true
//    func updateRandomDisplay() {
//        guard let toDisplay = curator<!>.selector.randomArkonForDisplay else { return }
//
//        var update = primeRandomUpdate
//        if let c = nowShowingRandomCandidate {
//            update = update || (c.fishNumber != toDisplay.fishNumber)
//        }
//
//        if update {
//            vBrain.displayBrain(toDisplay, .two)
//            nowShowingRandomCandidate = toDisplay
//            primeRandomUpdate = false
//        }
//    }

}
