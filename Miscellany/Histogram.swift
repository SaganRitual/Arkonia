import SwiftUI

class Histogram {
    class Bucket: CustomDebugStringConvertible {
        var debugDescription: String { "Bucket hit \(self.cSamples) sum \(self.sumOfAllSamples) avg \(self.average)" }

        func addSample(_ sample: Double) {
            cSamples += 1; sumOfAllSamples += sample
        }

        private(set) var cSamples: Int = 0
        private(set) var sumOfAllSamples: Double = 0

        var average: Double { sumOfAllSamples == 0 ? 0 : Double(cSamples) / sumOfAllSamples }

        func reset(cSamples: Int = 0, totalSum: Double = 0) { self.cSamples = cSamples; self.sumOfAllSamples = totalSum }
    }

    let cBuckets: Int
    let dBuckets: Double
    var inputRange: Range<Double>?
    let inputRangeMode: InputRangeMode
    var theBuckets: [Bucket]
    var variableTop: Double = 10

    enum InputRangeMode { case minusOneToOne, zeroToVariable, zeroToMax(Int), zeroToOne }

    var count: Int { self.cBuckets }

    init(_ cColumns: Int, _ inputRangeMode: InputRangeMode) {
        self.cBuckets = cColumns
        self.dBuckets = Double(cColumns)
        self.theBuckets = (0..<cColumns).map { _ in Bucket() }
        self.inputRangeMode = inputRangeMode

        switch inputRangeMode {
        case .minusOneToOne:           self.inputRange = Double(-1)..<Double(1)
        case .zeroToVariable:          self.inputRange = nil
        case let .zeroToMax(rangeTop): self.inputRange = Double(0)..<Double(rangeTop)
        case .zeroToOne:               self.inputRange = Double(0)..<Double(1)
        }
    }

    func getScalarDistribution(reset: Bool) -> [CGFloat]? {
        guard let max = theBuckets.max(by: { $0.cSamples < $1.cSamples }) else
            { return nil }

        if max.cSamples == 0 { return nil }

        defer { if reset { theBuckets.forEach { $0.reset() } } }
        return theBuckets.map { CGFloat($0.cSamples) / CGFloat(max.cSamples) }
    }

    func track(sample: Double) {
        addSample(xAxis: sample, yAxis: 1)
    }

    func track(cJumps: Int, against cGrazeSuccesses: Int) {
        Debug.log(level: 224) { "track cJumps \(cJumps) against grazeSuccess \(cGrazeSuccesses)" }
        addSample(xAxis: Double(cJumps), yAxis: Double(cGrazeSuccesses))
    }

    private func addSample(xAxis: Double, yAxis: Double) {
        let bucketSS = getBucketFor(xAxis)
        theBuckets[bucketSS].addSample(yAxis)
    }

    private func getBucketFor(_ value: Double) -> Int {
        assert(inputRange == nil || inputRange!.contains(value))

        let ss: Int
        switch inputRangeMode {
        case .minusOneToOne:
            let shifted = value + 1             // Convert scale -1..<1 to 0..<2
            let rescaled = shifted / 2          // Convert scale 0..<2 to 0..<1

            let s = Int(rescaled * dBuckets)
            ss = s < cBuckets ? s : cBuckets - 1

        case .zeroToOne:
            let s = Int(value * dBuckets)
            ss = s < cBuckets ? s : cBuckets - 1

        case let .zeroToMax(value):
            let rescaled = Double(value) / Double(inputRange!.upperBound)
            let s = Int(rescaled * dBuckets)
            ss = s < cBuckets ? s : cBuckets - 1

        case .zeroToVariable:
            let rescaled = Double(value) / variableTop
            let s = Int(rescaled * dBuckets)
            if s >= cBuckets { scaleUp() }
            ss = s < cBuckets ? s : cBuckets - 1
        }

        return ss
    }

    func scaleUp() {
        let totalSamples = theBuckets.reduce(0) { $0 + $1.cSamples }
        let totalSum = theBuckets.reduce(0) { $0 + $1.sumOfAllSamples }

        variableTop *= 10

        theBuckets[0].reset(cSamples: totalSamples, totalSum: totalSum)
        theBuckets.dropFirst().forEach { $0.reset() }
    }
}
