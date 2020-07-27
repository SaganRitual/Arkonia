import Dispatch
import SwiftUI

class Histogram: ObservableObject {
    let cBuckets: Int
    let dBuckets: Double
    var histogram: [Int]?
    var inputRange: Range<Double>
    let inputRangeMode: InputRangeMode

    enum InputRangeMode { case minusOneToOne, zeroToOne }

    init(_ scale: Int, _ inputRangeMode: InputRangeMode) {
        self.cBuckets = scale
        self.dBuckets = Double(scale)
        self.histogram = [Int](repeating: 0, count: scale)
        self.inputRangeMode = inputRangeMode

        switch inputRangeMode {
        case .minusOneToOne: self.inputRange = Double(-1)..<Double(1)
        case .zeroToOne:     self.inputRange = Double(0)..<Double(1)
        }
    }

    func addSample(_ value: Double) {
        if(value < inputRange.lowerBound || value > inputRange.upperBound) {
            Debug.log { "Histogram overflow: value is \(value) range is \(inputRange)" }
        }

        let ss: Int
        switch inputRangeMode {
        case .minusOneToOne:
            let shifted = value + 1           // Convert scale -1..<1 to 0..<2
            let rescaled = shifted / 2     // Convert scale 0..<2 to 0..<1

            let s = Int(rescaled * dBuckets)
            ss = s < cBuckets ? s : cBuckets - 1

        case .zeroToOne:
            let rescaled = value / 2     // Convert scale 0..<1 to bucket subscript 0..<cBuckets
            let s = Int(rescaled * dBuckets)
            ss = s < cBuckets ? s : cBuckets - 1
        }

        self.histogram![ss] += 1
    }
}
