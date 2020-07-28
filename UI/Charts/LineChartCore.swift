import SwiftUI

class LineChartCore: ObservableObject {
    @Published var updateTrigger = 0

    var theData = [Cbuffer<Double>]()

    init(_ cDataSets: Int) {
        (0..<cDataSets).forEach { _ in
            let c = Cbuffer<Double>(cElements: 20, mode: .putOnlyRing)
            (0..<20).forEach { _ in c.put(0) }
            theData.append(c)
        }
    }

    func update(_ newSamples: [Double]) {
        DispatchQueue.main.async {
            zip(0..., newSamples).forEach { (ss, newSample) in
                let putValue: Double

                if newSample < 1 { putValue = 0 }
                else {
                    let log = log10(newSample)
                    putValue = min(4, log) / 4.0
                }

                self.theData[ss].put(putValue)
            }

            self.updateTrigger += 1
        }
    }
}
