import Foundation
import SpriteKit

extension Arkon {
    typealias Update = (Bool, Bool) -> Void

    struct Status {
        init(fishNumber: Int) {
            self.fishNumber = fishNumber
        }

        mutating func postInit() {
            self.birthday.set(Display.shared.currentTime)
        }

        var age: TimeInterval { return Display.shared.currentTime - birthday }
        var birthday = SetOnce<TimeInterval>(defaultValue: 0.0)
        var cOffspring = 0      { willSet { World.shared.populationChanged = true } }
        let fishNumber: Int
        var health = 10.0
        var isAlive = false
        var isHealthy: Bool      { return health > 0 }
        var isDuggarest = false
        var isOldest = false
    }
}
