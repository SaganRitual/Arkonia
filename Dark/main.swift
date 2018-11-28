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
import GameKit

#if false
let sciNotation = "(?:-?\\d\\.\\d+e-?\\d+)"
let civilian =     "(?:-?\\d*\\.?\\d*)"
let allSwim = sciNotation + "|" + civilian
let reCivilian = "b\\[\(allSwim)\\]v\\[\(allSwim)\\]"

let reSciNotation = "b\\[\(sciNotation)\\]v\\[\(sciNotation)\\]"

let wtf = "^([BW])\\(b\\[(-?\\d*\\.?\\d*e)\\]v\\[(-?\\d*\\.?\\d*e)\\]\\)$"

let desperation = "([WB])\\(b\\[(-?\\d*\\.?\\d*)\\]v\\[(-?\\d*\\.?\\d*)\\]\\)"

let dumbass = "W(b[1.7]v[3.14159])"
let dumberass = "B(b[6.02e23]v[1.47e9])"
let badum = "b[87]v[1.03e29]"

let ambition = "\\[([^\\]]+)\\]"
let reDoubletAmbition = "([BW])?\\(?b\\[([^\\]]+)\\]v\\[([^\\]]+)\\]?\\)?"

////print(dumbass.searchRegex(regex: civilian))
////print(dumbass.searchRegex(regex: sciNotation))
print(badum.searchRegex(regex: reDoubletAmbition))
print(badum.searchRegex(regex: ambition))

print(dumbass.searchRegex(regex: reDoubletAmbition))
print(dumbass.searchRegex(regex: ambition))

print(dumberass.searchRegex(regex: reDoubletAmbition))
print(dumberass.searchRegex(regex: ambition))

print(ambition, reDoubletAmbition)

exit(0)
#endif

#if BELL_CURVE
// With deepest gratitude to Stack Overflow dude
// https://stackoverflow.com/users/2538939/code-different
// https://stackoverflow.com/a/49471411/1610473
class MyGaussianDistribution {
    private let randomSource: GKRandomSource
    let mean: Float
    let deviation: Float
    
    init(randomSource: GKRandomSource, mean: Float, deviation: Float) {
        precondition(deviation >= 0)
        self.randomSource = randomSource
        self.mean = mean
        self.deviation = deviation
    }
    
    func nextFloat() -> Float {
        guard deviation > 0 else { return mean }
        
        let x1 = randomSource.nextUniform() // a random number between 0 and 1
        let x2 = randomSource.nextUniform() // a random number between 0 and 1
        let z1 = sqrt(-2 * log(x1)) * cos(2 * Float.pi * x2) // z1 is normally distributed
        
        // Convert z1 from the Standard Normal Distribution to our Normal Distribution
        return z1 * deviation + mean
    }
}

let mgd = BellCurve()
for _ in 0..<100 {
    print(mgd.nextFloat())
}

#elseif ATTEMPT_OF_SO_GUY1

func random(count: Int, in range: ClosedRange<Int>, mean: Int, deviation: Int) -> [Int] {
    guard count > 0 else { return [] }
    
    let randomSource = GKARC4RandomSource()
    let randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(mean), deviation: Float(deviation))
    
    // Clamp the result to within the specified range
    return (0..<count).map { _ in
        let rnd = randomDistribution.nextInt()
        print(randomDistribution.nextUniform())
        
        return rnd
    }
}

let arr = random(count: 1_000_000, in: 0...100, mean: 0, deviation: 3)

let summary = NSCountedSet(array: arr)
for i in -10...10 {
    print("\(i): \(summary.count(for: i))")
}

#if RUN_DARK
print("running dark")
#else
print("running blind")
#endif

#elseif ATTEMPT_OF_ROB

class Normal {
    let randomSource = GKARC4RandomSource()
    let randomDistribution: GKGaussianDistribution
    init(count: Int, mean: Int, deviation: Int) {
        guard count > 0 else { fatalError() }

        randomDistribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(mean), deviation: Float(deviation))
    }

    func nextUniform() -> Float {
        return randomDistribution.nextUniform()
//        return Double(randomDistribution.nextUniform())
    }
}

var histogram = Array(repeating: 0, count: 1000)
let normal = Normal(count: 1000, mean: 0, deviation: 3)

for _ in -500..<500 {
    let sample = normal.nextUniform()
    print("\(sample), ")
    let slotNumber = Int(sample * 100.0) + 500
    histogram[slotNumber] += 1
}

for x in -500..<500 {
    let y = histogram[x + 500]
    if y == 0 { continue }
    print("\(x): \(y)")
}

#else
let pointOhOneSix =  "L_N_A(true)_W(b[0.85008]v[0.85008])_N_A(true)_W(b[0.91789]v[1.032])_N_A(false)_W(b[1.0261]v[1.08621])_N_A(true)_W(b[1]v[1])_N_A(true)_W(b[0.97173]v[1.01098])_"
let pointOhOhEight = "L_N_A(true)_W(b[0.81439]v[0.84956])_N_A(false)_W(b[1]v[1])_N_A(true)_W(b[0.98591]v[1.01923])_N_A(true)_W(b[0.97715]v[3.41965])_N_A(true)_W(b[1]v[1])_"

var testSubjects = TSTestGroup()
let relay = TSRelay(testSubjects)
let fitnessTester = FTLearnZoeName()
let testSubjectFactory = TSZoeFactory(relay, fitnessTester: fitnessTester)
var curator: Curator?

var curatorStatus = CuratorStatus.running
let v = RepeatingTimer(timeInterval: 0.1)

v.eventHandler = { if let c = curator { curatorStatus = c.track(); curatorStatus = .finished } }

v.resume()
while curatorStatus == .running {
    while true {
        guard curator == nil else { continue }
        curator = Curator(starter: nil, testSubjectFactory: testSubjectFactory)
    }
}

print("\nCompletion state: \(curatorStatus)")
#endif
