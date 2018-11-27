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
//
//let pointOhOneSix =  "L_N_A(true)_W(b[0.85008]v[0.85008])_N_A(true)_W(b[0.91789]v[1.032])_N_A(false)_W(b[1.0261]v[1.08621])_N_A(true)_W(b[1]v[1])_N_A(true)_W(b[0.97173]v[1.01098])_"
//let pointOhOhEight = "L_N_A(true)_W(b[0.81439]v[0.84956])_N_A(false)_W(b[1]v[1])_N_A(true)_W(b[0.98591]v[1.01923])_N_A(true)_W(b[0.97715]v[3.41965])_N_A(true)_W(b[1]v[1])_"
//
//var testSubjects = TSTestGroup()
//let relay = TSRelay(testSubjects)
//let fitnessTester = FTLearnZoeName()
//let testSubjectFactory = TSZoeFactory(relay, fitnessTester: fitnessTester)
//var curator: Curator?
//
//var curatorStatus = CuratorStatus.running
//let v = RepeatingTimer(timeInterval: 0.1)
//
//v.eventHandler = { if let c = curator { curatorStatus = c.track() } }
//
//v.resume()
//while curatorStatus == .running {
//    do {
//        guard curator == nil else { continue }
//        curator = try Curator(starter: nil, testSubjectFactory: testSubjectFactory)
//    } catch {
//        curator = nil
//        print("caught in main:", error)
//    }
//}
//
//print("\nCompletion state: \(curatorStatus)")
import Cocoa
import GameKit

var str = "Hello, playground"

// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/2538939/code-different
// https://stackoverflow.com/a/44535176/1610473

class BellCurve {
    let summary: NSCountedSet
    let endOfRange: Int
    let maxValue: Double
    
    init() {
        let arr = BellCurve.generateBellCurve(count: 100_000, mean: 50, deviation: 16)
        let summary = NSCountedSet(array: arr)
        let endOfRange = BellCurve.getEndOfRange(summary)
        let maxValue = BellCurve.getMaxValue(summary)

        self.endOfRange = endOfRange
        self.maxValue = maxValue
        self.summary = summary
    }

    static func generateBellCurve(count: Int, mean: Int, deviation: Int) -> [Int] {
        guard count > 0 else { return [] }
        
        let randomSource = GKARC4RandomSource()
        let randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(mean), deviation: Float(deviation))
        
        // Clamp the result to within the specified range
        return (0..<count).map { _ in return randomDistribution.nextInt() }
    }
    
    static func getEndOfRange(_ summary: NSCountedSet) -> Int {
        var finalIndex = 0
        for indexer in 0..<summary.count { finalIndex += summary.count(for: indexer) }
        return finalIndex
    }
    
    func getDouble() -> Double {
        let reallyRandom = Int.random(in: 0..<endOfRange)
        var indexer = reallyRandom
        var normalRandom = 0
        
        for slotSS in 0..<summary.count {
            let slotValue = summary.count(for: slotSS)
            indexer -= slotValue

            if indexer < 0 { normalRandom = slotSS; break }
        }
        
        return 1.0 - (Double(normalRandom) / 100.0)
    }
    
    static func getMaxValue(_ summary: NSCountedSet) -> Double {
        var m = 0
        
        for i in 0..<100 {
            let t = summary.count(for: i)
            if t > m { m = t; }
        }
        
        return Double(m)
    }
    
    func mutate(from value: Double) -> Double {
        let percentage = getDouble()
        let moveMedianToZero = percentage - 0.5
        return value * (1 + moveMedianToZero)
    }
}

let bc = BellCurve()
var buckets = [Int : Int]()

for _ in 0..<1000 {
    
    let d = bc.getDouble()
    let whichBucket = Int(100.0 * d) / 10
    
    if buckets[whichBucket] == nil {
        buckets[whichBucket] = 1; continue
    }
    
    buckets[whichBucket]! += 1
}

let tuples = buckets.map { ($0, $1) }.sorted { $0.0 < $1.0 }
print(tuples)

for _ in 0..<10 {
    print(bc.mutate(from: Double(0.27)))
}
