func getWeightedRandomLogThing(from startingValue: Double) -> Double {
    let randomPercentage = Double.random(in: -1...1)
    if randomPercentage == 0 { return 1 }

    return ((0.001 / randomPercentage) * startingValue) + startingValue
}

//for bump in 0..<10 {
//    let d = getWeightedRandomLogThing(from: Double(bump))
//    print(d)
//}

func getWeightedRandomLogThing(from startingValue: Int) -> Int {
    let randomPercentage = Double.random(in: -1...1)
    if randomPercentage == 0 { return 1 }
    
    let d = ((0.001 / randomPercentage) * Double(startingValue)).rounded(.towardZero)
    
    return startingValue + Int(d)
}


for bump in stride(from: 0, to: 100, by: 1) {
    let d = getWeightedRandomLogThing(from: bump)
    print(d)
}
