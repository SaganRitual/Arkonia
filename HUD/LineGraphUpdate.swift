import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getFoodHitStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { Census.dispatchQueue.async(execute: b) }

        func b() {
            onComplete(LineGraphInputSet(0, 0, 0))
        }

        a()
    }

    static func getWeatherStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { Census.dispatchQueue.async(execute: b) }

        func b() {
            mainDispatch {
                let temperature =
                    Clock.shared.seasonalFactors.sunHeight +
                    Clock.shared.seasonalFactors.sunstickHeight

                onComplete(
                    LineGraphInputSet(
                            Clock.shared.seasonalFactors.sunHeight,
                            Clock.shared.seasonalFactors.sunstickHeight,
                            temperature
                    )
                )
            }
        }

        a()
    }

}
