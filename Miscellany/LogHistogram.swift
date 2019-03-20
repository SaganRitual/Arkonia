import Foundation
import GameplayKit

class LogHistogram {
    private var counters = [Int: Int]()
    private var maxSampleValueMagnitude = 0
    private let sampleResolution: Double

    init(sampleResolution: Double) {
        self.sampleResolution = sampleResolution
    }

    class Accumulator {
        let histogram: LogHistogram
        let numberOfResultColumns: Int

        init(_ histogram: LogHistogram, _ numberOfResultColumns: Int) {
            self.histogram = histogram
            self.numberOfResultColumns = numberOfResultColumns
        }

        func accumulateCounts(base: Double, raiseBase: (Double, Double) -> Double) -> ([Int], Int) {

            var capForCurrentResultsCounter = base
            var results = [Int]()
            var subtotal = 0
            var whichRawCounter = 0
            var whichResultsCounter = 0

            while true {
                if whichResultsCounter > numberOfResultColumns ||
                    whichRawCounter >= histogram.maxSampleValueMagnitude {
                    break
                }

                if floor(Double(whichRawCounter)) >= capForCurrentResultsCounter {
                    results.append(subtotal)

                    capForCurrentResultsCounter = raiseBase(capForCurrentResultsCounter, base)
                    whichResultsCounter += 1
                    subtotal = 0
                    continue
                }

                subtotal += (histogram.counters[whichRawCounter] ?? 0)
                whichRawCounter += 1
            }

            return (results, whichRawCounter)
        }

        func accumulateCounts<T: BinaryFloatingPoint>(
            base: T,
            raiseBase: (Double, Double) -> Double)
            -> ([Int], Int)
        {
            return accumulateCounts(base: Double(base), raiseBase: raiseBase)
        }

        func accumulateCounts<T: BinaryInteger>(
            base: T,
            raiseBase: (Double, Double) -> Double)
            -> ([Int], Int)
        {
            return accumulateCounts(base: Double(base), raiseBase: raiseBase)
        }
    }

    func addSample(_ value: Double) {
        let whichCounter = abs(Int(value / sampleResolution))

        if whichCounter > maxSampleValueMagnitude { maxSampleValueMagnitude = whichCounter }

        if counters[whichCounter] == nil { counters[whichCounter] = 1 }
        else { counters[whichCounter]! += 1 }
    }

    func addSample<T: BinaryFloatingPoint>(_ value: T) { addSample(Double(value)) }
    func addSample<T: BinaryInteger>(_ value: T) { addSample(Double(value)) }

    //swiftlint:disable large_tuple
    func getCountsCompressed(to numberOfResultColumns: Int) -> (Double, [Int], Int) {
        let m = Double(maxSampleValueMagnitude)
        let n = Double(numberOfResultColumns)
        let base = pow(m, 1.0 / (n + 1))   // The width (that is, the range) of each column

        let accumulator = Accumulator(self, numberOfResultColumns)
        let (results, whichRawCounter) = accumulator.accumulateCounts(base: base) { $0 * $1 }

        return (base, results, whichRawCounter)
    }
    //swiftlint:enable large_tuple

    func getCountsTruncated(to numberOfResultColumns: Int) -> ([Int], Int) {
        let m = Int(maxSampleValueMagnitude)
        let n = numberOfResultColumns
        let base = m / n   // The width (that is, the range) of each column

        let accumulator = Accumulator(self, numberOfResultColumns)
        let (results, whichRawCounter) = accumulator.accumulateCounts(base: base) { $0 + $1 }

        return (results, whichRawCounter)
    }

}
