import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getAgeStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { Census.dispatchQueue.async(execute: b) }

        func b() {
            let cLiveNeurons = CGFloat(Census.shared.cLiveNeurons)
            let cLiveArkons = Census.shared.archive.count

            if cLiveNeurons == 0 { onComplete(nil); return }

            let average = cLiveNeurons / CGFloat(cLiveArkons)
            let medianSS = cLiveArkons / 2

            let median: CGFloat
            let sorted = Census.shared.archive.sorted {
                $0.value.cNeurons < $1.value.cNeurons
            }

            if cLiveArkons % 2 == 1 {
                median = CGFloat(sorted[medianSS].value.cNeurons)
            } else {
                let upper = CGFloat(sorted[medianSS].value.cNeurons)
                let lower = CGFloat(sorted[medianSS - 1].value.cNeurons)
                median = CGFloat(upper + lower) / 2
            }

            onComplete(LineGraphInputSet(average, median, cLiveNeurons))
        }

        a()
    }
}
