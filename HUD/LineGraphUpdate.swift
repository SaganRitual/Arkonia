import Foundation
import SpriteKit

enum LineGraphUpdate {
    static func getFoodHitStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { Census.dispatchQueue.async(execute: b) }

        func b() {
            Seasons.shared.getSeasonalFactors { dayIntensity, seasonIntensity in
                let temperature = dayIntensity + seasonIntensity
                onComplete(LineGraphInputSet(dayIntensity, seasonIntensity, temperature))
            }
        }

        a()
    }

    static func getWeatherStats(_ onComplete: @escaping (LineGraphInputSet?) -> Void) {
        func a() { Census.dispatchQueue.async(execute: b) }

        func b() {
            Seasons.shared.getSeasonalFactors { dayIntensity, seasonIntensity in
                let temperature = dayIntensity + seasonIntensity
                onComplete(LineGraphInputSet(dayIntensity, seasonIntensity, temperature))
            }
        }

        a()
    }

}
