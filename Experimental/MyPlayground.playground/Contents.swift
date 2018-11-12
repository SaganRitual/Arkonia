import Cocoa

var quick = "The quick brown fox jumped over the lqzy dog"

let k_ = quick.firstIndex(of: "k")!
let kSegment = quick[k_...]

print(kSegment)

let u_ = kSegment.firstIndex(of: "u")!

let uSegment = kSegment[k_...]

print(uSegment)

let v_ = uSegment.firstIndex(of: "q")!
let vSegment = uSegment[u_..<v_]

print(vSegment)
