import Foundation
import SpriteKit

enum SpriteUserDataKey {
    case net9Portal, netHalfNeuronsPortal, netDisplay, x, y, uuid, lineGraphDots
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
    let teethPool: SpritePool
    var count = 0

    init(scene: SKScene) {
        self.scene = scene

        (arkonsPool, nosesPool, teethPool) = SpriteFactory.makeArkonsPools()
        (fullNeuronsPool, halfNeuronsPool, linesPool) = SpriteFactory.makeNetDisplayPools()
        mannaPool = SpriteFactory.makeMannaPool()
    }

    static func makeMarkersPool() -> SpritePool {
        let markerPrototype = DronePrototype(
            alpha: 1, color: .white, colorBlendFactor: 1,
            zPosition: 0, zRotation: 0
        )

        let cMarkers = 5
        let p = SpritePool("Backgrounds", "marker", nil, cMarkers, markerPrototype, nil)

        zip(0..., p.parkedDrones).forEach {
            $1.zPosition = 50
            $1.zRotation = CGFloat($0) * CGFloat.tau / CGFloat(cMarkers)
        }

        return p
    }

    // swiftlint:disable large_tuple
    // Large Tuple Violation: Tuples should have at most 2 members. (large_tuple)
    static func makeArkonsPools() -> (ThoraxPool, SpritePool, SpritePool) {
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

        let toothPrototype =
            DronePrototype(alpha: 1, color: .systemPink, colorBlendFactor: 1, zPosition: 0, zRotation: 0)

        let teeth = SpritePool(
            "Arkons", "spark-tooth-large", ArkoniaScene.arkonsPortal, 1000, toothPrototype, nil
        )

        return (arkons, noses, teeth)
    }

    static func makeMannaPool() -> SpritePool {
        let mannaPrototype = DronePrototype(
            alpha: 1, color: .blue, colorBlendFactor: Arkonia.mannaColorBlendMaximum, zPosition: 0, zRotation: 0
        )

        let manna = SpritePool(
            "Manna", "manna", ArkoniaScene.arkonsPortal, Arkonia.cMannaMorsels, mannaPrototype, nil
        )

        return manna
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
