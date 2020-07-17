import SwiftUI

class LineChartData: ObservableObject {
    @Published var updateTrigger = 0
    var theData = [Cbuffer<Double>]()

    var timer: Timer?

    init(_ cDataSets: Int) {
        (0..<cDataSets).forEach { _ in
            let c = Cbuffer<Double>(cElements: 20, mode: .putOnlyRing)
            (0..<20).forEach { _ in c.put(Double.random(in: 0..<1)) }
            theData.append(c)
        }

        self.timer = Timer.scheduledTimer(
            withTimeInterval: 1, repeats: true, block: update
        )
    }

    func update(_: Timer) {
        theData.forEach { cBuffer in cBuffer.put(Double.random(in: 0..<1)) }
        updateTrigger += 1
    }
}
