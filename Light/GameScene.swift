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

    let tsFactory = TSNumberGuesserFactory()

    var frameCount = 0
    var curator: Curator?
    var workItem: DispatchWorkItem!

    var myCuratorStatus = CuratorStatus.running

    override func sceneDidLoad() {
        self.curator = Curator(tsFactory: tsFactory)
        self.workItem = DispatchWorkItem { [weak self] in let _ = self!.curator!.select() }
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
    
    var subjectToDisplay: TSTestSubject?
    
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

        guard let bestTestSubject = curator.getBestTestSubject() else { print("GS: nothing to display"); return }
        if subjectToDisplay == nil { subjectToDisplay = bestTestSubject; print("GS: first display \(subjectToDisplay!.fishNumber)") }
        else if subjectToDisplay!.fishNumber == bestTestSubject.fishNumber { /*print(".", terminator: ""); */return }
        
        print("N(\(bestTestSubject.fishNumber)) O(\(subjectToDisplay!.fishNumber))")
        subjectToDisplay = bestTestSubject
        vBrain = VBrain(gameScene: self, brain: subjectToDisplay!.brain)
        vBrain.displayBrain(subjectToDisplay!.brain, fishNumber: subjectToDisplay!.fishNumber)
        subjectToDisplay!.brain.show(tabs: "", override: false)
    }

}

