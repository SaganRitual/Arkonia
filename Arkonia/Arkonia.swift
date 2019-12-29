import SpriteKit

func six(_ string: String?) -> String { return String(string?.prefix(15) ?? "<no input>") }

class Arkonia {
    typealias OnComplete1p = (Int) -> Void

    static let masterScale = CGFloat(2)
    static let senseGridSide = 3
    static let spriteScale = masterScale / 6
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeurons = 2 * cSenseGridlets + 4
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1

    static let allowSpawning = true
    static let inhaleFudgeFactor: CGFloat = 2.0
    static let spawnOverhead: CGFloat = 1.5


}
