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

    private var vBrain: VBrain!

//    let tsFactory = TSZoeFactory()
//    let tsFactory = TSNumberGuesserFactory()
    let goalSuite = NGGoalSuite("Zoe Bishop")

    var frameCount = 0
    var curator: Curator?
    var workItem: DispatchWorkItem!
    var currentProgenitor: GSSubject?

    var myCuratorStatus = CuratorStatus.running
    var firstPass = true

    override func sceneDidLoad() {
        self.curator = Curator(goalSuite: goalSuite)
        self.workItem = DispatchWorkItem { [weak self] in _ = self!.curator!.select() }
        DispatchQueue.global(qos: .background).async(execute: self.workItem)
    }

    // With deepest gratitude to Stack Overflow dude
    // https://stackoverflow.com/users/2346164/gilian-joosen
    // https://stackoverflow.com/a/26787701/1610473
    //
    func returnChar(_ theEvent: NSEvent) -> Character? {
        let s: String = theEvent.characters!
        for char in s{ return char }
        return nil
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

        if mine.fishNumber == his.fishNumber && !firstPass { return }

        self.currentProgenitor = his

        vBrain = VBrain(gameScene: self, arkon: his)
        vBrain.displayBrain(his.brain.net)

        firstPass = false
    }

}
