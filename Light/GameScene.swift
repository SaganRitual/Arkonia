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

#if BELL_CURVE
    
    let bellCurve = BellCurve()
    var hSpacing = CGFloat(0.0)
    var vSpacing = CGFloat(0.0)
    var maxY = CGFloat(1.0)
    let hResolution = CGFloat(1000.0)
    var buckets = Array<Int>()
    
    override func didMove(to view: SKView) {
        hSpacing = view.frame.size.width / hResolution
        vSpacing = view.frame.size.height

        buckets = Array(repeating: 0, count: Int(hResolution))
    }

    override func update(_ currentTime: TimeInterval) {
        let d = CGFloat(bellCurve.getDouble())
        let marker = SKShapeNode(circleOfRadius: CGFloat(5.0))
        
        let f = (d / hSpacing).rounded(.toNearestOrEven) - 0.5
        let ssBucket = Int(f)
        buckets[ssBucket] += 1

        marker.position.x = (d / hSpacing) - 1.0
        
        let fBucketHeight = CGFloat(buckets[ssBucket])
        if fBucketHeight > maxY { maxY = fBucketHeight }
        
        vSpacing = 1 / (maxY / 100.0)
        
        marker.position.y = vSpacing * fBucketHeight
        
        self.addChild(marker)
    }

#else
    
    private var vBrain: VBrain!
    
    var frameCount = 0
    var curator: Curator!
    var curatorStatus = CuratorStatus.running
    var brain: NeuralNetProtocol!

    // With deepest gratitude to Stack Overflow dude
    // https://stackoverflow.com/users/2346164/gilian-joosen
    // https://stackoverflow.com/a/26787701/1610473
    //
    func returnChar(_ theEvent: NSEvent) -> Character? {
        let s: String = theEvent.characters!
        for char in s{ return char }
        return nil
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

    func getCurator() throws {
        guard self.curator == nil else { return }
        
        let testSubjects = TSTestGroup()
        let relay = TSRelay(testSubjects)
        let fitnessTester = FTLearnZoeName()
        let testSubjectFactory = TSZoeFactory(relay, fitnessTester: fitnessTester)
//        let fitnessTester = TestSubjectFitnessTester()
//        let testSubjectFactory = TestSubjectFactory(relay, fitnessTester: fitnessTester)
        self.curator = Curator(starter: nil, testSubjectFactory: testSubjectFactory)
    }
    
    var completionDisplayed = false
    override func update(_ currentTime: TimeInterval) {
        frameCount += 1
        
        do { try getCurator() }
        catch { return }
        
        guard let curator = self.curator else { return }
        
        guard self.curatorStatus == .running else {
            if !completionDisplayed {
                vBrain.displayBrain(self.brain, isFinalUpdate: true)
                completionDisplayed = true
            }
            return
        }
        
        self.curatorStatus = curator.track()

        switch self.curatorStatus {
        case .running: break
            
        case .finished: fallthrough
        case .chokedByDudliness:
            print("\nCompletion state: \(curatorStatus)")
        }

//        if frameCount < 60 { return }
//        print("?", terminator: "")
//        frameCount = 0

        guard let brainOk = try? curator.getMostInterestingTestSubject() else {
            return
        }
        
        self.brain = brainOk

        vBrain = VBrain(gameScene: self, brain: self.brain)
        vBrain.displayBrain(self.brain)
    }
    
#endif

}

