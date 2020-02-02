import Foundation
import SpriteKit

enum SpriteUserDataKey {
    case manna, net9Portal, netHalfNeuronsPortal, netDisplay, stepper, uuid, debug
    case setContentsCallback, bloomActionIx
}

class SpriteFactory {
    static var shared: SpriteFactory!

    let arkonsPool: ThoraxPool
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
        mannaPool = SpriteFactory.makeMannaPool()
    }

    static func makeArkonsPools() -> (ThoraxPool, SpritePool) {
        let arkonPrototype =
            DronePrototype(alpha: 0, color: .gray, colorBlendFactor: 1, zPosition: 10, zRotation: 0)

        let arkons = ThoraxPool(
            "Arkons", "spark-thorax-large", GriddleScene.arkonsPortal, 1000, arkonPrototype, .stepper
        )

        let nosePrototype =
            DronePrototype(alpha: 0, color: .darkGray, colorBlendFactor: 1, zPosition: 11, zRotation: 0)

        let noses = SpritePool(
            "Arkons", "spark-nose-large", GriddleScene.arkonsPortal, 1000, nosePrototype, nil
        )

        return (arkons, noses)
    }

    static func makeMannaPool() -> SpritePool {
        let mannaPrototype = DronePrototype(
            alpha: 0, color: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum, zPosition: 9, zRotation: 0
        )

        return SpritePool(
            "Manna", "manna", GriddleScene.mannaPortal, Arkonia.cMannaMorsels, mannaPrototype, .manna
        )
    }

    // swiftlint:disable large_tuple
    static func makeNetDisplayPools() -> (SpritePool, SpritePool, SpritePool) {
        let fullNeuronPrototype =
            DronePrototype(alpha: 0, color: .green, colorBlendFactor: 1, zPosition: 5, zRotation: 0)

        let fullNeurons = SpritePool(
            "Neurons", "neuron-plain", nil, 1000, fullNeuronPrototype, .net9Portal
        )

        let halfNeuronPrototype =
            DronePrototype(alpha: 0, color: .gray, colorBlendFactor: 1, zPosition: 5, zRotation: 0)

        let halfNeurons = SpritePool(
            "Neurons", "neuron-plain-half", nil, 500, halfNeuronPrototype, .netHalfNeuronsPortal
        )

        let linePrototype =
            DronePrototype(alpha: 0, color: .green, colorBlendFactor: 1, zPosition: 5, zRotation: 0)

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
        line.zPosition = 10
        return line
    }
}
