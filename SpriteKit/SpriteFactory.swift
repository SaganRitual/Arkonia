import Foundation
import SpriteKit

enum SpriteUserDataKey: String {
    case net9Portal, netHalfNeuronsPortal, netDisplay, x, y, uuid
}

class SpriteFactory {
    static var shared: SpriteFactory!

    let arkonsPool: ThoraxPool
    let dotsPool: SpritePool
    let fullNeuronsPool: SpritePool
    let halfNeuronsPool: SpritePool
    let linesPool: SpritePool
    let mannaPool: SpritePool
    let nosesPool: SpritePool
    let scene: SKScene
    var count = 0

    init(scene: SKScene) {
        self.scene = scene

        (arkonsPool, nosesPool) = SpriteFactory.makeArkonsPools()
        (fullNeuronsPool, halfNeuronsPool, linesPool) = SpriteFactory.makeNetDisplayPools()
        (mannaPool, dotsPool) = SpriteFactory.makeMannaPool()
    }

    static func makeArkonsPools() -> (ThoraxPool, SpritePool) {
        let arkonPrototype =
            DronePrototype(alpha: 1, color: .gray, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let arkons = ThoraxPool(
            "Arkons", "spark-thorax-large", ArkoniaScene.arkonsPortal, 1000, arkonPrototype
        )

        let nosePrototype =
            DronePrototype(alpha: 1, color: .darkGray, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let noses = SpritePool(
            "Arkons", "spark-nose-large", ArkoniaScene.arkonsPortal, 1000, nosePrototype, nil
        )

        return (arkons, noses)
    }

    static func makeMannaPool() -> (SpritePool, SpritePool) {
        let mannaPrototype = DronePrototype(
            alpha: 1, color: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum, zPosition: 0, zRotation: 0
        )

        let manna = SpritePool(
            "Manna", "manna", ArkoniaScene.arkonsPortal, Arkonia.cMannaMorsels, mannaPrototype, nil
        )

        let dots = SpritePool(
            "Manna", "manna", ArkoniaScene.arkonsPortal, (LineGraph.cColumns * 2), mannaPrototype, nil
        )

        return (manna, dots)
    }

    // swiftlint:disable large_tuple
    static func makeNetDisplayPools() -> (SpritePool, SpritePool, SpritePool) {
        Debug.log(level: 159) { "makeNetDisplayPools" }
        let fullNeuronPrototype =
            DronePrototype(alpha: 0, color: .green, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let fullNeurons = SpritePool(
            "Neurons", "neuron-plain", nil, 1000, fullNeuronPrototype, .net9Portal
        )

        let halfNeuronPrototype =
            DronePrototype(alpha: 0, color: .gray, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let halfNeurons = SpritePool(
            "Neurons", "neuron-plain-half", nil, 500, halfNeuronPrototype, .netHalfNeuronsPortal
        )

        let linePrototype =
            DronePrototype(alpha: 0, color: .green, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let lines = SpritePool(
            "Line", "line", nil, 4000, linePrototype, nil
        )

        return (fullNeurons, halfNeurons, lines)
    }
    // swiftlint:enable large_tuple
}

extension SpriteFactory {

    static func drawLine(from start: CGPoint, to end: CGPoint, color: SKColor) -> SKShapeNode {
        let linePath = CGMutablePath()

        linePath.move(to: start)
        linePath.addLine(to: end)

        let line = SKShapeNode(path: linePath)
        line.strokeColor = color
        line.lineWidth = 3
        line.zPosition = 0
        return line
    }
}
