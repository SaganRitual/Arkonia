import SpriteKit

class Arkonia {
    typealias OnComplete1p = (Int) -> Void

    static let shared = Arkonia()

    static let masterScale = CGFloat(2)
    static let senseGridSide = 3
    static let spriteScale = masterScale / 6
    static let cSenseGridlets = senseGridSide * senseGridSide
    static let cSenseNeurons = 2 * cSenseGridlets + 4
    static let cMotorNeurons = 9 - 1
    static let cMotorGridlets = cMotorNeurons + 1

    static let dispatchQueue = DispatchQueue(
        label: "ak.arkonia.q",
        attributes: .concurrent,
        target: DispatchQueue.global(qos: .utility)
    )
}
