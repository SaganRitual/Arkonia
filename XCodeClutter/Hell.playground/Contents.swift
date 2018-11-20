import Foundation

var lowestScore = Int.max
var highestScore = 0
var missedLows = 0
var missedHighs = 0
var caughtLows = 0
var caughtHighs = 0
for _ in 0..<10000 {
    let c = abs(Int.random(in: -1000000...1000000))
    if c < lowestScore { lowestScore = c; caughtLows += 1 }
    else { missedLows += 1}
    if c > highestScore { highestScore = c; caughtHighs += 1 }
    else { missedHighs += 1 }
}

print("lowestScore = \(lowestScore), highestScore = \(highestScore)")
print("caughtLows = \(caughtLows), caughtHighs = \(caughtHighs)")
print("missedLows = \(missedLows), missedHighs = \(missedHighs)")
